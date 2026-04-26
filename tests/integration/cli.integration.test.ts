import { beforeAll, describe, expect, test } from 'bun:test';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const binary = 'dist/ts-bun';

beforeAll(async () => {
  const build = Bun.spawn(['bun', 'run', 'build'], { stdout: 'inherit', stderr: 'inherit' });
  expect(await build.exited).toBe(0);
});

describe('BDR-001 integration scenarios', () => {
  test('writes to a real filesystem path when --output is provided', async () => {
    const dir = await mkdtemp(join(tmpdir(), 'ts-bun-integration-'));
    const outputPath = join(dir, 'greeting.txt');

    const proc = Bun.spawn([binary, 'greet', '--name', 'Ada', '--output', outputPath], {
      stdout: 'pipe',
      stderr: 'pipe',
    });
    const [stdout, stderr, exitCode] = await Promise.all([
      new Response(proc.stdout).text(),
      new Response(proc.stderr).text(),
      proc.exited,
    ]);

    expect(exitCode).toBe(0);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
    expect(await readFile(outputPath, 'utf8')).toBe('Hello, Ada!\n');

    await rm(dir, { recursive: true, force: true });
  });
});
