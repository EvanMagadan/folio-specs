# 04 — Change Rules

**Purpose:** Protect cross-repository contracts and privacy invariants during change.

**Confidence note:** derived from the product specification on 2026-11-19; no implementation lockstep sets are present.

## Known lockstep set

1. **Platforms and contracts:** `folio-web`, `folio-android`, `folio-api`, and the corresponding specification documents.
   - Change together when an API shape, authentication flow, role, or privacy rule changes.
   - Miss → one client can accept a contract that the other client or API rejects.
   - Retest → Google Sign-In, authorization by role, privacy filtering, and aggregation behavior on both clients.

2. **User levels and access table:** the role table and MVP access table in `business-logic-v1.0.md`.
   - Miss → a role can gain or lose access silently.
   - Retest → every feature against A–E, including unauthenticated Guest behavior.

3. **Privacy controls:** location protection, retention, per-user trail prohibition, aggregation thresholds, and resale consent.
   - Miss → a feature can violate the stated privacy baseline even when functional tests pass.

No constants, enums, registries, columns, or error codes are implemented yet.
