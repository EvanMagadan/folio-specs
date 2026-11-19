# 00 — Index

**Purpose:** Reading order and maintenance guide for the Folio engineering knowledge base.

**Confidence note:** verified against the four repository working trees on 2026-11-19. The code wins (see 16).

## Reading order

| Task | Read |
|---|---|
| Understand the product | 01, 02, 07, 08 |
| Change code | 03, 04, 11 |
| Diagnose a failure | 05, 06, 09 |
| Ship a release | 10, 11, 15 |
| Assess risk or a dependency | 09, 12, 13, 15 |

## Documents

All documents were created or verified on 2026-11-19. The implementation repositories currently contain no source code, configuration, tests, migrations, or commits, so implementation-specific sections are explicitly unverified.

00_INDEX, INBOX, 01_ARCHITECTURE, 02_PROJECT_STRUCTURE, 03_CODE_STYLE, 04_CHANGE_RULES, 05_DEBUGGING_PLAYBOOK, 06_FAILURE_STORIES, 07_DATABASE, 08_API, 09_SECURITY, 10_DEPLOYMENT, 11_TESTING, 12_PERFORMANCE, 13_DEPENDENCIES, 14_DEVELOPER_WORKFLOWS, 15_KNOWN_LIMITATIONS, 16_ENGINEERING_PRINCIPLES.

## Contributions

Add rough discoveries to `INBOX.md`; include evidence and what breaks without the knowledge. Verify entries against code before promoting them. Retire stale knowledge instead of deleting it. Append to the changelog below; do not renumber documents.

## Changelog

- 2026-11-19 — Created the initial baseline from `folio-specs/business-logic-v1.0.md`, repository instructions, and empty repository inventories.
