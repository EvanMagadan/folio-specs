# 03 — Code Style

**Purpose:** Record coding conventions once implementation exists.

**Confidence note:** no source, formatter, linter, logger, or test command exists in the repositories as of 2026-11-19.

## Current rules

- Follow the local `AGENTS.md` in each repository.
- Explain non-obvious guards with the failure they prevent; otherwise future maintainers may remove a necessary privacy or compatibility check.
- Never commit secrets; name environment variables, never their values.
- Use the required commit format from `folio-specs/git-guidelines.md`: `scope: Imperative summary`, with a 50-character summary limit.

## Unverified

Language naming, formatting, error envelopes, logging fields, and banned patterns cannot be specified honestly until code and tooling exist. Miss → invented conventions will conflict with the first real framework choice.
