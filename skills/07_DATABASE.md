# 07 — Database

**Purpose:** Define the evidence boundary for persistence decisions.

**Confidence note:** no schema, migration, database provider, tables, or indexes exist as of 2026-11-19.

## Required design invariants

- Store only data required by approved requirements; retention limits must be enforceable, not aspirational.
- Protect location data and avoid per-user trails as required by the business logic.
- Aggregation thresholds must prevent reporting on too-small groups.
- Any resale path requires recorded consent.

## Unverified

Identity keys, foreign keys, delete behavior, migrations, indexes, and backup commands are unknown. Miss → guessing these details can make deletion, retention, or privacy guarantees impossible to enforce.
