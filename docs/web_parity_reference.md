# SharkStage Web Feature & API Catalogue

This document captures the functionality currently implemented in the Next.js web experience (`sharkstage/`) and the REST surface provided by the Node/Express backend (`sharkserver/`). It serves as the parity checklist for bringing the Flutter application (`Shark-Stage/`) to feature equivalence.

## 1. Frontend Feature Map

| Area | Source (Next.js) | Key Behaviours | Notable Components |
|------|------------------|----------------|--------------------|
| Landing / Marketing | `app/(main)/page.jsx`, `app/components/home/*` | Hero CTA, value propositions, KPIs, investment categories, testimonials, CTA banner. | `Hero`, `WhyChooseSection`, `Numbers`, `InvestmentCategories`, `Banner`, `ReadySection`, `NavBar`, `Footer`, `PageTransition`. |
| Authentication | `app/(auth)/sign/in/page.jsx`, `app/(auth)/sign/up/page.jsx`, `StoreProvider.jsx`, `lib/features/auth/*` | Email/password signup/login, Google OAuth, account type selection, redux-powered global user state. | `SignInput`, `GoogleAuthButton`, `InputField`, Redux `authSlice`, `authThunks`. |
| Global State & Routing | `StoreProvider.jsx`, `app/layout.js`, `app/(main)/layout.jsx` | Redux store bootstrapping, auto auth check (`checkAuth`), project preload (`getProjects`), Google OAuth provider, route group layouts. | `makeStore`, `PageTransition`, `Provider`. |
| Projects Catalogue | `app/(main)/projects/page.jsx`, `app/components/projects/*` | Search, category & status filtering, ROI slider, sort options, pagination, project cards with stats, empty-state messaging. | `FilterBar`, `ProjectCard`, `Pagination`, `SendMessage`, `InvestorFilter`, `OwnerFilter`. |
| Project Details | `app/(main)/projects/[id]/page.jsx`, `MessageForm.jsx` | Detailed view, hero media, investment metrics, owner info, send message/offer entry points. | `MessageForm`, `SendMessage`, `Quote`. |
| Dashboard Shell | `app/(dashboard)/account/layout.js`, `app/components/dashboard/*` | Sidebar navigation, responsive header, notifications popover, account menu. | `Sidebar`, `Header`, `AccountPopover`, `Notifications`. |
| Dashboard Overview | `app/(dashboard)/account/page.js` | Role-aware KPIs, charts (bar & pie), curated error state, animated cards. | Recharts `BarChart`, `PieChart`, `useDashboardProjects` hook. |
| Dashboard Projects | `app/(dashboard)/account/projects/*` | Owner filters, investor filters, add/edit project flows, project tables, tabs. | `OwnerFilter`, `InvestorFilter`, add/edit forms. |
| Dashboard Offers | `app/(dashboard)/account/offers/page.js`, `[id]/page.jsx` | Sent vs received offer lists, detailed offer view, CTA for actions (accept/ reject/ cancel). | `OffersCards`, role-dependent logic. |
| Dashboard Messages | `app/(dashboard)/account/messages/page.js`, `app/chat/*` | Conversation list, websocket-enabled chat threads, message composer. | `chat/page.jsx`, `[conversationId]/page.jsx`, real-time socket handling. |
| Dashboard Profile | `app/(dashboard)/account/profile/page.js` | Profile overview, editable information, avatar upload integration. | `ImageUpload`, `InputField`. |
| Account Settings | `app/(dashboard)/account/settings/page.js` | Preferences, password change flow, toggles (details inferred from slice). | Utilises redux auth slice. |
| Support / FAQ | `app/components/DialogWindow.jsx`, `app/components/Chatbot.jsx` | FAQ dialog, AI chatbot integration for quick assistance. | `Chatbot` component hitting `/chatbot/ask`. |

## 2. Backend Endpoint Overview

The Express application mounts routers at the following base paths (`index.js`). Middleware `requireAuth` demands JWT tokens provided via cookies or `Authorization: Bearer` headers.

### Authentication (`/auth`)

| Method & Path | Purpose | Notes |
|---------------|---------|-------|
| `POST /signup` | Create user with email/password. | Rate limited (10 per 15 min). |
| `POST /signin` | Login, returns JWT, sets `token` cookie. | Requires email/password. |
| `POST /google` | OAuth exchange for Google account. | Accepts `{ code, intent, accountType }`. |
| `POST /logout` | Clear session. | No auth guard applied (handles cookies). |
| `POST /upload-profile-picture` | Upload avatar image. | `multipart/form-data`, field `profilePicUrl`, requires auth. |
| `DELETE /remove-profile-picture` | Delete avatar. | Requires auth. |
| `GET /me` | Fetch current user. | Requires auth. |
| `PATCH /profile` | Update profile fields. | Requires auth. |
| `PATCH /password` | Change password. | Requires auth. |

