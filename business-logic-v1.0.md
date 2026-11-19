# Business Logic

> Development of a Web-Based Community Book Sharing and Exchange Platform using React and Supabase for Book Enthusiasts

- Allowed Platforms: Web, Android

## Project Details

- Company/Startup/Team Name: Veltrix
- Project Code Name: Folio
- Project Short Code: FL
- Short Description: Folio is a community-powered platform that connects book lovers to discover, share, swap, and donate pre-loved books within their communities.
- Long Description: Folio is a community-powered book sharing and exchange platform designed to make books more accessible and encourage sustainable reading habits. Users can list books they no longer need, discover available books from other community members, and arrange swaps or donations. Each listing includes a generalized location, such as a city, municipality, or campus, allowing users to discover nearby books without revealing exact addresses. Folio also provides private in-app messaging so users can communicate, discuss book conditions, and coordinate exchanges. The platform encourages community participation, resource sharing, and meaningful connections among book enthusiasts.

## User Levels

> Note: Modify/rename the list of users based on the actual users that you expect to use the system.

| User Level | Description |
| --- | --- |
| A. System Administrator | Maintains system configurations, security settings, and database backups. |
| B. Administrator | Manages platform settings, oversees community operations, and views aggregated system reports. |
| C. Moderator | Reviews reported listings and messages, handles user complaints, and enforces community guidelines. |
| D. Contributor | Registered users who can create book listings, discover books, request exchanges, send private messages, and participate in book sharing. |
| E. Guest | Unregistered users who can browse publicly available book listings and view generalized locations but cannot post, request, or message. |

## System Requirements

1. The app shall allow users to authenticate using Google Sign-In integration.
2. The app shall allow authenticated users to create, edit, and remove book listings containing a title, author, genre, condition, description, image, exchange type, and generalized location.
3. The app shall allow users to browse, search, and filter book listings by title, author, genre, condition, exchange type, and generalized location.
4. The app shall allow contributors to select a city, municipality, or campus area for their listings without requiring exact addresses or continuous GPS tracking.
5. The app shall allow authenticated users to send and receive private text messages with other contributors to discuss books and coordinate exchanges.
6. The app shall allow contributors to request books for swapping or donation, while book owners can accept or reject requests and update book availability.
7. The app shall allow users to report inappropriate listings or messages, block other users, and allow moderators to review reports and enforce community guidelines.

## Required Solution Layers

1. Security and privacy by design. The platform shall follow the Data Privacy Act of 2012 (Republic Act No. 10173), apply appropriate access controls, protect private conversations, and minimize the collection of personal information.
2. Location protection. The platform shall display only generalized locations such as province, city, municipality, or campus area. Exact home addresses and live GPS locations shall not be publicly displayed or required.
3. Data retention and user privacy. The platform shall establish appropriate retention limits, avoid unnecessary per-user activity trails, and provide mechanisms for account and personal data deletion subject to legitimate retention requirements.
4. Community safety. The platform shall support reporting, blocking, and moderation of inappropriate listings and messages without relying on publicly visible reputation scores.
5. Data access and reporting. Administrative analytics shall use aggregated information with appropriate minimum reporting thresholds. Personal data shall not be resold without valid consent and applicable legal safeguards.

## MVP Features and Access

> See the User Levels table for reference.

| Feature | Access |
| --- | --- |
| 1. Browse and search publicly available book listings with generalized location filters | A, B, C, D, E |
| 2. Google Sign-In and contributor account management | A, B, C, D |
| 3. Create, edit, and manage personal book listings with generalized locations | A, B, C, D |
| 4. Request swaps or donations and manage book availability | A, B, C, D |
| 5. Private messaging, conversation management, and user blocking | A, B, C, D |
| 6. Review reports and moderate community content | A, B, C |
| 7. Manage platform configurations, security, and backups | A |

## Notes

- Folio is a community-powered platform developed by Veltrix.
- The initial MVP focuses on book discovery, swapping, donations, generalized location filtering, private messaging, and community moderation.
- The platform is intended for book enthusiasts, including students and other community members.
- Users shall manually select a generalized location for each listing.
- The MVP shall not require GPS tracking, exact distance calculations, or precise location sharing.
- Private messaging shall initially support text-based conversations only.
- Users shall be able to report or block other users for inappropriate behavior.
- Book exchanges and meetups shall be arranged voluntarily between participating users.
- Book lending, reselling, ratings, group chats, and advanced recommendations are considered future enhancements.
- The initial version shall prioritize a manageable feature set, community safety, privacy, and ease of use.
