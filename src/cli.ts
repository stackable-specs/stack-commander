#!/usr/bin/env bun
import { Command } from 'commander';
import pkg from '../package.json' with { type: 'json' };
import { greet } from './commands/greet.ts';
import {
  emitCommandLog,
  initializeObservability,
  recordCommandMetric,
  runWithSpan,
  shutdownObservability,
} from './observability.ts';

/**
 * Dependency-injection hooks for the CLI program.
 *
 * @public
 * @category CLI
 */
export interface CreateProgramOptions {
  /** Optional stdout writer override used by in-process tests. */
  readonly stdout?: (chunk: string) => void;
  /** Optional stderr writer override used by in-process tests. */
  readonly stderr?: (chunk: string) => void;
  /** Whether Commander should throw instead of terminating the process. */
  readonly exitOverride?: boolean;
}

function forEachCommand(root: Command, fn: (cmd: Command) => void): void {
  fn(root);
  for (const child of root.commands) {
    forEachCommand(child, fn);
  }
}

/**
 * Construct the root Commander program for the stack CLI.
 *
 * @public
 * @category CLI
 * @param options - Optional output and exit overrides for in-process tests.
 * @returns A configured Commander program.
 * @throws Re-throws command failures from downstream handlers.
 * @example
 * ```ts
 * const program = createProgram({ exitOverride: true });
 * ```
 */
export function createProgram(options: CreateProgramOptions = {}): Command {
  const program = new Command();

  program
    .name('ts-bun')
    .description('Reference CLI for the typescript-bun stack')
    .version(pkg.version)
    .showHelpAfterError();

  const writeOut = options.stdout ?? ((chunk: string): boolean => process.stdout.write(chunk));
  const writeErr = options.stderr ?? ((chunk: string): boolean => process.stderr.write(chunk));

  program
    .command('greet')
    .description('Print a greeting to stdout')
    .requiredOption('-n, --name <name>', 'name to greet')
    .option('-l, --loud', 'shout the greeting', false)
    .option('-o, --output <path>', 'write the greeting to a file instead of stdout')
    .action(async (opts: { name: string; loud: boolean; output?: string }) => {
      await runWithSpan(
        'cli.greet',
        {
          'cli.command': 'greet',
          'cli.output.file': opts.output ?? 'stdout',
        },
        async () => {
          const message = greet({ name: opts.name, loud: opts.loud });
          if (opts.output !== undefined) {
            await Bun.write(opts.output, `${message}\n`);
          } else {
            writeOut(`${message}\n`);
          }

          emitCommandLog('greet command completed', {
            'cli.command': 'greet',
            'cli.output.file': opts.output ?? 'stdout',
          });
          recordCommandMetric('greet', 'ok', {
            'cli.output.file': opts.output ?? 'stdout',
          });
        },
      );
    });

  forEachCommand(program, (cmd) => {
    cmd.configureOutput({ writeOut, writeErr });
    if (options.exitOverride === true) {
      cmd.exitOverride();
    }
  });

  return program;
}

if (import.meta.main) {
  await initializeObservability();
  try {
    const program = createProgram();
    await program.parseAsync(process.argv);
  } finally {
    await shutdownObservability();
  }
}
