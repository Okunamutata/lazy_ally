# Contributing to lazy_ally

Thanks for considering it, this is a small project, but accessibility is a big deal, and your help is welcome.

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
`test/lazy_ally_controller_test.dart` (controller-level) or `example/test/` (widget-level) — this
project's whole premise is accessibility correctness, so untested behavior changes are hard to trust.

If you're adding content to `example/lib/main.dart`'s `HomePage` and a widget test needs to reach it:
`find.byType`/`find.text` default to `skipOffstage: true`, and `RenderSliverList` only mounts elements
within reach of the viewport + cache extent — for a target genuinely below the fold, use
`tester.scrollUntilVisible(finder, delta)` (which tolerates a not-yet-built target) rather than
`tester.ensureVisible` (which needs it already mounted to measure where to scroll to).

## Scope guardrails

A few decisions are settled and worth knowing before proposing changes that cut against them (see the
design-decisions section in the README for the reasoning):

- No `MaterialApp` replacement, no bundled custom font.
- `light`/`dark` are plain `ThemeData`, not a custom theme type. There's no bespoke "extra dark" mode
  either — variants like that go through the `customThemes` registry instead.
- No 3rd-party dependencies, no platform channels, no native code. This is a pure Dart package.

Proposals that revisit these are still welcome as issues/discussion — just flag that's what you're
doing, since it's a bigger conversation than a typical PR.

## Reporting issues

Open a [GitHub issue](https://github.com/okunamutata/lazy_ally/issues) with a minimal repro if
possible. For accessibility-specific bugs (a color combination that fails contrast, a missing
semantics announcement, etc.), please say which assistive technology or setting surfaced it — that
context is genuinely useful and easy to lose otherwise. General questions are also welcome via
[lazyfruit.dev](https://lazyfruit.dev) or lazy.ally.reprise769@passmail.net.

## Publishing (maintainers)

See [PUBLISHING.md](PUBLISHING.md) for the release checklist. Not relevant to most contributors.

## Code of conduct

This project follows [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
