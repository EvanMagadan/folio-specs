# 14 — Developer Workflows

**Purpose:** Provide safe recipes while the repositories are being bootstrapped.

**Confidence note:** verified against repository contents on 2026-11-19; no build workflow exists.

## Before implementing a feature

1. Fill the placeholder requirement and define its acceptance behavior.
2. Update role access and privacy impact.
3. Update the API contract and both clients together.
4. Add tests for Guest and all applicable roles.
5. Run repository-native checks and review the lockstep set in 04.

Miss → implementing against `...` placeholders creates an untestable feature and later contract drift.

## Before release

Follow the branch gates in 10 and the tag rules in `folio-specs/git-guidelines.md`.

After each workflow, add what surprised you to `INBOX.md`.
