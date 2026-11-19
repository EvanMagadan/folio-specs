# Folio Business Logic v1.1 — Proposed MVP Baseline

**Status:** Proposed for review

**Purpose:** Complete the minimum product decisions needed to build and validate Folio's first release. This proposal keeps the MVP centered on discovering, offering, requesting, and safely coordinating pre-loved book exchanges.

## 1. Product positioning

Folio is a privacy-first nationwide community marketplace for giving books a second life. It helps book enthusiasts throughout the Philippines discover books, offer books they no longer need, and coordinate a swap or donation without exposing exact addresses or requiring location tracking.

**Core promise:** Find a book anywhere in the Philippines, make a clear request, and arrange a safe handoff with only the information needed to complete it.

**Primary users:** book enthusiasts with books to share and readers looking for affordable or free books across Philippine regions, provinces, cities, municipalities, campuses, and community areas.

**MVP proof:** a new contributor can discover a suitable book anywhere in the Philippines, request it, communicate with the owner, and complete or close the exchange without needing an exact location or an external messaging channel.

## 2. Project details

| Field | Proposed value |
| --- | --- |
| Company / team | Veltrix |
| Code name | Folio |
| Short code | FL |
| Coverage | Nationwide throughout the Philippines |
| Allowed platforms | Web first; Android-compatible API and responsive experience as a release constraint |
| Product type | Community book sharing, swapping, and donation platform |

The first build should not require platform-specific features that prevent the same MVP flow from working on Web and Android.

## 3. User levels and boundaries

| Level | Role in MVP | Allowed actions |
| --- | --- | --- |
| A. System Administrator | Operates the system | Manage security/configuration, backups, access, and emergency moderation controls |
| B. Administrator | Runs the community | Review aggregate reports, manage community settings, and support moderation operations |
| C. Moderator | Keeps the community safe | Review reports, hide/remove violating content, restrict accounts, and record moderation decisions |
| D. Contributor | Shares and requests books | Manage own listings, browse, request, message, block, report, and close own exchanges |
| E. Guest | Evaluates the service | Browse approved public listings and generalized locations; cannot request, message, or publish |

**Boundary:** Administrator and Moderator are operational roles, not trusted owners of private conversations. Access to message content must be limited to a documented safety workflow and only where legally and operationally justified.

## 4. MVP requirements

### R1. Authentication and account

The system shall support Google Sign-In, create a contributor profile with the minimum required information, allow sign-out, and allow a contributor to request account deletion.

**Acceptance:** unauthenticated users cannot create requests or send messages; a deleted account no longer appears as an active contributor or listing owner, subject to documented legal retention.

### R2. Listing creation

A contributor shall create, edit, archive, and delete a listing with:

- title and author;
- genre or category;
- condition selected from a controlled list;
- short description;
- one cover/photo image;
- offer type: `swap`, `donation`, or `swap or donation`;
- manually selected generalized location; and
- availability state.

Required fields must be validated before publication. Exact addresses, phone numbers, live GPS, and continuous location collection are not listing requirements.

### R3. Discovery

Guests and contributors shall browse approved available listings and search or filter by title, author, genre, condition, offer type, region, province, city/municipality, and optional campus or community area.

Users shall be able to discover listings throughout the Philippines. Location filters shall use the listing owner's manually selected generalized location; they shall not depend on GPS, exact distance, maps, or live location.

The initial search may be simple text and exact category filters. Relevance ranking, personalized recommendations, distance calculations, and map views are out of scope.

### R4. Listing and request lifecycles

A contributor shall request an `available` listing by selecting `swap` or `donation` where the owner permits it and adding an optional short note. Multiple contributors may submit pending requests while the listing is available.

Listing status and request status are separate. A listing shall expose exactly these statuses:

`available`, `reserved`, `completed`, `withdrawn`

A request shall expose exactly these statuses:

`pending`, `accepted`, `rejected`, `withdrawn`, `cancelled`, `completed`

