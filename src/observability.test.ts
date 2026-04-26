import { describe, expect, test } from 'bun:test';
import { initializeObservability, shutdownObservability } from './observability.ts';

describe('observability', () => {
  test('does not start telemetry when OTEL is disabled', async () => {
    const previous = process.env.OTEL_ENABLED;
    process.env.OTEL_ENABLED = 'false';

    expect(await initializeObservability()).toBe(false);
    await shutdownObservability();

    if (previous === undefined) {
      delete process.env.OTEL_ENABLED;
    } else {
      process.env.OTEL_ENABLED = previous;
    }
  });
});
