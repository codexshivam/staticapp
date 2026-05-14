# Confessions App — Developer & Publishing Setup Guide

Welcome to the official developer and publishing guide for **Confessions**. This document provides end-to-end instructions for configuring the backend infrastructure, local offline persistence, subscription paywalls, observability, and publishing the application to the Google Play Store.

---

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Environment Configuration (.env)](#environment-configuration-env)
4. [Firebase Infrastructure Setup](#firebase-infrastructure-setup)
5. [Local SQLite Database Architecture](#local-sqlite-database-architecture)
6. [RevenueCat In-App Subscriptions](#revenuecat-in-app-subscriptions)
7. [Publishing to Google Play Store](#publishing-to-google-play-store)

---

## 🏛 Architecture Overview

The application utilizes a highly optimized, offline-first, decoupled architecture:
- **Frontend**: Flutter (Material Design 3 & Vanilla Styling).
- **Audio Engine**: `just_audio` and `just_audio_background` supporting background media sessions and local file caching.
- **Backend**: Google Firebase (Firebase Auth, Cloud Firestore, Firebase Cloud Storage).
- **In-App Subscriptions**: RevenueCat (`purchases_flutter` & `purchases_ui_flutter`).
- **Observability & Engagement**: Firebase Crashlytics, Analytics, Cloud Messaging (FCM), and Remote Config.
- **Local Persistence**: Unlimited Firestore persistence engine paired with local SQLite (`sqflite`) for permanent offline listen history.

---

## ⚙️ Prerequisites

Before building or publishing, ensure you have the following installed and configured:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11.0` or higher).
- [Dart SDK](https://dart.dev/get-dart).
- Active project on [Google Firebase Console](https://console.firebase.google.com).
- Active developer account on [RevenueCat](https://app.revenuecat.com).
- Active merchant account on [Google Play Console](https://play.google.com/console).

---

## 🔐 Environment Configuration (.env)

The project uses `flutter_dotenv` to securely inject API keys without hardcoding them into Dart source files.

1. Create a `.env` file in the root directory (duplicate `.env.example`):
```env
# RevenueCat Subscription Management Keys
REVENUECAT_ANDROID_KEY=test_dqUqZKVCRZxyjcGymsxZQGRxHJf
REVENUECAT_IOS_KEY=test_dqUqZKVCRZxyjcGymsxZQGRxHJf
```

> **Note**: Firebase configuration is fully managed natively by `lib/firebase_options.dart` generated via `flutterfire configure`.

---

## ☁️ Firebase Infrastructure Setup

### 1. Authentication
Enable **Authentication** in the Firebase Console. Activate the following sign-in providers:
- **Email/Password**
- **Anonymous Sign-In** (for guest mode access)

### 2. Cloud Firestore Collections
Enable **Cloud Firestore** in Native mode. Configure index rules for timestamp sorting. The app interacts with the following root collections:

#### Collection: `users`
- `displayName` (String, required)
- `email` (String, required)
- `handle` (String, required)
- `bio` (String, optional)
- `followersCount` (Number, default: `0`)
- `followingCount` (Number, default: `0`)
- `confessionCount` (Number, default: `0`)
- `upiId` (String, optional)
- `links` (Array, default: `[]`)
- `savedConfessionIds` (Array, default: `[]`)
- `followingIds` (Array, default: `[]`)
- `followerIds` (Array, default: `[]`)
- `dailyPlaybackCount` (Number, default: `0`)
- `lastPlaybackDate` (String, optional)
- `isPro` (Boolean, default: `false`)

#### Collection: `confessions`
- `id` (String, required)
- `title` (String, required)
- `audioUrl` (String, required)
- `durationText` (String, required)
- `authorId` (String, required)
- `waveformData` (Array<Number>, required)
- `commentsCount` (Number, default: `0`)
- `createdAt` (String ISO-8601 / Timestamp, required)

#### Collection: `comments`
- `id` (String, required)
- `confessionId` (String, required)
- `authorId` (String, required)
- `content` (String, required)
- `imageUrl` (String, optional)
- `createdAt` (String ISO-8601 / Timestamp, required)

### 3. Firebase Cloud Storage
Enable **Cloud Storage**. The app uses two buckets:
- `/confessions/` — Stores user-recorded M4A audio files.
- `/comments/` — Stores visual whisper attachment PNGs.

### 4. Push Notifications (FCM) & Status Bar Icons
Firebase Cloud Messaging is integrated for background notifications.
- **Android Status Bar Vector Icon**: FCM strictly requires a monochrome vector drawable. This is pre-configured in `android/app/src/main/res/drawable/ic_notification.xml`.
- Ensure your Firebase service account key or FCM API key is linked to your sending server if triggering automated broadcast pushes.

### 5. Remote Config
Enable **Remote Config** in the Firebase Console and configure the following parameters:
- `is_subscription_enabled` (Boolean, default: `true`): Toggles premium paywall enforcement.
- `refund_policy_url` (String, default: `https://support.google.com/googleplay/answer/2479637`): Dynamic URL displayed on the paywall screen.

---

## 🗄 Local SQLite Database Architecture

To provide robust offline listen history, the app utilizes `sqflite` managing `confessions.db` (Schema v2).
- **Table**: `history`
- **Columns**:
  - `id` (TEXT PRIMARY KEY)
  - `listened_at` (TEXT ISO-8601)
  - `data` (TEXT JSON payload of the entire `Confession` model)

> **Caching Engine**: When streaming audio, `PlaybackManager` automatically downloads and caches M4A files into the device temp directory, eliminating repeat Firebase Storage egress bandwidth costs.

---

## 💎 RevenueCat In-App Subscriptions

The app enforces a freemium model (1 free confession stream per day for non-pro users).

1. Log into your RevenueCat dashboard and create a project.
2. Add an **Android App** (Google Play) and link your Google Play Service Account credentials.
3. Add an **Entitlement** exactly named:
   ```text
   TheStatic Pro
   ```
4. Attach an **Offering** (e.g., `default` or `monthly`) containing your Google Play subscription product ID.
5. Populate your `.env` file with the respective RevenueCat public API key.

---

## 🚀 Publishing to Google Play Store

### 1. Generate Keystore (Android Signing)
Generate a secure upload keystore for signing your production release:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Configure `key.properties`
Create a `key.properties` file inside `android/key.properties` (do not commit this file to version control):
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/Users/username/upload-keystore.jks
```

### 3. Verify Versioning
Open `pubspec.yaml` and increment the version and build number before every release:
```yaml
version: 1.0.0+1 # [version_number]+[build_number]
```

### 4. Build Production App Bundle
Run flutter clean and compile the Android App Bundle (AAB):
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

The compiled bundle will be available at:
`build/app/outputs/bundle/release/app-release.aab`

### 5. Google Play Console Upload
1. Log into Google Play Console and create your application.
2. Complete all required declarations (Data Privacy, Content Ratings, Target Audience).
3. Navigate to **Production** (or **Closed Testing**), create a new release, and upload the generated `app-release.aab`.
4. Submit for review!

---
*Built with passion by the Confessions Engineering Team.*
