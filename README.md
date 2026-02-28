# User Friendly News

Personalized live news app built with Flutter.

## What It Does

- Lets users create and manage their own news tags.
- Fetches real-time stories from Google News RSS using those tags.
- Prioritizes well-known trusted publishers in the feed.
- Shows a refreshable home feed of latest matched stories.
- Sends local push notifications for new matched stories using background sync.

## Tech Stack

- Flutter
- `http` + `xml` for live RSS parsing
- `shared_preferences` for local tag storage
- `flutter_local_notifications` for notifications
- `workmanager` for periodic background refresh checks

## Run Locally

```bash
flutter pub get
flutter run
```

## Notes

- Android notification permission is required on Android 13+.
- Background checks are periodic and controlled by OS battery/background policies.
- This app is source-driven by your selected tags, so adding better tags improves results.
