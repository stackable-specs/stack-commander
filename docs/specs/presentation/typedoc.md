---
id: typedoc
layer: presentation
extends:
  - typescript
---

# TypeDoc

## Purpose

TypeDoc converts a TypeScript package's exported types and TSDoc comments into navigable HTML reference documentation — but only the parts that are actually documented, with stable links, when the build runs as a quality gate. Left to defaults, it silently skips undocumented symbols, accepts broken `{@link}` references, emits a "next" docs site that drifts past the published package version, and lets internal helpers leak into the public reference because no one tagged them `@internal`. Without `@public` / `@beta` / `@alpha` / `@internal` markers, every consumer treats every export as load-bearing API, so a refactor of an internal helper becomes a "breaking change" by default. Without `@example` blocks and `@throws` documentation, the generated reference is a typed dictionary, not a usage guide. This spec pins TypeDoc's configuration as code, the TSDoc tag set authors must use, the API-stability markers, the validation flags that turn TypeDoc into a CI gate (`invalidLink`, `notExported`, `notDocumented`, `treatValidationWarningsAsErrors`), and the publish flow that ties a docs URL to a released package version, so the generated reference is a reliable contract rather than a snapshot of whatever the source happens to look like today.

## References

- **spec** `typescript` — language-layer TypeScript spec this refines
- **external** `https://typedoc.org/` — TypeDoc home
- **external** `https://typedoc.org/documents/Options.Validation.html` — TypeDoc validation options
- **external** `https://tsdoc.org/` — TSDoc specification
- **external** `https://api-extractor.com/pages/tsdoc/syntax/` — TSDoc tag reference
- **external** `https://github.com/microsoft/tsdoc/tree/main/eslint-plugin` — `eslint-plugin-tsdoc`
- **external** `https://semver.org/` — Semantic Versioning 2.0.0 (deprecation lifecycle context)

## Rules

1. Use TypeDoc as the canonical API reference generator for every published TypeScript package; do not hand-maintain a parallel API reference that duplicates source comments.
2. Pin the TypeDoc version as an exact `devDependency` (no `^` or `~`) and upgrade deliberately via a dedicated PR. (refs: typescript)
3. Configure TypeDoc declaratively in `typedoc.json` (or the `typedoc` field in `package.json`); do not pass long CLI flag lists from `package.json` scripts.
4. Set `entryPoints` (or `entryPointStrategy: "packages"` for monorepos) explicitly; do not rely on auto-discovery for what to document.
5. Write the generated output to a build directory listed in `.gitignore` (e.g. `docs-site/api/`); do not commit generated HTML to source control.
6. Author doc comments using TSDoc tags (`@param`, `@returns`, `@throws`, `@example`, `@remarks`, `@deprecated`, `@see`); do not use JSDoc-only tags whose semantics differ in TypeScript (`@type`, `@typedef`, `@property`).
7. Mark every symbol exported from the package's main entry point with an API-stability tag — `@public`, `@beta`, `@alpha`, or `@internal`; do not ship an unmarked export.
8. Document every exported function and method with `@param <name> - <description>` for each parameter and `@returns <description>` for the return; do not leave a public function with no doc comment.
9. Provide at least one `@example` block on every exported function, class, and standalone type a consumer would call directly.
10. Document thrown errors with `@throws {<ErrorType>} <when>` for every exception a public function may raise.
11. Mark deprecated symbols with `@deprecated <since version> - <replacement>` for at least one minor-release cycle before removal; do not delete a public symbol without first publishing it as `@deprecated`.
12. Reference other symbols with `{@link SymbolName}` (or `{@link package#Symbol}`); do not use bare backticked names for cross-references that should resolve to a doc page.
13. Enable `validation.invalidLink: true`, `validation.notExported: true`, and `validation.notDocumented: true` in the TypeDoc config.
14. Set `treatValidationWarningsAsErrors: true` (or `treatWarningsAsErrors: true`) so TypeDoc validation failures fail the build.
15. List documented exceptions in `intentionallyNotExported` and `intentionallyNotDocumented`; do not silence warnings by lowering the `requiredToBeDocumented` set or by removing validation flags.
16. Run TypeDoc in CI on every PR (e.g. `typedoc --emit none`) so doc-comment warnings block merges, separately from the doc-publish step.
17. Lint TSDoc syntax with `eslint-plugin-tsdoc`; do not commit malformed TSDoc that parses differently across tools.
18. Assign symbols to documented categories with `@category <Name>` and enable `categorizeByGroup` so navigation reflects the package's mental model; do not rely on alphabetical-only listing for packages with more than a handful of exports.
19. Pin the TypeDoc theme (and any plugins) as exact `devDependency` versions and reference them via the `theme` / `plugin` options; do not let the upstream default theme version change implicitly between builds.
20. Publish the generated HTML to a stable URL (GitHub Pages, Vercel, S3 + CloudFront, or equivalent) on every release tag, with the URL path including the released package version; do not maintain a single "latest" docs site that drifts from the version a consumer actually installed.
