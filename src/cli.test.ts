import { describe, expect, test } from 'bun:test';
import { rm } from 'node:fs/promises';
import { createProgram } from './cli.ts';

function captured() {
  let out = '';
  let err = '';
  const program = createProgram({
    stdout: (chunk) => {
      out += chunk;
    },
    stderr: (chunk) => {
      err += chunk;
    },
    exitOverride: true,
  });
  return {
    program,
    getOut: () => out,
    getErr: () => err,
  };
}

describe('cli: greet', () => {
  test('prints a greeting for --name', async () => {
    const { program, getOut } = captured();
    await program.parseAsync(['bun', 'ts-bun', 'greet', '--name', 'World']);
    expect(getOut()).toBe('Hello, World!\n');
  });

  test('shouts when --loud is passed', async () => {
    const { program, getOut } = captured();
    await program.parseAsync(['bun', 'ts-bun', 'greet', '--name', 'World', '--loud']);
    expect(getOut()).toBe('HELLO, WORLD!\n');
  });

  test('errors when required --name is missing', async () => {
    const { program, getErr } = captured();
    let caught: unknown;
    try {
      await program.parseAsync(['bun', 'ts-bun', 'greet']);
    } catch (err) {
      caught = err;
    }
    expect(caught).toBeDefined();
    expect((caught as { code?: string }).code).toBe('commander.missingMandatoryOptionValue');
    expect(getErr()).toContain("required option '-n, --name <name>'");
  });

  test('writes the greeting to a file when --output is passed', async () => {
    const { program, getOut } = captured();
    const outputFile = 'tmp-greeting.txt';
    await program.parseAsync(['bun', 'ts-bun', 'greet', '--name', 'World', '--output', outputFile]);
    expect(getOut()).toBe('');
    expect(await Bun.file(outputFile).text()).toBe('Hello, World!\n');
    await rm(outputFile, { force: true });
  });
});
