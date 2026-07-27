---
name: ste-writing
description: Rewrite prose (docs, READMEs, PR descriptions, error messages, release notes, comments — never code) into ASD-STE100 Simplified Technical English to remove "AI slop". Use when asked to make writing not sound like AI, make docs clear or plain, enforce a controlled writing style, or write technical documentation that reads human. Two modes — strict (procedures/safety) and STE-flavored (general prose).
---

# ste-writing

Write prose = ASD-STE100 Simplified Technical English. Applies to: docs, READMEs, PR text, error msg, release notes, comments. Not for: code, identifiers, command syntax, marketing copy, essays, anything needing voice. STE strips voice on purpose.

This file is agent-facing, so it uses caveman-hyphen style, not STE. Text you output for a human reader must still follow the rules below in full sentences — the rules govern your output, not the wording of this file.

## Rules

WORDS
- 1 name per thing. Never rename same item mid-doc.
- Short word only: start (not begin/commence/initiate) - use (not utilize/leverage) - help (not facilitate) - make sure (not ensure) - before (not prior to) - after (not subsequent to) - about (not regarding/concerning) - get (not obtain/acquire) - show (not demonstrate) - also (not additionally/furthermore/moreover).
- 1 meaning per word. "fall" = move down. Not "decrease."
- No marketing word: seamless, robust, powerful, cutting-edge, effortless, world-class, next-generation, revolutionary.
- American spelling.

VERBS
- Active voice. "the parser reads the file" - not "the file is read by the parser."
- Verb = action, not nominalization. "analyze the log" - not "perform an analysis of the log."
- No stacked auxiliary. "this improves X" - not "it is important to note that this may help to improve X."
- No "-ing" main verb where simple tense works.

SENTENCES
- 1 instruction per sentence. Max 20 words (instruction). Max 25 (descriptive).
- No contraction. Use article: a, an, the, this, these.

PUNCTUATION
- No semicolon. Write 2 sentences instead. (Em dash is allowed by STE — only semicolon is banned. Add your own "no em dash" rule if you want it gone.)

STRUCTURE
- 1 topic per paragraph, max 6 sentences. Steps = numbered vertical list, 1 action per item, imperative form. Condition goes before its command.

Output only the requested text. No preamble, no summary, no closing remark.

## Modes

- strict — procedure, runbook, safety text, error message. Apply every rule, both length caps.
- STE-flavored — general prose (README, PR description, docs). Apply sentence/paragraph/active-voice/no-phrasal-verb discipline. Skip the ~900-word strict dictionary lockdown so text keeps enough range to read naturally.

## Self-lint (run before returning text)

1. Sentence over 20 words? Split it.
2. Semicolon? Replace with a period.
3. Contraction? Expand it.
4. Passive voice with a known actor? Make it active.
5. "-ing" main verb, nominalization ("perform an analysis"), or phrasal verb ("spin up")? Replace with a plain verb.
6. Same thing named 2 ways? Pick 1 name.

The rules above are lintable — they remove slop-form. Full STE also needs human judgment (right technical noun, whether a sentence makes good sense) — a checker cannot certify that, and slop is not about that. This skill fixes the FORM of slop. It cannot make a hollow paragraph true.

Official standard (copyrighted, do not paste in full): https://asd-ste100.org
