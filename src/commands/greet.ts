/**
 * Options accepted by {@link greet}.
 *
 * @public
 * @category Commands
 */
export interface GreetOptions {
  /** Caller-supplied name rendered into the greeting output. */
  readonly name: string;
  /** Whether the rendered greeting should be uppercased. */
  readonly loud?: boolean;
}

/**
 * Render the greeting message for a caller-supplied name.
 *
 * @public
 * @category Commands
 * @param options - Command input describing the name to greet and whether the output should be uppercased.
 * @returns The rendered greeting message.
 * @throws When `options.name` is empty after trimming.
 * @example
 * ```ts
 * greet({ name: 'Ada' });
 * // => "Hello, Ada!"
 * ```
 */
export function greet(options: GreetOptions): string {
  const normalizedName = options.name.trim();
  if (normalizedName.length === 0) {
    throw new TypeError('name must not be empty');
  }

  const message = `Hello, ${normalizedName}!`;
  return options.loud === true ? message.toUpperCase() : message;
}