When the owner accepts one pending request, the system shall mark that request `accepted`, mark the listing `reserved`, automatically mark all other pending requests for that listing `rejected`, and prevent new requests while the listing is reserved. The owner can withdraw a listing before acceptance; the requester can withdraw a pending request.

The system shall guarantee that only one request for a listing can have `accepted` status at any given time. Request acceptance shall be performed as one atomic database transaction with concurrency protection and database-level enforcement against duplicate accepted requests, including simultaneous acceptance attempts. The transaction shall set the selected request to `accepted`, set the associated listing to `reserved`, reject all other pending requests for that listing, and prevent additional requests while the listing is reserved.

If two acceptance attempts happen simultaneously, only one may succeed. The other shall fail safely without leaving an inconsistent listing or request state. A failed attempt must not leave its request accepted, must not reserve the listing incorrectly, and must not alter the successful request's state.

If an accepted exchange is cancelled, the system shall first remove the request's active accepted-reservation state in the same protected state transition, then mark the request `cancelled`. The listing remains `reserved` until the owner explicitly chooses to relist it, at which point it returns to `available`; otherwise the owner may withdraw it. The listing must not become available while the database still treats the request as an active accepted reservation. When an exchange is completed, the system shall mark both the request and listing `completed` and prevent additional requests for that listing.

Miss → treating listing status and request status as one state machine can leave competing requests active, allow duplicate reservations, or make a completed book available again.

### R5. Private coordination

Contributors involved in a request shall exchange text messages in a private conversation tied to that request. Users shall be able to mute/archive a conversation, report a message or user, and block another user.

The MVP does not include attachments, voice/video, group chats, public comments, or end-to-end encryption claims unless separately specified and validated.

### R6. Safety and moderation

Users shall report a listing, message, or user with a required reason. Moderators shall see a queue with the reported item, reason, timestamps, and current status, then record one outcome: `dismissed`, `warning`, `content hidden`, `listing removed`, `account restricted`, or `escalated`.

The system shall prevent a blocked user from initiating new requests or messages to the blocker. Moderation must not depend on public ratings or reputation scores.

### R7. Administration and analytics

Administrators shall view only aggregate operational metrics needed for MVP decisions, such as active listings, requests by state, completed exchanges, report counts, and broad location/category totals.

Reports shall suppress groups below an approved minimum threshold. Individual contributor histories and exact locations shall not be exposed through analytics.

## 5. Privacy, security, and safety baseline

Folio shall apply privacy by design and comply with applicable obligations under the Philippine Data Privacy Act of 2012 (Republic Act No. 10173), subject to legal review before launch.

- Collect only information needed for authentication, listings, requests, safety, and support.
- Store a manually selected generalized location; never require exact home addresses or continuous GPS.
- Protect private conversations and restrict operational access to the minimum required for safety handling.
- Publish retention periods for listings, messages, reports, and deleted accounts before launch.
- Provide account deletion and a way to request personal-data access or correction, subject to documented exceptions.
- Do not resell personal data. Any future data-sharing use requires separate consent and legal review.
- Rate-limit sign-in, messaging, reports, and requests to reduce abuse and spam.
- Record moderation decisions and security events only as long as needed for safety, audit, or legal obligations.

**Miss →** If privacy rules exist only in the UI, a direct API call can expose exact locations, private messages, or unauthorized actions.

## 6. MVP access matrix

| Capability | A | B | C | D | E |
| --- | --- | --- | --- | --- | --- |
| Browse approved public listings | ✓ | ✓ | ✓ | ✓ | ✓ |
| Search and filter listings | ✓ | ✓ | ✓ | ✓ | ✓ |
| Sign in and manage own account | ✓ | ✓ | ✓ | ✓ | — |
| Create and manage own listings | ✓ | ✓ | ✓ | ✓ | — |
| Request, accept, reject, cancel, or complete exchanges | ✓ | ✓ | ✓ | ✓ | — |
| Message an exchange participant | ✓ | ✓ | ✓ | ✓ | — |
| Block and report | ✓ | ✓ | ✓ | ✓ | — |
| Review and resolve reports | ✓ | ✓ | ✓ | — | — |
| View aggregate operational reports | ✓ | ✓ | — | — | — |
| Manage system security/configuration/backups | ✓ | — | — | — | — |