### Projects (`/projects`)

| Method & Path | Purpose | Notes |
|---------------|---------|-------|
| `GET /` | List all projects. | Public. |
| `GET /:id` | Fetch single project. | Public. |
| `GET /user/:id` | Projects for a specific user. | Public. |
| `POST /add` | Create project. | Auth required, `multipart/form-data` with `image`. |
| `PUT /edit/:id` | Update project. | Auth required, optional image upload. |
| `DELETE /delete/:id` | Delete project. | Auth required. |
| `PUT /:projectId/image` | Replace project image. | Auth required with upload. |
| `DELETE /:projectId/image` | Remove stored image. | Auth required. |

### Offers (`/offers`)

| Method & Path | Purpose |
|---------------|---------|
| `POST /send` | Send offer (auth expected but middleware absent—review). |
| `GET /sent` | List sent offers (auth). |
| `GET /received` | List received offers (auth). |
| `GET /:id` | Fetch single offer (auth). |
| `PATCH /accept/:id` | Accept offer (auth). |
| `PATCH /reject/:id` | Reject offer (auth). |
| `PATCH /cancel/:id` | Cancel offer (auth). |

### Chat (`/chat`)

| Method & Path | Purpose |
|---------------|---------|
| `POST /send` | Post message to conversation (auth). |
| `GET /conversations` | Fetch user conversations (auth). |
| `GET /:conversationId` | Retrieve messages for conversation (auth). |

Socket.io events (namespace default):
- `join_conversation` → `socket.join(conversationId)`
- `send_message` → broadcast `receive_message`

### Notifications (`/notifications`)

| Method & Path | Purpose |
|---------------|---------|
| `GET /user` | Fetch notifications for current user (auth). |
| `PATCH /read/:id` | Mark notification as read (auth). |

### FAQ (`/faq`)

| Method & Path | Purpose |
|---------------|---------|
| `POST /` | Create FAQ entry. |
| `GET /` | List FAQ entries. |
| `GET /:id` | Retrieve FAQ entry. |
| `PUT /:id` | Update FAQ. |
| `DELETE /:id` | Delete FAQ. |

### Chatbot (`/chatbot`)

| Method & Path | Purpose |
|---------------|---------|
| `POST /ask` | Submit question to AI assistant. |

### Upload (legacy)

`/upload/profilepic` exists in `routers/uploadpic.route.js` but is not currently mounted in `index.js` (future consideration).

## 3. Data Models & Payload Hints

- Auth controllers and `requireAuth` middleware expose user fields: `_id`, `firstName`, `lastName`, `email`, `accountType`, `profilePicUrl`, plus optional `company`, `phone`, `bio`, `ownedProjects`, `investedProjects`.
- Projects appear to include `title`, `description`, `category`, `status`, `expectedROI`, `totalPrice`, `currentFunding`, `image`, `updatedAt`.
- Offers provide sender/receiver context, status transitions (pending/accepted/rejected/cancelled), and associated project metadata.
- Conversations/messages reference participants, message body, timestamps, and `lastMessage` relation.
- Notifications capture message, read state, and user ID.
- FAQ entries include question/answer text and CRUD metadata.

## 4. Flutter Parity Implications

1. **Feature Coverage** – Flutter must implement landing marketing pages, auth flows (including Google OAuth), project catalogue and detail, dashboard (owner/investor/admin permutations), offers, chat (with socket support), notifications, profile management, FAQ/chatbot experiences.
2. **API Contracts** – Ensure HTTP client handles cookie + bearer token strategies, multipart upload for images, error payloads `{ message }` or `{ error }`, and JWT refresh behaviour (7-day expiry).
3. **Real-time Messaging** – Integrate Socket.IO via Flutter compatible client, mirroring event names.
4. **Design System** – Translate gradients (`AppColors` vs web palette), typography, spacing, motion (via `AnimatedContainer`, `ImplicitlyAnimatedReorderableList`, `rive`, etc.).
5. **State Management** – Plan to replace Redux with Flutter equivalents (e.g., Riverpod, Bloc, Provider) keeping same intent: auth guard, project preload, optimistic updates.

This catalogue will be updated as further deep-dives uncover additional flows or edge cases in the web app/back-end. Use it as the authoritative reference for scope during the Flutter parity implementation.

