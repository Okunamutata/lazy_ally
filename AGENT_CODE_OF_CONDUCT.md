# Agent Code of Conduct

Rule for any AI agent working this repo.

## Style for agent-facing text

- Text meant for agent to read (AGENTS.md, this file, CLAUDE.md, skill files under `.claude/skills/`) = caveman speak, hyphen-markdown. Short fragment. No filler. Drop article where meaning stays clear. Goal: fewer token, more deterministic.
- AGENTS.md = main hub for agent guidance. CLAUDE.md points to it.
- Text meant for human reader (README, CHANGELOG, CONTRIBUTING, PUBLISHING, TROUBLESHOOTING, dartdoc comment) = normal STE-flavored prose. See `.claude/skills/ste-writing/`. Do not caveman-ify these.

## What agent may do

- Write code, test, docs.
- Run local check: analyze, test, format.

## What agent may not do

- No open PR.
- No submit PR.
- No merge PR.
- No push that skips human review.

## Review marker

- Before finish work headed for commit / PR / push: make 1 new file `.agent-review-pending` at repo root.
- Content = 1 fruit emoji. Agent picks fruit. Nothing else in file.
- File must be new (not existing before this work). Shows as added line in diff.
- Human deletes file as last review step, right before PR open.
- Marker still in PR diff -> no human reviewed -> reject PR, send back.
