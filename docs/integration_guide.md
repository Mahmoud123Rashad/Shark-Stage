# SharkStage Flutter Integration Guide

This document explains how to run the refreshed Flutter application against the `sharkserver` backend and highlights the new feature parity modules.

## Prerequisites

- Flutter **3.38.0-0.2.pre** (beta) or newer (run `flutter --version` to confirm).
- Dart SDK 3.10.0 (ships with Flutter beta).
- Node.js 18+ and npm (for running `sharkserver`).
- MongoDB connection credentials configured for the backend.

## Backend Setup

1. Navigate to `sharkserver/`.
2. Copy `.env.example` (if available) to `.env` and update:
   - `PORT` (defaults to 5000)
   - `MONGO_URL`
   - `DB_NAME`
   - `JWT_SECRET`
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start the server:
   ```bash
   npm run dev
   ```
   The API will be reachable at `http://localhost:5000`.

## Flutter App Configuration

The Flutter client reads environment variables via `--dart-define`. Set the API base as needed:

```bash
# PowerShell (single line)
flutter run -d 192.168.1.2:5555 --dart-define=SHARK_API_BASE=http://10.0.2.2:5000 --dart-define=SHARK_SOCKET_BASE=http://10.0.2.2:5000 --dart-define=SHARK_WEB_BASE=http://localhost:3000

# PowerShell (multi-line)
flutter run -d 192.168.1.2:5555 `
  --dart-define=SHARK_API_BASE=http://10.0.2.2:5000 `
  --dart-define=SHARK_SOCKET_BASE=http://10.0.2.2:5000 `
  --dart-define=SHARK_WEB_BASE=http://localhost:3000
```

The client now auto-selects sensible defaults per platform:

- Android emulator → `http://10.0.2.2:5000`
- iOS simulator → `http://127.0.0.1:5000`
- Physical devices → set to your machine's LAN IP via `--dart-define`
- Web/desktop → `http://localhost:5000`

Override the defaults with `--dart-define` if your backend runs elsewhere.

## Google OAuth Setup

Mobile clients now share the same `/auth/google` flow that powers the `sharkstage` web app. Reuse the credentials that already live in your Google Cloud project:

1. Verify the existing **Web application** client ID (used by the backend for server-side exchanges). This becomes your `SHARK_GOOGLE_SERVER_CLIENT_ID`.
2. Create OAuth client IDs per platform if you haven’t already:
   - **Android**: Package name `com.example.finial_project` (update if you changed it) and the app’s SHA-1 fingerprint. This client ID is used for `SHARK_GOOGLE_CLIENT_ID`.
   - **iOS**: Bundle identifier `com.example.finialProject` (match your `Runner` target). This client ID is used for `SHARK_GOOGLE_IOS_CLIENT_ID`.
3. Update the Flutter run/build command with the new defines:

```bash
flutter run `
  --dart-define=SHARK_API_BASE=http://10.0.2.2:5000 `
  --dart-define=SHARK_GOOGLE_CLIENT_ID=YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com `
  --dart-define=SHARK_GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID.apps.googleusercontent.com `
  --dart-define=SHARK_GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

4. Ensure platform projects are configured per the [`google_sign_in` setup guide](https://pub.dev/packages/google_sign_in):
   - Android: Add the SHA-1 for debug/release keystores in the Google Cloud console.
   - iOS: Add the reversed client ID (`com.googleusercontent.apps.xxx`) to `Runner/Info.plist` under `CFBundleURLTypes`.

Once these values are supplied, the Flutter app requests a Google server auth code and trades it with the SharkStage backend, mirroring the production web login.

## Key Modules & Parity

- **Authentication**: Email/password signup & login now call `/auth/signup`, `/auth/signin`, `/auth/me`, `/auth/logout`.
- **Projects**: Catalogue, detail, and creation leverage `/projects` endpoints. Listings support filtering, sorting, and pagination.
- **Dashboard**: Entrepreneur and investor dashboards now derive stats from live project data via Riverpod providers.
- **Offers**: New Offer Desk screen fetches `/offers/sent` and `/offers/received`, with accept/reject/cancel actions.
- **Chat**: Messaging list consumes `/chat/conversations`; real-time threads are stubbed with a placeholder pending full Socket.IO integration.

## Testing & QA Checklist

1. **Backend health**: `curl http://localhost:5000/health`.
2. **Auth**:
   - Sign up as entrepreneur and investor.
   - Confirm login flow routes to appropriate dashboards.
3. **Projects**:
   - Verify listing renders remote data.
   - Create a project as entrepreneur (ensure image upload is optional).
   - Open project details screen.
4. **Offers**:
   - Trigger offers via `/offers/send` (e.g. via Postman or web client), then confirm Offer Desk tabs render and actions update state.
5. **Chat**:
   - Seed conversations/messages (using backend tools or API) and confirm chat list populates.
6. **Theming**:
   - Toggle light/dark mode within sign up screen; verify persisted preference on restart.

## Commands Reference

```bash
# Analyze & format
flutter analyze
dart format lib test

# Generate Freezed/JSON classes
flutter pub run build_runner build --delete-conflicting-outputs
```

## Known Gaps

- In-conversation chat UI is pending; current build surfaces conversation previews only.
- Offer actions assume optimistic success; add error toasts if API returns failure states.

## Next Steps

- Wire the chat thread UI with Socket.IO streams (`socket_io_client` already included).
- Expand project creation form to capture full backend schema (risks, benefits, management team).
- Automate integration tests hitting `sharkserver` via `flutter_test` or `integration_test`.

