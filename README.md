# 🌌 Confessions — Premium Audio Storytelling Platform

> *"Listening to someone's untold feelings late at night... ❤️"*

**Confessions** is an intimate, luxurious, and highly emotional romantic audio storytelling platform built with Flutter. Unlike loud, fast-paced, and highly colorful social media clones, **Confessions** feels like a quiet evening journal. It is a warm, poetic, and minimal sanctuary where users record, stream, share, and preserve secret audio whispers under anonymous pen names.

---

## 🎨 Design Philosophy & UX Tokens

Every pixel, curve, and typographical contrast is tailored to capture the feeling of reading a personal diary under soft midnight lamplight:

*   **Typography**: Exclusively mapped to **Playfair Display** (via `google_fonts`), creating a premium, literary, and high-editorial editorial look.
*   **Color Palette**:
    *   `Primary Background`: `#E8E4DF` (Warm, comforting beige)
    *   `Container Background`: `#FFFFFF` (Pure white journal backdrops)
    *   `Primary Text`: `#2E2E2E` (Solid charcoal black for effortless readability)
    *   `Secondary Text`: `#6F6B66` (Warm grey for timelines and descriptive captions)
    *   `Accent Highlight`: `#111111` (Deep black for buttons, icons, and focus points)
    *   `Romantic Highlight`: Minimalist red hearts (`#D32F2F` ❤️)
*   **Border Curves**: Strictly restricted to a clean **`5.0px`** on all widgets (containers, cards, buttons, text fields, and sheets) to achieve a modern, premium, structured silhouette.
*   **Spacing**: Harmonized using a consistent `16px` standard padding and `14px` layout gaps.

---

## 📱 High-Fidelity App Tour & Flows

Confessions is fully interactive using highly polished mock diaries, user logs, and background animations:

1.  **Splash & Onboarding** (`splash_screen.dart`, `login_screen.dart`, `signup_screen.dart`):
    *   Animated fade-and-scale brand launcher that takes you into intimate authorization fields.
    *   Allows pen name and diary bio onboarding so users can write *letters they will never mail*.
2.  **Bottom Navigation & Active Playback** (`main_navigation_shell.dart`, `playback_manager.dart`):
    *   Custom-notched navigation bar housing dynamic tabs (Home, Explore, Saved, Profile).
    *   A **synchronized audio playback simulation engine** with elapsed timer calculations. Playing any card across the application updates all active cards and top players instantly.
3.  **Home Feed** (`home_screen.dart`):
    *   Features a persistent active global controller.
    *   Horizontally scrolling sliders for *"Active in the Past 24 Hours"* alongside vertical streams for *"People You Follow"*.
4.  **Confession Detail & Whisper Room** (`confession_detail_screen.dart`):
    *   Renders a large, precise **audio waveform generator** that colors in bars proportionally as the simulated head moves.
    *   **UPI Support Block**: Support authors anonymously using select tipping buttons (₹20 to ₹200) that connect to real UPI app launch dialogs.
    *   **Discussion Feed**: Live-editable discussion thread enabling users to post silent whispers, attach simulated photo thumbnails, and delete comment lines dynamically.
5.  **Calendar Explore** (`explore_screen.dart`):
    *   Interactive **7-day weekly calendar strip** to step back into the echoes of previous nights and filter diaries.
    *   Quick-tag filter capsules (e.g., *Late Night*, *First Love*, *Regrets*).
6.  **Saved Journals & Follow logs** (`saved_screen.dart`, `followers_screen.dart`):
    *   Bookmarked diaries supporting **dismissible swipe-to-unsave gesture animations**.
    *   Slidable profiles allowing you to follow other diaries, navigate directly to their feeds, and explore their stories.
7.  **Simulated Recorder** (`create_confession_screen.dart`):
    *   Fully animated recording visualizer that **toggles real microphone wave oscillations** and tracks time limits.
    *   Detailed **uploading state pipeline** (*Formatting audio...*, *Encrypting anonymous initials...*, *Broadcasting to the stars...*) that inserts the newly created confession into our live list upon success!

---

## 📁 Repository Structure

