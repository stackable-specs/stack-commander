export { createProgram } from './cli.ts';
export type { CreateProgramOptions } from './cli.ts';
export { greet } from './commands/greet.ts';
export type { GreetOptions } from './commands/greet.ts';
export {
  initializeObservability,
  runWithSpan,
  emitCommandLog,
  shutdownObservability,
} from './observability.ts';
