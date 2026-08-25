# 🧮 Flutter Calculator App

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-%5E3.8.1-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)

A beautiful, robust, and native-feeling Calculator application built with Flutter. Designed with a clean modern aesthetic, snappy animations, and bulletproof state management that handles edge cases flawlessly.

## ✨ Features

- **Native UI/UX:** Active operator highlighting that elegantly transitions as you type, mirroring the premium feel of native OS calculators.
- **Robust Math Engine:** Safely handles edge cases like division-by-zero, chained operations, percentage calculations, and multiple `=` presses without breaking sweat.
- **Adaptive Theming:** Clean Material UI that leverages `Theme.of(context)` for seamless dynamic styling and colors.
- **State Management:** Powered by `Provider` for highly responsive, decoupled, and testable business logic.
- **Precision Formatting:** Automatically strips redundant trailing decimals and formats large numbers cleanly.

## 📸 Screenshots
*(Add your screenshots here! E.g., `![Light Mode](screenshots/light.png)`)*

## 🚀 Getting Started

To run this project on your local machine, ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

### 1. Clone the repository
```bash
git clone https://github.com/sakib-codes/calculator_app.git
cd calculator_app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the app
```bash
flutter run
```

## 🛠️ Tech Stack & Architecture
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Architecture:** Separated UI and Business Logic (`screens/`, `widgets/`, `providers/`)
- **Android Target:** Modern AGP 9.0+ compatibility with Kotlin 2.3.20

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/sakib-codes/calculator_app/issues).

## 📝 License
This project is open-source and available under the MIT License.