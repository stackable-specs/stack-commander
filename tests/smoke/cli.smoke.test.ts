import { beforeAll, describe, expect, test } from 'bun:test';

const binary = 'dist/ts-bun';

async function runBinary(args: string[]) {
  const proc = Bun.spawn([binary, ...args], {
    stdout: 'pipe',
    stderr: 'pipe',
  });
  const [stdout, stderr, exitCode] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  return { stdout, stderr, exitCode };
}

beforeAll(async () => {
  const build = Bun.spawn(['bun', 'run', 'build'], { stdout: 'inherit', stderr: 'inherit' });
  expect(await build.exited).toBe(0);
});

describe('smoke: built CLI', () => {
  test('prints version', async () => {
    const result = await runBinary(['--version']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe('0.1.0');
  });

  test('prints top-level help', async () => {
    const result = await runBinary(['--help']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout).toContain('Reference CLI for the typescript-bun stack');
  });

  test('runs the happy-path greeting command', async () => {
    const result = await runBinary(['greet', '--name', 'Ada']);
    expect(result.exitCode).toBe(0);
    expect(result.stdout).toBe('Hello, Ada!\n');
  });
});
