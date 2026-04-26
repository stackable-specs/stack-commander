# BDR-001: Greeting command renders a message

## Status

Proposed

## Behavior

The CLI renders a greeting for a caller-supplied name and can optionally write that rendered message to a caller-chosen file.

## Context

The reference stack needs one end-to-end behavior contract that is small enough to understand quickly but still exercises the stack's real CLI surface, packaging path, and filesystem integration. A greeting command is the minimum useful capability that can be checked as a black-box by both smoke and integration tests.

## Acceptance Criteria

- AC-1: `ts-bun greet --name Ada` exits `0` and writes `Hello, Ada!` to stdout followed by a newline.
- AC-2: `ts-bun greet --name Ada --loud` exits `0` and writes `HELLO, ADA!` to stdout followed by a newline.
- AC-3: `ts-bun greet --name Ada --output /tmp/out.txt` exits `0`, writes no greeting text to stdout, and creates `/tmp/out.txt` containing `Hello, Ada!` followed by a newline.
- AC-4: `ts-bun greet` without `--name` exits non-zero and prints a help/error message mentioning the required `--name` option.

## Verification

### Scenario 1: Default stdout rendering

- **Given** the CLI is available as the built artifact
- **When** the caller runs `ts-bun greet --name Ada`
- **Then** the process exits `0` and stdout equals `Hello, Ada!\n`

### Scenario 2: Loud rendering

- **Given** the CLI is available as the built artifact
- **When** the caller runs `ts-bun greet --name Ada --loud`
- **Then** the process exits `0` and stdout equals `HELLO, ADA!\n`

### Scenario 3: File output

- **Given** the CLI is available as the built artifact
- **When** the caller runs `ts-bun greet --name Ada --output /tmp/out.txt`
- **Then** the process exits `0`, stdout is empty, and `/tmp/out.txt` equals `Hello, Ada!\n`
