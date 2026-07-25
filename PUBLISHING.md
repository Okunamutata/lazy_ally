# Publishing lazy_ally (maintainers only)

Not relevant to most contributors — see [CONTRIBUTING.md](CONTRIBUTING.md) for that. This is the
release checklist for whoever owns pub.dev publish rights. See the [`Makefile`](Makefile) (`make
help`) for the commands referenced below.

## One-time setup, before the first publish

- [ ] **Make the GitHub repo public.** `homepage`/`repository`/`issue_tracker` in `pubspec.yaml` all
      point at `github.com/okunamutata/lazy_ally` — pub.dev links to them directly on the package
      page, and pana (pub.dev's scoring tool) checks that they resolve. A private repo makes those
      links 404 for every visitor. Push everything, confirm CI is green on `main`, then flip repo
      visibility to public.
- [ ] **Re-check the package name is still unclaimed.** `lazy_ally` was free as of 2026-07-24; names
      can be claimed by anyone at any time before you actually publish. Check
      [pub.dev/packages/lazy_ally](https://pub.dev/packages/lazy_ally) immediately before the "Publish"
      step below — if it 404s, you're still clear.
- [ ] **`flutter pub login`** (or `dart pub login`) — opens a browser for Google OAuth. Run this
      yourself interactively; it can't be scripted or delegated.
- [ ] **(Optional, recommended) Register a verified publisher** for `lazyfruit.dev` at
      [pub.dev/publishers](https://pub.dev/publishers) — proves domain ownership (DNS TXT record or
      Google Search Console), adds a verified checkmark next to the package on pub.dev, and lets you
      publish future packages under the same identity. Not required to publish, but worth doing once,
      before the first release, since packages can't be retroactively moved to a publisher as smoothly
      as being published under one from the start.

## Every release

- [ ] **Update `CHANGELOG.md`.** Once a version is actually published (not just `-dev`), give each
      subsequent release its own dated section — don't keep folding everything into one
      `0.1.0-dev.1` entry the way pre-publish development did.
- [ ] **Bump `version:` in `pubspec.yaml`**, following semver. For the very first publish, decide
      between:
  - **Publish as a pre-release** (e.g. `0.1.0-dev.1`, what's currently set) — signals "usable, but
    expect breaking changes," and consumers won't pick it up via a plain `^0.1.0` constraint unless
    they explicitly opt into pre-releases. Lower-stakes for a first publish.
  - **Publish as `0.1.0`** — signals "ready to depend on normally." Only do this once you're
    comfortable with the public API as committed.
- [ ] **Run `make check`.** Formats, analyzes, and tests both the package and the example, then runs
      `flutter pub publish --dry-run`. Read every line of the dry-run output, not just the exit code —
      it has caught real issues before (a deleted-but-still-git-staged stray file, and a `build/`
      cache directory that slipped past `.gitignore` once `.pubignore` existed — both would've been
      silently included in the archive otherwise).
- [ ] **Check `git status`.** Publishing from a dirty working tree works, but the dry-run will warn
      about it, and it makes the published archive harder to reason about later. Commit or stash
      first.
- [ ] **Publish: `make publish`.** Runs `check` first — a failing test, a formatting diff, or a
      dry-run warning stops this before anything public happens — then runs the real
      `flutter pub publish`. Its own `y/N` confirmation prompt is the last checkpoint.
      **Publishing is effectively irreversible.** A version can be *retracted* (hidden, not deleted)
      within 7 days via `dart pub retract`, but nothing after that; anyone who already resolved it
      keeps a working copy. Take the dry-run output seriously *before* this step, not after.
- [ ] **Tag the release in git**, matching the published version:
      ```sh
      git tag v0.1.0 && git push origin v0.1.0
      ```
      Then create a GitHub Release from that tag, pasting in the matching `CHANGELOG.md` section.

## After publishing

- [ ] **Check the rendered pub.dev page** (README formatting, banner image, badges, the pub score
      once pana finishes analyzing — this runs asynchronously and can take a few minutes to an hour).
      Fix anything that renders wrong and republish as a patch version; the banner and badges are
      exactly the kind of thing that can look fine on GitHub and subtly break on pub.dev's stricter
      markdown/HTML sanitizer, so actually look at the live page, don't assume.
- [ ] **`topics:` in `pubspec.yaml` must come from pub.dev's approved topic list** (max 5) —
      arbitrary strings are silently ignored, not an error. Re-check the current list still fits
      before adding more (e.g. reduce-motion/i18n-related ones) as the package grows.
- [ ] **Respond to pub score suggestions** pana surfaces (documentation coverage, platform support
      declarations, etc.) — these directly affect discoverability, not just vanity metrics.
- [ ] **Consider a GitHub repo description + social preview image** matching `doc/banner.png`, and
      branch protection / required CI status checks on `main` now that the repo is public.
