---
id: commander-js
layer: interface
extends: []
---

# Commander.js CLI Interface

## Purpose

Commander.js encodes an entire CLI invocation contract — commands, options, arguments, help, version, errors, and exit codes — in one declarative place. Ad-hoc `process.argv` parsing inside action handlers, manual required-option checks, hardcoded help strings, or `process.exit()` calls from handlers all fragment that contract: the CLI behaves inconsistently across subcommands, unit tests end up shelling out to subprocesses, and the uniform help/error UX the library provides is lost. This spec pins the declarative style so the invocation surface is single-sourced, testable in-process, and consistent across every subcommand.

## References

- **external** `https://github.com/tj/commander.js` — Commander.js source repository
- **external** `https://github.com/tj/commander.js/blob/master/Readme.md` — Commander.js readme / usage guide
- **external** `https://www.npmjs.com/package/commander` — `commander` npm package
- **external** `https://github.com/tj/commander.js/tree/master/examples` — Commander.js usage examples

## Rules

1. Construct a single top-level `Command` instance as the program root; do not create parallel parsers for the same process.
2. Declare every subcommand with `.command('<name>')` and attach its behavior with `.action(handler)`.
3. Do not parse `process.argv` manually inside an action handler; use the parameters Commander passes to the handler.
4. Declare every positional argument with `.argument('<name>')` (required) or `.argument('[name]')` (optional), and include a description string.
5. Declare every option with `.option('-s, --long <value>', 'description')` and include both short and long forms when a conventional short form exists.
6. Use `.requiredOption()` for options that must be provided; do not add manual "is this undefined?" checks inside action handlers.
7. Pass a parser function as the third argument to `.option()` for any option whose semantic type is not a string (numbers, enums, arrays, custom types).
8. Provide default values via `.option()` / `.argument()` default parameters; do not apply defaults inside action handlers.
9. Set the program version with `.version()` read from `package.json`; do not hardcode the version string in source.
10. Set a description on the program and on every subcommand; do not leave descriptions empty.
11. Extend help content with `.addHelpText('before' | 'after', ...)` when additional guidance is needed.
12. Do not override `.helpInformation()` unless the default layout cannot express a required constraint.
13. Accept action-handler parameters using the positional signature declared by `.argument()` plus the final options object; do not read values from `program.args` when a declared signature is available.
14. Mark any action handler that performs asynchronous work `async`, or return a promise from it explicitly.
15. Invoke the program with `await program.parseAsync(argv)` when any action handler is asynchronous.
16. Do not call `.allowUnknownOption(true)` unless a comment at the call site documents why unknown options must be accepted.
17. Do not call `.allowExcessArguments(true)` unless a comment at the call site documents why excess positional arguments must be accepted.
18. Report user-facing CLI errors with `command.error(message, { exitCode })`; do not call `process.exit()` from inside action handlers.
19. Enable `.showHelpAfterError()` on the program so invocation errors print help automatically.
20. In unit tests, call `program.exitOverride()` and `program.configureOutput({ writeOut, writeErr })` to capture exits and output; do not spawn child processes for tests that exercise only parsing or handler logic.
