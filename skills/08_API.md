# 08 — API

**Purpose:** Capture the API contract requirements before routes are implemented.

**Confidence note:** `folio-api` contains no routes, validators, response envelope, or versioning as of 2026-11-19.

## Required contract concerns

- Authenticate through the approved Google Sign-In integration.
- Authorize every feature using the user levels and MVP access table.
- Preserve Guest access only where the table permits it.
- Enforce privacy requirements server-side; clients are not a trust boundary.

## Adding an endpoint

First update the specification, role/access matrix, privacy analysis, and shared contract; then implement the API and both clients together. Miss → a client-only permission check can be bypassed by direct API calls.

Route inventory and error codes are pending implementation.
