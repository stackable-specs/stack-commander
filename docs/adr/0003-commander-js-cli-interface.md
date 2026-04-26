# ADR 0003: Use Commander.js for the CLI invocation contract

- **Status:** Accepted
- **Date:** 2026-04-24
- **Layer:** interface
- **Related spec:** [`specs/interface/commander-js.md`](../specs/interface/commander-js.md)

## Context

The CLI invocation surface — commands, options, arguments, help, version, errors, exit codes — is a contract shared across every subcommand, CI script, and test. When that contract is implemented ad-hoc (manual `process.argv` slicing, hand-rolled `if (!opts.foo) exit(1)` checks, hardcoded help strings, `process.exit()` from handlers), it fragments in predictable ways: subcommands behave inconsistently, unit tests must shell out to subprocesses to exercise parsing, and the uniform help/error UX users expect disappears.

A parser library centralizes the contract. Among mature options in the TypeScript/Bun ecosystem:

- **Commander.js.** Declarative, widely adopted, stable API, strong support for async action handlers and in-process test harnessing (`exitOverride`, `configureOutput`).
- **yargs.** Powerful but heavier, with a builder style that tends to spread configuration across many files.
- **oclif.** Opinionated framework geared toward large, plugin-based CLIs — more scaffolding than this stack needs.
- **Roll our own.** Lowest dependency cost, highest long-term maintenance cost; every new subcommand re-litigates help, errors, and exit codes.

## Decision

Adopt Commander.js and use it declaratively. One top-level `Command` per process. Every subcommand is declared with `.command()` + `.action()`; every positional with `.argument()`; every option with `.option()` (or `.requiredOption()` when mandatory). Non-string option types get a parser function; defaults live on `.option()` / `.argument()`, not inside handlers. The program version comes from `package.json` via `.version()`. Errors surface through `command.error(msg, { exitCode })` — never `process.exit()` from a handler. Async handlers run under `await program.parseAsync(argv)`. Tests use `program.exitOverride()` and `program.configureOutput(...)` to exercise parsing and handler logic in-process.

## Consequences

**Positive**

- The invocation contract is single-sourced: help text, required options, defaults, and types all live in one place per command.
- Consistent UX across subcommands — identical error formatting, exit codes, and `--help` layout.
- Unit tests run in-process, so they're fast and can assert on captured stdout/stderr without spawning subprocesses.
- Async handlers are first-class, which composes cleanly with Bun's runtime.

**Negative**

- A library dependency the project would not otherwise need; Commander's API stability becomes part of the stack's risk surface.
- Edge cases (unknown options, excess arguments) require explicit opt-in with a justifying comment — slight friction compared to "just accept everything."
- Team members must learn Commander's declarative vocabulary rather than reading argv directly.

**Neutral**

- Higher layers (presentation, delivery) consume the help/version/exit-code contract Commander establishes; swapping parsers later would touch user-facing UX and CI scripts.
