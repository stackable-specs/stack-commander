import { context, trace, type Attributes, SpanStatusCode } from '@opentelemetry/api';
import { logs, SeverityNumber } from '@opentelemetry/api-logs';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPLogExporter } from '@opentelemetry/exporter-logs-otlp-http';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-http';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { LoggerProvider, BatchLogRecordProcessor } from '@opentelemetry/sdk-logs';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';
import { NodeSDK } from '@opentelemetry/sdk-node';

let sdk: NodeSDK | null = null;
let loggerProvider: LoggerProvider | null = null;
let started = false;

function otelEnabled(): boolean {
  return process.env.OTEL_ENABLED === 'true' || process.env.APP_OTEL_ENABLED === 'true';
}

async function resolveHeaders(): Promise<Record<string, string>> {
  const path = process.env.OTEL_EXPORTER_OTLP_HEADERS_FILE;
  if (path === undefined || path.length === 0) {
    return {};
  }

  const content = await Bun.file(path).text();
  return content
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .reduce<Record<string, string>>((headers, line) => {
      const [key, ...rest] = line.split('=');
      if (key !== undefined && rest.length > 0) {
        headers[key] = rest.join('=');
      }
      return headers;
    }, {});
}

/**
 * Initialize OpenTelemetry exporters once for the process.
 *
 * @public
 * @category Observability
 * @returns Whether telemetry was initialized for this process.
 * @throws When exporter configuration is invalid.
 * @example
 * ```ts
 * await initializeObservability();
 * ```
 */
export async function initializeObservability(): Promise<boolean> {
  if (started || !otelEnabled()) {
    return started;
  }

  const headers = await resolveHeaders();
  const traceExporter = new OTLPTraceExporter({ headers });
  const metricExporter = new OTLPMetricExporter({ headers });
  const logExporter = new OTLPLogExporter({ headers });

  loggerProvider = new LoggerProvider({
    processors: [new BatchLogRecordProcessor(logExporter)],
  });
  logs.setGlobalLoggerProvider(loggerProvider);

  sdk = new NodeSDK({
    traceExporter,
    metricReader: new PeriodicExportingMetricReader({
      exporter: metricExporter,
    }),
    instrumentations: [getNodeAutoInstrumentations()],
  });

  sdk.start();
  started = true;
  return true;
}

/**
 * Emit a structured command log record with the active trace context.
 *
 * @public
 * @category Observability
 * @param message - Human-readable log message.
 * @param attributes - Structured fields attached to the log record.
 * @returns Nothing.
 * @example
 * ```ts
 * emitCommandLog('greet completed', { 'cli.command': 'greet' });
 * ```
 */
export function emitCommandLog(message: string, attributes: Attributes = {}): void {
  const span = trace.getSpan(context.active());
  const spanContext = span?.spanContext();
  const logger = logs.getLogger('typescript-bun-cli');

  logger.emit({
    severityNumber: SeverityNumber.INFO,
    severityText: 'INFO',
    body: message,
    attributes: {
      ...attributes,
      'trace.id': spanContext?.traceId,
      'span.id': spanContext?.spanId,
    },
  });
}

/**
 * Execute an operation inside an active span.
 *
 * @public
 * @category Observability
 * @param name - Span name to create.
 * @param attributes - Span attributes to attach immediately.
 * @param fn - Operation to run inside the span.
 * @returns The callback result.
 * @throws Re-throws callback failures after recording them on the span.
 * @example
 * ```ts
 * await runWithSpan('cli.greet', { 'cli.command': 'greet' }, async () => 'ok');
 * ```
 */
export async function runWithSpan<T>(
  name: string,
  attributes: Attributes,
  fn: () => Promise<T> | T,
): Promise<T> {
  const tracer = trace.getTracer('typescript-bun-cli');
  return await tracer.startActiveSpan(name, { attributes }, async (span) => {
    try {
      const result = await fn();
      return result;
    } catch (error) {
      span.recordException(error as Error);
      span.setStatus({ code: SpanStatusCode.ERROR, message: 'command failed' });
      throw error;
    } finally {
      span.end();
    }
  });
}

/**
 * Flush and stop OpenTelemetry exporters.
 *
 * @public
 * @category Observability
 * @returns Nothing.
 * @throws When the SDK fails to flush buffered telemetry.
 * @example
 * ```ts
 * await shutdownObservability();
 * ```
 */
export async function shutdownObservability(): Promise<void> {
  if (!started) {
    return;
  }

  await Promise.all([sdk?.shutdown(), loggerProvider?.shutdown()]);
  sdk = null;
  loggerProvider = null;
  started = false;
}