Role permissions must be enforced by the API, not only by hidden client controls.

## 7. Out of scope for the MVP

To protect time-to-market, do not build these in the first release:

- lending, rentals, payments, shipping, or resale checkout;
- exact distance, maps, live GPS, or route planning;
- public ratings, follower systems, social feeds, or group chats;
- attachments or media messaging beyond one listing image;
- personalized recommendations or advanced search ranking;
- automated content moderation or AI-generated metadata;
- multi-language support, loyalty programs, or gamification;
- institutional inventory integrations or public APIs.

These may be reconsidered only after the core exchange flow is measured.

## 8. Launch acceptance criteria

The MVP is ready for system testing when all of the following are true:

1. A Guest can browse approved listings from throughout the Philippines and filter by region, province, city/municipality, and optional campus or community area.
2. A Contributor can publish a valid listing with a manually selected generalized location, find it through search/filter, and change its listing status.
3. Multiple Contributors can submit pending requests for an available listing, but accepting one request rejects all other pending requests and reserves the listing.
4. A reserved listing rejects new requests; cancelling an accepted request marks it `cancelled` and only returns the listing to `available` when the owner relists it.
5. Completing an exchange marks both the request and listing `completed` and prevents additional requests.
6. A concurrent acceptance test against two pending requests for the same listing allows only one acceptance to succeed, leaves exactly one accepted request and one reserved listing, rejects the competing pending request, and leaves no inconsistent state after the failed attempt.
7. Only exchange participants can message about an exchange; blocking prevents new contact, and users can report listings, messages, or users.
8. Moderators can resolve reports with an auditable outcome, and API authorization rejects unauthorized role actions outside the client.
9. Exact addresses, continuous GPS, raw small-group analytics, and deleted active accounts are not exposed; account deletion, retention, backup, and restore procedures are documented and tested.

## 9. Initial success measures

Track only aggregate metrics needed to decide whether the product works:

- listing publication completion rate;
- listing discovery and filter usage by generalized location level;
- search-to-request conversion;
- accepted-request rate;
- completed exchange rate;
- median time from request to owner response;
- report rate and moderator resolution time; and
- percentage of active listings with a valid generalized location.

Do not create individual behavioral profiles to calculate these measures. Set numeric targets after a small pilot establishes a baseline.

## 10. Remaining decisions before implementation

These are required decisions, not optional enhancements:

1. Define the initial rollout and support plan for nationwide Philippine coverage, including the authoritative region, province, city/municipality, and optional campus/community-area lists.
2. Approve listing condition values and the listing/request transition rules defined in R4.
3. Set the minimum aggregate reporting threshold and retention periods with legal/privacy review.
4. Define the community guidelines, report reasons, moderator escalation path, and account restriction durations.
5. Decide whether the first release is Web-only with Android-ready contracts or simultaneous Web/Android delivery.
6. Name the data controller/support contact and publish the privacy notice, deletion process, and consent language.

Until these are decided, the requirements remain proposed and should not be treated as implementation-ready.

## 11. Gap summary against v1.0

| v1.0 gap | v1.1 proposal |
| --- | --- |
| Product promise was broad | Adds a concise positioning statement and proof of value |
| No explicit listing lifecycle | Defines availability states and transitions |
| Requests lacked cancellation/completion rules | Defines owner/requester actions and duplicate-reservation behavior |
| Moderation outcomes were unspecified | Adds report reasons, queue fields, and outcomes |
| Account/data controls were incomplete | Adds deletion, retention, access/correction, and minimum collection |
| Access table lacked operational detail | Adds capability-level role matrix and API enforcement rule |
| No launch gate | Adds eight acceptance criteria |
| Scope could expand easily | Adds explicit MVP exclusions and required pre-build decisions |

