# 10 — Deployment

**Purpose:** Record the release gates and current deployment gap.

**Confidence note:** verified against `folio-specs/git-guidelines.md` on 2026-11-19; no build or deployment pipeline exists.

## Required order

Develop on `main`, promote to `beta` after review, promote to `release` only after QA/system testing, publish the release bundle for independent integration testing, then deploy only the exact approved release candidate.

The product prefixes are WCN (web), BCN (API), ACN (Android), and SCN (specifications). The first tags are WCN.01.0.001, BCN.01.0.001, ACN.01.0.001, and SCN.01.0.001.

## Current gap

No commits, build artifacts, CI, hosting, or release tags exist. Miss → claiming a deployment is complete would bypass the controlled promotion gates.
