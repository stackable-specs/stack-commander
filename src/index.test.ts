import { describe, expect, test } from 'bun:test';
import * as stack from './index.ts';

describe('index exports', () => {
  test('re-exports the public stack surface', () => {
    expect(typeof stack.createProgram).toBe('function');
    expect(typeof stack.greet).toBe('function');
    expect(typeof stack.initializeObservability).toBe('function');
    expect(typeof stack.runWithSpan).toBe('function');
    expect(typeof stack.emitCommandLog).toBe('function');
    expect(typeof stack.shutdownObservability).toBe('function');
  });
});
