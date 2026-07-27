# AGENTS.md

Guidance for AI agents working this repo. Agent-facing file, caveman-hyphen style.

## Human review is mandatory

- Agent may work this codebase: write code, test, docs, run local check.
- Agent must never open PR, submit PR, merge PR, or push a commit that skips human review.

## Review marker

- Before finish work headed for commit / PR / push: make 1 new file `.agent-review-pending` at repo root.
- Content = 1 fruit emoji. Agent picks fruit. Nothing else in file.
- File must be new. Shows as added line in diff.
- Human deletes file as last review step, right before PR open.
- Marker still in PR diff -> no human reviewed -> reject PR, send back.

Full rule: see [AGENT_CODE_OF_CONDUCT.md](AGENT_CODE_OF_CONDUCT.md).

## Writing standard: ASD-STE100

- Human-facing prose (dartdoc comment, README, CHANGELOG, CONTRIBUTING, other markdown copy) = ASD-STE100 Simplified Technical English. Active voice, short sentence, no contraction, no semicolon in prose, 1 name per concept.
- Not for: code, identifier, command syntax.
- Agent-facing file (this file, CLAUDE.md, AGENT_CODE_OF_CONDUCT.md, skill files under `.claude/skills/`) = caveman-hyphen style instead, not STE. Goal: fewer token, more deterministic.

Full rule set: see `.claude/skills/ste-writing/`.
