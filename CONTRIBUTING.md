# Contributing to lazy_ally

Thanks for considering it — this is the maintainer's first published package, so process is
intentionally light-weight.

## Getting set up

```sh
git clone https://github.com/okunamutata/lazy_ally.git
cd lazy_ally
flutter pub get
cd example && flutter pub get && cd ..
```

## Before opening a PR

```sh
flutter analyze
flutter test
cd example && flutter analyze && flutter test && cd ..
```

All three should be clean. If you're changing behavior, add or update a test in
`test/lazy_ally_controller_test.dart` (or the relevant widget test once those exist) — this project's
whole premise is accessibility correctness, so untested behavior changes are hard to trust.

## Scope guardrails

A few decisions are settled and worth knowing before proposing changes that cut against them (see the
design-decisions section in the README for the reasoning):

- Color-blind support is an **orthogonal flag**, not a fourth brightness mode.
- No `MaterialApp` replacement, no bundled custom font — this is a deliberate contrast with other
  packages in the space, not an oversight.
- `light` / `dark` / `extraDark` are plain `ThemeData`, not a custom theme type.

Proposals that revisit these are still welcome as issues/discussion — just flag that's what you're
doing, since it's a bigger conversation than a typical PR.

## Reporting issues

Open a GitHub issue with a minimal repro if possible. For accessibility-specific bugs (a color
combination that fails contrast, a missing semantics announcement, etc.), please say which assistive
technology or setting surfaced it — that context is genuinely useful and easy to lose otherwise.

## Code of conduct

This project follows [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
