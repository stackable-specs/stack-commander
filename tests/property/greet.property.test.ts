import { describe, expect, test } from 'bun:test';
import fc from 'fast-check';
import { greet } from '../../src/commands/greet.ts';

describe('greet property tests', () => {
  test('invariant: loud output is the uppercase form of normal output', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 1 }).filter((value) => value.trim().length > 0),
        (name) => {
          expect(greet({ name, loud: true })).toBe(greet({ name }).toUpperCase());
        },
      ),
      {
        numRuns: 100,
        examples: [['Ada'], ['  Grace  '], ['\u00c9lodie']],
      },
    );
  });
});
