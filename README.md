# TheStatic Platform

Static is a sanctuary for the unsaid. A space where late-night confessions find their voice, where emotions become stories, and where being vulnerable is never alone.

Hear authentic voices. Share your truth. Connect through the feelings that matter.


## Architecture
* **Frontend**: Flutter (Material 3).
* **Audio Engine**: `just_audio` & `just_audio_background`.
* **Backend**: Firebase (Auth, Firestore, Storage).
* **Subscriptions**: RevenueCat.
* **Observability**: Firebase Crashlytics, Analytics, FCM, Remote Config.
* **Local Persistence**: SQLite (`sqflite`).

## Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11.0`+) & Dart SDK.
* Active [Firebase](https://console.firebase.google.com) project.
* Active [RevenueCat](https://app.revenuecat.com) developer account.
* Active [Google Play Console](https://play.google.com/console) merchant account.

## Environment Configuration
Create a `.env` file in the root directory:
```env
REVENUECAT_ANDROID_KEY=your_android_key
REVENUECAT_IOS_KEY=your_ios_key
```
*(Note: Firebase config is managed natively via `flutterfire configure` in `lib/firebase_options.dart`)*

## Firebase Setup

**1. Auth & Storage**
* Enable **Email/Password** & **Anonymous Sign-In**.
* Create Storage buckets for `/confessions/` (M4A) and `/comments/` (PNG).

**2. Push Notifications & Remote Config**
* FCM: Configure monochrome vector icon at `android/app/src/main/res/drawable/ic_notification.xml`.
* Remote Config: Set `is_subscription_enabled` (Bool, default: true) and `refund_policy_url` (String).

**3. Firestore Collections**
* `users`: `displayName`, `email`, `handle`, `bio`, metrics (`followersCount`, `followingCount`, `confessionCount`), `upiId`, `links`, `savedConfessionIds`, `followingIds`, `followerIds`, `dailyPlaybackCount`, `lastPlaybackDate`, `isPro`.
* `confessions`: `id`, `title`, `audioUrl`, `durationText`, `authorId`, `waveformData`, `commentsCount`, `createdAt`.
* `comments`: `id`, `confessionId`, `authorId`, `content`, `imageUrl`, `createdAt`.

## Local Database (SQLite)
Manages offline listen history (`confessions.db`, Schema v2) via `sqflite`. Audio is cached via `PlaybackManager` to the device temp directory.
* **Table `history`**: `id` (TEXT PK), `listened_at` (TEXT ISO-8601), `data` (TEXT JSON).

## RevenueCat Subscriptions
1. Create a RevenueCat project and add an Android App (Google Play).
2. Add an Entitlement strictly named: `TheStatic Pro`.
3. Attach an Offering containing your Google Play subscription product ID.

## Publishing (Google Play Store)

**1. Generate Keystore**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**2. Configure Properties**
Create `android/key.properties` (do not commit to version control):
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

**3. Build Release Bundle**
Increment the version in `pubspec.yaml`, then compile:
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
Upload the resulting `app-release.aab` from `build/app/outputs/bundle/release/` to the Google Play Console.
