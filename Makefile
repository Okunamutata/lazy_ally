.DEFAULT_GOAL := help

.PHONY: help get format format-check analyze test test-package test-example check example dry-run publish clean

help:
	@echo "lazy_ally maintainer commands:"
	@echo ""
	@echo "  make get            Install dependencies (package + example)"
	@echo "  make format         Apply dart format to package + example"
	@echo "  make format-check   Check formatting without modifying files (CI mode)"
	@echo "  make analyze        flutter analyze --fatal-infos (package + example)"
	@echo "  make test-package   Run the package's controller tests only"
	@echo "  make test-example   Run the example's widget tests only"
	@echo "  make test           Run all tests (package + example)"
	@echo "  make check          Full verification: get + format-check + analyze + test + dry-run"
	@echo "  make example        Run the example app (flutter run)"
	@echo "  make dry-run        flutter pub publish --dry-run"
	@echo "  make publish        Run 'check' first, then the real 'flutter pub publish'"
	@echo "  make clean          flutter clean (package + example)"

get:
	flutter pub get
	cd example && flutter pub get

format:
	dart format .

format-check:
	dart format --output=none --set-exit-if-changed .

analyze:
	flutter analyze --fatal-infos
	cd example && flutter analyze --fatal-infos

test-package:
	flutter test

test-example:
	cd example && flutter test

test: test-package test-example

dry-run:
	flutter pub publish --dry-run

# Everything CI runs, plus the example's own tests and a publish dry-run.
# Run this before opening a PR, and before every release.
check: get format-check analyze test dry-run

example:
	cd example && flutter run

# Only reaches the real publish if `check` passes — a failing test, a
# formatting diff, or a dry-run warning stops this before anything public
# happens.
publish: check
	flutter pub publish

clean:
	flutter clean
	cd example && flutter clean
