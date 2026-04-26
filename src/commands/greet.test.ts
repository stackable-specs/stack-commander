import { describe, expect, test } from 'bun:test';
import { greet } from './greet.ts';

describe('greet', () => {
  test('returns a friendly hello for the given name', () => {
    expect(greet({ name: 'World' })).toBe('Hello, World!');
  });

  test('uppercases the greeting when loud is true', () => {
    expect(greet({ name: 'World', loud: true })).toBe('HELLO, WORLD!');
  });

  test('trims surrounding whitespace before rendering', () => {
    expect(greet({ name: '  World  ' })).toBe('Hello, World!');
  });

  test('throws when the name is blank after trimming', () => {
    expect(() => greet({ name: '   ' })).toThrow('name must not be empty');
  });
});