```
lib/
├── main.dart                      <- App bootstrap & custom Material 3 theme load
├── core/
│   ├── theme/
│   │   ├── app_colors.dart        <- Hexadecimal design system tokens
│   │   └── app_theme.dart         <- Custom ThemeData (5px curves, Playfair TextTheme)
│   └── navigation/
│       └── playback_manager.dart  <- Synchronized ChangeNotifier simulating elapsed durations
├── models/
│   ├── user.dart                  <- Pen-name profiles and statistics
│   ├── comment.dart               <- Whisper room comments with text, images, and author markers
│   └── confession.dart            <- Audio cards mapping waves, duration records, and save states
├── mock_data/
│   └── sample_data.dart           <- Emotional, night-themed mock content and initial states
├── widgets/
│   ├── section_title.dart         <- Clean section headers with action triggers
│   ├── search_field.dart          <- Minimalist text input bars
│   ├── settings_tile.dart         <- Custom rows for profile configuration
│   ├── user_list_tile.dart        <- slidable followers row with follow actions
│   ├── comment_bubble.dart        <- Chat balloons supporting deletion and photo whisper shapes
│   └── confession_card.dart       <- Playable cards with real-time waveform seek bars
└── screens/
    ├── splash_screen.dart         <- Animated launch gate
    ├── login_screen.dart          <- Access panel with poetic instructions
    ├── signup_screen.dart         <- Onboarding registration forms
    ├── main_navigation_shell.dart <- Unified bottom shell orchestrator
    ├── home_screen.dart           <- Dynamic player hub, 24h streams, and following feeds
    ├── confession_detail_screen.dart <- Waveform controller, UPI tipping, & comments
    ├── explore_screen.dart        <- Multi-filter searches, categories, and calendar strips
    ├── saved_screen.dart          <- Favorited diaries with slidable dismissals
    ├── profile_screen.dart        <- Biographies, statistical counters, and owner diaries
    ├── create_confession_screen.dart <- Sound recorder and multi-step publisher
    ├── settings_screen.dart       <- Identifier adjustments, UPI virtual updates, and logouts
    └── followers_screen.dart      <- Followers & following listings with navigation loops
```

---

## ⚙️ Android Configuration & Release Preparation

The Android wrapper files have been properly audited and upgraded to release-ready state:

*   **Release-ready namespace & package**: Default `com.example` has been completely deleted and replaced with a professional, deployment-ready namespace:
    *   **Application ID / Namespace**: `com.confessions.app` in [build.gradle.kts](android/app/build.gradle.kts)
    *   **MainActivity package structure**: Moved to a clean folder tree `android/app/src/main/kotlin/com/confessions/app/MainActivity.kt`
*   **App Icon & Label**: Set to `"Confessions"` in [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml).
*   **Core Audio Permissions**: Configured permissions required for high-fidelity recording and playback:
    ```xml
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    ```

---

## 🚀 Step-by-Step Installation & Setup

Get "Confessions" running on your local machine or device in minutes:

### Prerequisites
Make sure you have the following installed on your machine:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19 or higher recommended)
*   [Dart SDK](https://dart.dev/get-started)
*   An Android Emulator, iOS Simulator, or physical test device with USB debugging enabled.

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/confessions.git
cd confessions
```

### 2. Install Dependencies
Download and fetch all required packages (including `google_fonts`):
```bash
flutter pub get
```

### 3. Verify Code Health
Run the static analyzer to confirm there are no compilation or syntax errors:
```bash
flutter analyze
```

### 4. Run the App
Launch the codebase on your connected mobile device or emulator in developer mode:
```bash
flutter run
```

---

## 🛠️ Build & Compilation

To generate builds for release, testing, or distribution:

### Android APK Build
Compile a high-performance release APK file:
```bash
flutter build apk --release
```
*The resulting APK will be saved at `build/app/outputs/flutter-apk/app-release.apk`.*

### Android App Bundle (AAB)
To submit the application to the Google Play Store, bundle the assets:
```bash
flutter build appbundle --release
```
*The resulting AAB will be saved at `build/app/outputs/bundle/release/app-release.aab`.*

---

## 🔮 Next Phase: Live Backend Integration
Since this phase focuses exclusively on premium front-end UI and mock state preservation, the code is prepared to easily adopt any backend architecture in the next stage.
*   **Suggested integrations**: Firebase Auth / Firestore, Appwrite Cloud, or custom GraphQL node layers.
*   **Audio Uploading**: Transition `create_confession_screen.dart` uploading pipeline to send the recorded WAV/AAC byte streams directly to an Appwrite Storage bucket or AWS S3, updating user document arrays.
*   **UPI Processing**: Transition our peer-to-peer tip buttons to connect directly to native UPI intent links using custom payment SDK gateways.

---

## 📄 License
This project is licensed under the MIT License — see the `LICENSE` file for details.

*Developed with love, night skies, and untold confessions.* ❤️
