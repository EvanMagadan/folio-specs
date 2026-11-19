# 09 — Security

**Purpose:** Make privacy and authorization requirements actionable.

**Confidence note:** verified against the security layer requirement in `business-logic-v1.0.md` on 2026-11-19; controls are not implemented.

## Threat model baseline

Protect authenticated accounts, location data, retained records, and aggregate outputs from unauthorized access, inference, excessive retention, and resale without consent.

## Required controls

1. Validate Google identity at the API boundary.
2. Authorize by role on every protected operation.
3. Minimize and expire retained data.
4. Suppress aggregates below the approved threshold.
5. Do not create per-user trails unless a future approved requirement explicitly changes this rule.
6. Require consent before any data resale.
7. Keep secrets in environment/configuration management; never in source.

Miss → client-only enforcement, unrestricted location data, or raw small-group reports can violate the stated privacy baseline.
