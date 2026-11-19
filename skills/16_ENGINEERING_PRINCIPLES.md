# 16 — Engineering Principles

**Purpose:** State the rules that should survive implementation changes.

**Confidence note:** principles are grounded in the current specification, not production evidence, on 2026-11-19.

1. **Enforce privacy at the API boundary.** Clients can be bypassed; server-side authorization and filtering are the last control before data leaves the system. (See 08, 09.)
2. **Treat roles and access as one lockstep set.** A role definition without matching feature access creates accidental privilege or denial. (See 04.)
3. **Do not build placeholder requirements.** `...` has no acceptance meaning; implementing it creates rework and untestable behavior. (See 01, 15.)
4. **Publish only tested release bundles.** Independent testers need reproducible artifacts; testing branch code directly makes results non-repeatable. (See 10, 11.)
5. **Trust evidence over assumption.** Empty repositories cannot justify route, schema, dependency, or performance claims; invented documentation causes wrong implementation. (See 00, 05.)

trust the code over any document, including this one
