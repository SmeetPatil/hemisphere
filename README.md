# Hemisphere 🌍

> *Build a Better Community. Connect, engage, and manage your neighborhood safety securely. Hemisphere empowers you to share insights, alert your community, and make your local surroundings safer for everyone.*

Hemisphere is a comprehensive Flutter-based mobile application designed to foster community engagement, enhance local safety, and promote environmental consciousness through AI-driven insights.

## ✨ Key Features

- **Community Hub & Chat**: Real-time messaging and community engagement. Share alerts, reports, and have 1-on-1 conversations with neighbors.
- **Interactive Map & GPS**: Powered by `flutter_map` and Mapbox, instantly fetch your location to pin reports, incidents, or community events with precise GPS tracking.
- **SOS & Safety Reporting**: Quick-access SOS forms with automatic location tagging to alert the community and emergency contacts of immediate dangers.
- **AI-Powered Capabilities**: Integrated on-device machine learning (via TensorFlow Lite) and cloud AI for multi-modal analysis (safety scoring, emission tracking, and waste classification).
- **Emissions Logger**: Track your carbon footprint with dedicated eco-logging tools and animated UI feedback.
- **Custom Design System**: A beautifully crafted UI utilizing custom typography (*ClashDisplay* & *Satoshi*) and a bespoke color palette with robust theming support.

---

## 🧠 Machine Learning Models

Hemisphere leverages local `tflite` models to process data privately and efficiently on the device:

- `safety_model.tflite`: Assesses neighborhood safety metrics based on user-provided environmental inputs or historical data.
- `garbage_classification_model.tflite`: An image classification model designed to detect and categorize neighborhood waste, streamlining community cleanup efforts.
- `emissions_model.tflite` & `emissions_model_2.tflite`: Neural networks tailored to estimate and log carbon emissions from vehicular activity or daily routines.

*Note: The app also integrates with external LLM via Groq for advanced natural language processing tasks.*

---

## 📁 Directory Structure

```text
hemisphere/
├── android/                 # Native Android build configurations
├── ios/                     # Native iOS build configurations
├── assets/                  # Static assets
│   ├── fonts/               # Custom fonts (ClashDisplay, Satoshi)
│   ├── images/              # SVG & PNG illustrations (e.g., logo.png)
│   └── models/              # On-device TensorFlow Lite models (*.tflite)
├── lib/                     # Main Flutter application code
│   ├── data/                # Local data layers and repositories
│   ├── models/              # Dart data classes and entities
│   ├── providers/           # State management (ChangeNotifiers/Providers)
│   ├── screens/             # UI Screens
│   │   ├── auth/            # Login and authentication flow
│   │   ├── community/       # Post creation, feeds, and chat interfaces
│   │   ├── inbox/           # Messaging hub
│   │   ├── map/             # Mapbox map views
│   │   ├── profile/         # User profile, settings, and emission logger
│   │   └── report/          # SOS and incident reporting handlers
│   ├── services/            # Firebase, Auth, and external API integrations
│   ├── theme/               # App colors, text styles, and Theme configuration
│   ├── widgets/             # Reusable UI components (buttons, animators, etc.)
│   └── main.dart            # Application entry point
├── build_app.ps1            # Custom PowerShell release & debug build script
├── firebase.json            # Firebase CLI configuration
├── pubspec.yaml             # Dart dependencies and asset declarations
└── .env                     # Environment variables (API Keys, Tokens)
```

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend & Auth**: [Firebase Auth](https://firebase.google.com/docs/auth) & [Cloud Firestore](https://firebase.google.com/docs/firestore)
- **Maps & Geolocation**: `flutter_map`, `latlong2`, `geolocator`, Mapbox APIs
- **Machine Learning**: `tflite_flutter`
- **State Management**: `provider` (and internal `ValueNotifier`)
- **Iconography/Assets**: `flutter_launcher_icons`, `flutter_native_splash`, `flutter_svg`

---

## 🚀 Getting Started

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version ^3.11.1)
2. Setup Android Studio / Xcode for native compilation.
3. Ensure you have your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in their respective directories for Firebase access.

### Environment Setup
Create a `.env` file in the root of your project with the following keys:
```env
GROQ_API_KEY=your_groq_key
MAPBOX_ACCESS_TOKEN=your_mapbox_token
```

### Running the App
```bash
# Get all dependencies
flutter pub get

# Run on an attached device
flutter run
```

### Building for Release
Use the bundled PowerShell script to automatically bump the version, obfuscate dart code, build the APK, and hide debug symbols:
```powershell
.\build_app.ps1 -Release
```
The compiled APK will be located at `build\app\outputs\flutter-apk\app-release.apk`.

