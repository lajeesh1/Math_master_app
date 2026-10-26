# Math Master Quiz 🎓✨

A colorful, attractive, and child-friendly Mathematics Quiz Android app built for **4th Standard school students** using Flutter, Dart, and SQLite.

**Developer:** Lajeesh  
**Version:** 1.0.0  
**Platform:** Android (100% Offline, Privacy First)

---

## 🌟 Key Features

- **Four Core Mathematical Operations**:
  - **Multiplication (×)**: Operands from 1 to 10.
  - **Addition (+)**: Operands from 1 to 999.
  - **Subtraction (−)**: Operands from 1 to 999 (`op1 >= op2`, results never negative).
  - **Division (÷)**: Whole-number answers, no remainder, and no division by zero.
- **15 Questions Per Quiz**: Fresh, random, non-repeating questions dynamically generated for each session.
- **Child-Friendly Scoring & Pass/Fail Rules**:
  - Score **> 10** (11–15): **PASSED!** with cheerful congratulations.
  - Score **≤ 10** (0–10): **TRY AGAIN!** with encouraging support.
- **Persistent Local Score History**:
  - Stored locally on the device using SQLite (`sqflite`).
  - Displays score breakdown, percentage, pass/fail status, and local date & time.
  - Single-record delete with confirmation dialog and "Clear All History" feature.
- **100% Offline & Private**: Zero external network calls, zero cloud dependencies, no tracking.

---

## 📱 Tech Stack

- **Flutter 3.47.7** & **Dart 3.13.5** (Material 3)
- **Local Storage**: `sqflite` & `path`
- **Formatting**: `intl`
- **Testing**: `flutter_test` & `sqflite_common_ffi`

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- Android SDK / Android Studio configured

### Installation & Run
1. Clone the repository:
   ```bash
   git clone https://github.com/lajeesh1/Math_master_app.git
   cd Math_master_app
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run automated tests:
   ```bash
   flutter test
   ```

4. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

---

## 📦 Building for Production

### Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (AAB for Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`
