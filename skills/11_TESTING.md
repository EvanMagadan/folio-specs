# 11 — Testing

**Purpose:** Define the confidence model before tests are written.

**Confidence note:** no test framework, test files, or build commands exist as of 2026-11-19.

## Minimum test dimensions

- Google Sign-In success, rejection, expiry, and account mismatch.
- Every MVP feature against roles A–E and Guest.
- API authorization independent of client controls.
- Location protection, retention expiry, aggregation thresholds, no per-user trails, and resale consent.
- Web and Android behavior against the same API contract.

Unit tests belong on `main`; system testing gates `beta`; independent integration testing uses only published `release` bundles. Miss → testing unreleased code makes the result non-reproducible.
