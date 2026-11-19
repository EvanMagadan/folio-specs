# 05 — Debugging Playbook

**Purpose:** Starting point for diagnosis before application logs exist.

**Confidence note:** no runtime, logs, routes, or exact error messages exist as of 2026-11-19.

## First checks

1. Confirm the failing repository and read its `AGENTS.md`.
2. Compare the behavior with `business-logic-v1.0.md`, especially the role/access and privacy rules.
3. Check the API/client contract in `folio-specs`; no generated contract exists yet.
4. Reproduce with Guest and each authenticated role before changing authorization.

## Known symptoms

No exact runtime symptoms are verified. Do not invent log messages. Miss → searching for a guessed message sends diagnosis to the wrong layer.

## Useful commands

`git -C <repo> status`, `git -C <repo> log --oneline`, and repository-native test commands once they are added. Current repositories have no commits or test commands.
