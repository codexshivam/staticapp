# Confessions App — Developer Setup Guide

Welcome to the **Confessions** application setup documentation. This guide covers how to set up the backend infrastructure (Appwrite), subscription management (RevenueCat), observability/notifications (Firebase), and how to configure environment variables.

---

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Environment Configuration (.env)](#environment-configuration-env)
4. [Appwrite Backend Setup](#appwrite-backend-setup)
5. [RevenueCat Subscription Setup](#revenuecat-subscription-setup)
6. [Firebase Observability & Notifications](#firebase-observability--notifications)
7. [Running the Application](#running-the-application)

---

## 🏛 Architecture Overview

The application utilizes a modular, decoupled architecture:
- **Frontend**: Flutter (Material Design 3)
- **Backend (Auth, Database, Storage)**: Appwrite
- **In-App Subscriptions**: RevenueCat (`purchase_service`)
- **Observability & Push Notifications**: Firebase (Crashlytics, Analytics, FCM, Remote Config)
- **Environment Management**: `flutter_dotenv` loading from a `.env` file

---

## ⚙️ Prerequisites

Before getting started, make sure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11.0` or higher)
- [Dart SDK](https://dart.dev/get-dart)
- An active account on [Appwrite Cloud](https://cloud.appwrite.io) (or self-hosted Appwrite)
- An active account on [RevenueCat](https://app.revenuecat.com)
- An active project on [Firebase Console](https://console.firebase.google.com)

---

## 🔐 Environment Configuration (.env)

The project uses `flutter_dotenv` to securely manage API keys and endpoints without hardcoding them into Dart source files.

1. In the root directory of the project, duplicate the template file `.env.example` and name it `.env`:
   ```bash
   cp .env.example .env
   ```

2. Open `.env` and fill in your corresponding production or development credentials:
   ```env
   # Appwrite Backend Configuration
   APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
   APPWRITE_PROJECT_ID=YOUR_APPWRITE_PROJECT_ID

   # RevenueCat Subscription Management
   REVENUECAT_ANDROID_KEY=YOUR_REVENUECAT_ANDROID_KEY
   REVENUECAT_IOS_KEY=YOUR_REVENUECAT_IOS_KEY
   ```

> **Note**: The `.env` file is automatically included in your asset bundle via `pubspec.yaml` but should be kept out of version control (ensure `.env` is added to `.gitignore`).

---

## ☁️ Appwrite Backend Setup

### 1. Create Project & API Key
- Log into Appwrite Cloud and create a new project.
- Copy the **Project ID** into your `.env` file under `APPWRITE_PROJECT_ID`.
- Register your Flutter mobile application platforms (Android package name & iOS Bundle ID) in the Appwrite Console under **Platforms**.

### 2. Database & Collections Setup
Create a new Database named `confessions_db` (ID: `confessions_db`). Within this database, create the following collections:

#### Collection: `users`
- `displayName` (String, required)
- `email` (String, required)
- `handle` (String, required)
- `avatarUrl` (String, optional)
- `bio` (String, optional)
- `link` (String, optional)
- `followersCount` (Integer, default: `0`)
- `followingCount` (Integer, default: `0`)
- `savedConfessionIds` (String Array, default: `[]`)
- `followingIds` (String Array, default: `[]`)
- `followerIds` (String Array, default: `[]`)
- `dailyPlaybackCount` (Integer, default: `0`)
- `lastPlaybackDate` (String, optional)

#### Collection: `confessions`
- `title` (String, required)
- `audioUrl` (String, required)
- `durationText` (String, required)
- `authorId` (String, required)
- `waveformData` (Float Array, required)
- `commentsCount` (Integer, default: `0`)
- `createdAt` (Datetime, required)

#### Collection: `comments`
- `confessionId` (String, required)
- `authorId` (String, required)
- `content` (String, required)
- `createdAt` (Datetime, required)

### 3. Storage Buckets Setup
Create two Storage Buckets in your Appwrite console:
- **`confessions_audio`**: For audio recordings (.m4a/.aac). Ensure appropriate permissions (e.g., Any user can read, authenticated users can write).
- **`comments_images`**: For optional comment attachments or avatars.

---

## 💎 RevenueCat Subscription Setup

The app uses RevenueCat to manage pro subscriptions (allowing unlimited daily confession listening).

1. Log into your RevenueCat dashboard and create a new Project.
2. Add an **Android App** (Google Play) and/or an **iOS App** (App Store) to the project.
3. Copy the generated **Public API Keys** into your `.env` file (`REVENUECAT_ANDROID_KEY` and `REVENUECAT_IOS_KEY`).
4. Set up an **Entitlement** named `pro` in RevenueCat.
5. Attach your corresponding App Store / Google Play products to this entitlement.

---

## 🔥 Firebase Observability & Notifications

Firebase is used for Crashlytics, Analytics, Cloud Messaging (Push Notifications), and Remote Config (for dynamic subscription toggling).

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure your Firebase project:
   ```bash
   flutterfire configure
   ```
   This command automatically generates the `lib/firebase_options.dart` file.

3. In Firebase Console under **Remote Config**, create a boolean parameter named `subscription_enabled` (default: `true` or `false` based on your regional rollout strategy).

---

## 🚀 Running the Application

1. Ensure all packages are downloaded and synced:
   ```bash
   flutter pub get
   ```

2. Run the application on your target emulator or physical device:
   ```bash
   flutter run
   ```

---

## 🛠 Troubleshooting

- **Appwrite Connection Issues**: Ensure your device/emulator has internet access and your app's Package Name / Bundle ID matches exactly what is configured in Appwrite under Platforms.
- **DotEnv Loading Errors**: Make sure your `.env` file exists in the root folder and is listed exactly as `- .env` under the `assets` section in `pubspec.yaml`.
