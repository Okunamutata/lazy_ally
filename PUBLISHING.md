# Publishing lazy_ally (maintainers only)

This does not apply to most contributors. See [CONTRIBUTING.md](CONTRIBUTING.md) for that. This is
the release checklist for whoever owns pub.dev publish rights. See the [`Makefile`](Makefile) (`make
help`) for the commands referenced below.

## One-time setup, before the first publish

- [ ] **Make the GitHub repo public.** `homepage`/`repository`/`issue_tracker` in `pubspec.yaml` all
      point at `github.com/okunamutata/lazy_ally`. pub.dev links to them directly on the package page,
      and pana (pub.dev's scoring tool) checks that they resolve. A private repo makes those links
      404 for every visitor. Push everything, confirm CI is green on `main`, then flip repo visibility
      to public.
- [ ] **Re-check that the package name is still unclaimed.** `lazy_ally` was free as of 2026-07-24.
      Names can be claimed by anyone at any time before you actually publish. Check
      [pub.dev/packages/lazy_ally](https://pub.dev/packages/lazy_ally) immediately before the
      "Publish" step below. If it 404s, you are still clear.
- [ ] **Run `flutter pub login`** (or `dart pub login`). This opens a browser for Google OAuth. Run
      this step yourself, interactively. It cannot be scripted or delegated.
- [ ] **(Optional, recommended) Register a verified publisher** for `lazyfruit.dev` at
      [pub.dev/publishers](https://pub.dev/publishers). This proves domain ownership (DNS TXT record
      or Google Search Console), adds a verified checkmark next to the package on pub.dev, and lets
      you publish future packages under the same identity. It is not required to publish, but it is
      worth doing once, before the first release, since packages cannot move to a publisher after the
      fact as smoothly as being published under one from the start.

## Every release

- [ ] **Update `CHANGELOG.md`.** Once a version is actually published (not just `-dev`), give each
      subsequent release its own dated section. Do not keep folding everything into one
      `0.1.0-dev.1` entry the way pre-publish development did.
- [ ] **Bump `version:` in `pubspec.yaml`**, following semver. For the very first publish, choose
      between:
  - **Publish as a pre-release** (for example `0.1.0-dev.1`, what is currently set). This signals
    "usable, but expect breaking changes." Consumers will not pick it up through a plain `^0.1.0`
    constraint unless they explicitly opt into pre-releases. This is lower-stakes for a first publish.
  - **Publish as `0.1.0`.** This signals "ready to depend on normally." Only do this once you are
    comfortable with the public API as committed.
- [ ] **Run `make check`.** This formats, analyzes, and tests both the package and the example, then
      runs `flutter pub publish --dry-run`. Read every line of the dry-run output, not just the exit
      code. It has caught real issues before: a deleted-but-still-git-staged stray file, and a
      `build/` cache directory that slipped past `.gitignore` once `.pubignore` existed. Both would
      have been silently included in the archive otherwise.
- [ ] **Check `git status`.** Publishing from a dirty working tree works, but the dry-run warns about
      it, and it makes the published archive harder to reason about later. Commit or stash first.
- [ ] **Publish with `make publish`.** This runs `check` first, so a failing test, a formatting diff,
      or a dry-run warning stops this before anything public happens, then runs the real
      `flutter pub publish`. Its own `y/N` confirmation prompt is the last checkpoint.
      **Publishing is effectively irreversible.** You can *retract* a version (hide it, not delete it)
      within 7 days using `dart pub retract`, but nothing after that. Anyone who already resolved it
      keeps a working copy. Take the dry-run output seriously *before* this step, not after.
- [ ] **Tag the release in git**, matching the published version:
      ```sh
      git tag v0.1.0 && git push origin v0.1.0
      ```
      Then create a GitHub Release from that tag, pasting in the matching `CHANGELOG.md` section.

## After publishing

- [ ] **Check the rendered pub.dev page**: README formatting, banner image, badges, and the pub score
      once pana finishes analyzing (this runs asynchronously and can take a few minutes to an hour).
      Fix anything that renders wrong and republish as a patch version. The banner and badges are
      exactly the kind of thing that can look fine on GitHub and subtly break on pub.dev's stricter
      markdown/HTML sanitizer, so look at the live page. Do not assume.
- [ ] **`topics:` in `pubspec.yaml` must come from pub.dev's approved topic list** (max 5). Arbitrary
      strings are silently ignored, not an error. Re-check that the current list still fits before
      adding more (for example, reduce-motion/i18n-related ones) as the package grows.
- [ ] **Respond to pub score suggestions** that pana surfaces (documentation coverage, platform
      support declarations, and others). These directly affect discoverability, not just vanity
      metrics.
- [ ] **Consider a GitHub repo description and social preview image** matching `doc/banner.png`, and
      branch protection or required CI status checks on `main` now that the repo is public.
