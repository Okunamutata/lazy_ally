# Contributing to lazy_ally

Thanks for considering it. This is a small project, but accessibility is a big deal, and your help is
welcome.

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

All three commands must run clean. If you change behavior, add or update a test in
`test/lazy_ally_controller_test.dart` (controller-level) or `example/test/` (widget-level). This
project's whole premise is accessibility correctness, so untested behavior changes are hard to trust.

If you add content to `HomePage` in `example/lib/main.dart` and a widget test needs to reach it, note
that `find.byType`/`find.text` default to `skipOffstage: true`, and `RenderSliverList` only mounts
elements within reach of the viewport plus cache extent. For a target genuinely below the fold, use
`tester.scrollUntilVisible(finder, delta)`, which tolerates a not-yet-built target, rather than
`tester.ensureVisible`, which needs the target already mounted to measure where to scroll to.

## Scope guardrails

A few decisions are settled and worth knowing before you propose changes that cut against them. See
the design-decisions section in the README for the reasoning:

- No `MaterialApp` replacement, no bundled custom font.
- `light`/`dark` are plain `ThemeData`, not a custom theme type. There is no built-in "extra dark"
  mode either. Variants like that go through the `customThemes` registry instead.
- No third-party dependencies, no platform channels, no native code. This is a pure Dart package.

Proposals that revisit these are still welcome as issues or discussions. Just flag that this is what
you are doing, since it is a bigger conversation than a typical PR.

## Reporting issues

Open a [GitHub issue](https://github.com/okunamutata/lazy_ally/issues) with a minimal repro if
possible. For accessibility-specific bugs, such as a color combination that fails contrast or a
missing semantics announcement, say which assistive technology or setting surfaced it. That context is
genuinely useful and easy to lose otherwise. General questions are also welcome through
[lazyfruit.dev](https://lazyfruit.dev) or lazy.ally.reprise769@passmail.net.

## Publishing (maintainers)

See [PUBLISHING.md](PUBLISHING.md) for the release checklist. This does not apply to most
contributors.

## Code of conduct

This project follows [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## AI agents

An AI agent working in this repository follows [AGENT_CODE_OF_CONDUCT.md](AGENT_CODE_OF_CONDUCT.md).
An agent may write code, tests, and docs, but must not open, submit, or merge a PR itself.
