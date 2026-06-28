# JBS Fintech

A production-ready Flutter mobile app for personal finance management based strictly on the provided OpenAPI contract.

## Flutter Version

- Flutter `3.41.9`
- Dart `3.11.5`

## Features

- Login with secure token persistence
- Splash session restore and guarded navigation
- Dashboard with balance summary and charts
- Accounts CRUD
- Categories CRUD
- Transactions CRUD
- Profile screen with theme mode and logout
- Indonesian-first formatting for Rupiah and dates

## Setup

1. Install Flutter `3.41.9` or a compatible stable release.
2. Run:

```bash
flutter pub get
```

## Environment Configuration

Base API URL is configurable through Dart define.

Run the app with:

```bash
flutter run --dart-define=API_BASE_URL=https://airaai.my.id/jbsfintech/api
```

Optional auth header configuration:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://airaai.my.id/jbsfintech/api \
  --dart-define=AUTH_HEADER_NAME=Authorization \
  --dart-define=AUTH_HEADER_PREFIX=Bearer
```

## Authentication Header

Protected requests are sent with:

```http
Authorization: Bearer <token>
```

This is centralized in `lib/core/config/app_config.dart` and `lib/core/network/api_client.dart`.

## Architecture Overview

Project structure:

```text
lib/
  app/
  core/
  features/
    auth/
    dashboard/
    accounts/
    categories/
    transactions/
    profile/
```

Main choices:

- `flutter_riverpod` for dependency injection and async state
- `go_router` for navigation and auth guards
- `dio` for networking and interceptors
- `flutter_secure_storage` for token persistence
- `shared_preferences` for non-sensitive UI preferences
- `intl` for Rupiah and Indonesian date formatting
- `fl_chart` for dashboard charts
- `shimmer` for loading placeholders

## Commands

Run the app:

```bash
flutter run --dart-define=API_BASE_URL=https://airaai.my.id/jbsfintech/api
```

Format:

```bash
dart format .
```

Analyze:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## API Notes And Limitations

- No undocumented endpoints were implemented.
- No registration, forgot password, upload, pagination, filtering query params, analytics, or reports were added.
- Transaction list filtering and sorting are local in the app because the API contract does not document server-side query support.
- Login parsing supports both documented and actual observed backend shapes:
  - documented fallback: `data` as token string
  - observed runtime shape: `data.token` and `data.user`
- `attachment_path` is treated as metadata/path only. No upload flow is implemented.
- Numeric and boolean fields are parsed defensively because API responses may vary in type.

## Testing Coverage

- API envelope parsing
- Login payload parsing
- Account, category, and transaction parsing
- Rupiah and date formatting
- Token persistence wrapper
- Login validation widget
- Transaction type/category filtering widget
- Empty state rendering widget
