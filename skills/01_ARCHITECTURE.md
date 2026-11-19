# 01 — Architecture

**Purpose:** Establish the intended system boundary before implementation begins.

**Confidence note:** inferred from `folio-specs/business-logic-v1.0.md` on 2026-11-19; no implementation exists to confirm it.

## Model

Folio is intended to provide Web and Android clients backed by an API and a database. Google Sign-In is the stated authentication integration. The specification requires security and privacy by design, including Data Privacy Act compliance, location protection, retention limits, no per-user trails, aggregation thresholds, and consent for data resale.

## Ownership and flow

| Component | Intended ownership | Verified entry point |
|---|---|---|
| `folio-web` | Web client | None exists |
| `folio-android` | Android client | None exists |
| `folio-api` | API/database boundary | None exists |
| `folio-specs` | Product and engineering specifications | `business-logic-v1.0.md` |

Expected flow: client → Google authentication → API authorization → persisted data → aggregated/reporting views. The API, schema, and authorization boundaries must be designed before implementation.

## Decision record

### Decision: Support Web and Android clients (2026-11-19, project baseline)
**Status:** accepted by the current specification.
**Context / Choice / Alternatives / Consequences:** The business logic names Web and Android as allowed platforms; supporting both creates two clients that must share contracts and privacy behavior.

## Debt register

1. No implementation baseline exists, so architecture cannot yet be validated.
2. Requirements 2–7 are placeholders; building against them would create rework.
3. Roles C and D have no descriptions; authorization policy is incomplete.
