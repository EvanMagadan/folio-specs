# 02 — Project Structure

**Purpose:** Explain where implementation and specification work belongs.

**Confidence note:** verified against repository directories and `business-logic-v1.0.md` on 2026-11-19.

## Current tree

```text
folio-api/       API repository; currently only AGENTS.md
folio-android/   Android repository; currently only AGENTS.md
folio-web/       Web repository; currently only AGENTS.md
folio-specs/     Specifications; business logic, sense-making, git rules
```

Put API code in `folio-api`, Android code in `folio-android`, web code in `folio-web`, and cross-client contracts or product decisions in `folio-specs`. Put this knowledge base in `folio-specs/skills/`.

Miss → placing client behavior in the API or duplicating a contract in one client causes drift. No naming conventions are verified yet; record them when source is introduced.
