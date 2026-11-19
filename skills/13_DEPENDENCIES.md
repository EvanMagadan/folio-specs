# 13 — Dependencies

**Purpose:** Track why dependencies are selected and what upgrades can break.

**Confidence note:** no manifests or dependency declarations exist as of 2026-11-19.

The only specified external integration is Google Sign-In. Its client SDKs, server verification library, versions, and upgrade policy are not chosen. Record each dependency's version, purpose, security posture, and rejected alternatives when implementation begins. Miss → an untracked authentication SDK upgrade can break login or identity verification.
