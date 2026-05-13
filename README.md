# Confessions App — Developer Setup Guide

Welcome to the **Confessions** application setup documentation. This guide covers how to set up the backend infrastructure (Google Firebase), subscription management (RevenueCat), observability/notifications, and environment configuration.

---

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Environment Configuration (.env)](#environment-configuration-env)
4. [Firebase Backend Setup](#firebase-backend-setup)
5. [RevenueCat Subscription Setup](#revenuecat-subscription-setup)
6. [Running the Application](#running-the-application)

---

## 🏛 Architecture Overview

The application utilizes a modular, decoupled architecture:
- **Frontend**: Flutter (Material Design 3)
- **Backend (Auth, Database, Storage)**: Firebase (Firebase Auth, Cloud Firestore, Firebase Cloud Storage)
- **In-App Subscriptions**: RevenueCat (`purchases_flutter`)
- **Observability & Push Notifications**: Firebase (Crashlytics, Analytics, FCM, Remote Config)
- **Environment Management**: `flutter_dotenv` loading from a `.env` file

---

## ⚙️ Prerequisites

Before getting started, make sure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11.0` or higher)
- [Dart SDK](https://dart.dev/get-dart)
- An active project on [Firebase Console](https://console.firebase.google.com)
- An active account on [RevenueCat](https://app.revenuecat.com)

---

## 🔐 Environment Configuration (.env)

The project uses `flutter_dotenv` to securely manage API keys without hardcoding them into Dart source files.

1. In the root directory of the project, ensure your `.env` file is present:
   ```env
   # RevenueCat Subscription Management
   REVENUECAT_ANDROID_KEY=test_dqUqZKVCRZxyjcGymsxZQGRxHJf
   REVENUECAT_IOS_KEY=test_dqUqZKVCRZxyjcGymsxZQGRxHJf
   ```

> **Note**: Firebase configuration is fully managed natively by `lib/firebase_options.dart` generated via `flutterfire configure`.

---

## ☁️ Firebase Backend Setup

### 1. Firebase Initialization & Auth
- In the Firebase Console, enable **Authentication** (Email/Password & Anonymous sign-in providers).

### 2. Firestore Database Collections
Enable **Cloud Firestore** in production/native mode. The app interacts with the following root collections:

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

#### Collection: `confessions`
- `id` (String, required)
- `title` (String, required)
- `audioUrl` (String, required)
- `durationText` (String, required)
- `authorId` (String, required)
- `waveformData` (Array<Number>, required)
- `commentsCount` (Number, default: `0`)
- `createdAt` (String ISO-8601, required)

#### Collection: `comments`
- `id` (String, required)
- `confessionId` (String, required)
- `authorId` (String, required)
- `content` (String, required)
- `createdAt` (String ISO-8601, required)

### 3. Firebase Cloud Storage
Enable **Cloud Storage** for Firebase. By default, audio files are saved under the `/confessions/` bucket path.

---

## 💎 RevenueCat Subscription Setup

The app uses RevenueCat to manage pro subscriptions (allowing unlimited daily confession listening).

1. Log into your RevenueCat dashboard and create a new Project.
2. Add an **Android App** (Google Play) and/or an **iOS App** (App Store) to the project.
3. Copy the generated **Public API Keys** into your `.env` file (`REVENUECAT_ANDROID_KEY` and `REVENUECAT_IOS_KEY`).
4. Set up an **Entitlement** named `TheStatic Pro` in RevenueCat.
5. Attach your corresponding App Store / Google Play offering (`monthly`).

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
