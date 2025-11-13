# SDK Configuration Guide for Health Records App

## 📱 Current SDK Setup

### **Dart SDK** ✅
```yaml
environment:
  sdk: ^3.9.2
```
- **Version**: Dart 3.9.2 or higher
- **Type**: Stable channel
- **Features**: Null safety enabled, Latest Dart features

---

## 🤖 Android SDK Configuration

### **Gradle Build Configuration**
Located in: `android/app/build.gradle.kts`

```kotlin
android {
    namespace = "com.example.student_records_app"
    compileSdk = flutter.compileSdkVersion        // Dynamic - from Flutter
    ndkVersion = flutter.ndkVersion                // Dynamic - from Flutter

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.student_records_app"
        minSdk = flutter.minSdkVersion             // Dynamic - from Flutter
        targetSdk = flutter.targetSdkVersion       // Dynamic - from Flutter
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

### **Key Android Settings**

| Setting | Value | Meaning |
|---------|-------|---------|
| **compileSdk** | flutter.compileSdkVersion | Android API level to compile against (Latest) |
| **minSdk** | flutter.minSdkVersion | Minimum Android version supported (~API 21: Android 5.0) |
| **targetSdk** | flutter.targetSdkVersion | Target Android version (Latest) |
| **Java Version** | 11 | Java language compatibility level |
| **Kotlin Version** | Latest | Kotlin language version |
| **NDK Version** | flutter.ndkVersion | Native Development Kit for native code |

### **Dynamic Values (From Flutter)**
Flutter automatically provides these values:
- `compileSdkVersion` - Latest supported API level
- `minSdkVersion` - Minimum API 21 (Android 5.0 Lollipop)
- `targetSdkVersion` - Latest API level
- `ndkVersion` - Latest NDK version

---

## 🍎 iOS SDK Configuration

### **Deployment Target**
Located in: `ios/Podfile` and `ios/Runner.xcodeproj`

**Default iOS Deployment Target**: iOS 12.0 or later

```ruby
# In ios/Podfile (Cocoapods configuration)
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

### **Key iOS Settings**

| Setting | Value | Meaning |
|---------|-------|---------|
| **Deployment Target** | 12.0+ | Minimum iOS version (iPhone 5s and later) |
| **Xcode Version** | Latest | Build tool requirement |
| **Swift Version** | 5.0+ | Swift language version |
| **Architecture** | arm64 | 64-bit ARM (standard for modern iOS) |

---

## 🌐 Web SDK Configuration

### **Dart/Flutter for Web**
- **Browser Support**: Modern browsers (Chrome, Firefox, Safari, Edge)
- **JavaScript Runtime**: Uses Dart2JS compiler
- **Target**: HTML5 Canvas with WebGL support

```yaml
# pubspec.yaml configuration
flutter:
  uses-material-design: true
```

---

## 📦 Supported Platforms

| Platform | Min Version | Target Version | Status |
|----------|------------|-----------------|--------|
| **Android** | 5.0 (API 21) | Latest (API 35+) | ✅ Supported |
| **iOS** | 12.0 | Latest (17.0+) | ✅ Supported |
| **Web** | Chrome 90+ | All modern browsers | ✅ Supported |
| **Windows** | Windows 10 | Windows 11+ | ✅ Supported |
| **macOS** | 10.14+ | 14.0+ | ✅ Supported |
| **Linux** | Ubuntu 18.04+ | Ubuntu 22.04+ | ✅ Supported |

---

## 🔧 How to Check Your SDK Versions

### **Check Installed Dart SDK**
```powershell
dart --version
```

### **Check Flutter SDK**
```powershell
flutter --version
```

### **Check Android SDK**
```powershell
flutter doctor
```

**Output Example:**
```
[✓] Flutter (Channel stable, 3.16.5, on Windows 11)
[✓] Android toolchain - develop for Android devices
    • Android SDK at C:\Android\sdk
    • Platform android-34
    • Build-tools 34.0.0
    • Android NDK: 26.1.10909125
[✓] Xcode - develop for iOS and macOS
    • Xcode 15.0.1
```

### **Check All SDKs Installed**
```powershell
flutter doctor -v
```

---

## 📝 Configuration Files

### **1. pubspec.yaml**
- **Location**: Root of project
- **Purpose**: Dart/Flutter dependencies and project metadata
- **Dart SDK**: `environment: sdk: ^3.9.2`

### **2. android/app/build.gradle.kts**
- **Location**: Android build configuration
- **Purpose**: Android-specific build settings
- **Controls**: compileSdk, minSdk, targetSdk, Java version

### **3. ios/Podfile**
- **Location**: iOS dependency management
- **Purpose**: iOS dependencies and build configuration
- **Controls**: iOS deployment target, Cocoapods packages

### **4. ios/Runner.xcodeproj/project.pbxproj**
- **Location**: Xcode project file
- **Purpose**: Low-level iOS build settings
- **Controls**: Code signing, build phases, compiler settings

### **5. android/settings.gradle.kts**
- **Location**: Android settings
- **Purpose**: Gradle project configuration and plugins

---

## 🎯 Recommended SDK Versions

### **For Development**
```
Flutter: 3.16.5+ (Stable)
Dart: 3.9.2+
Android SDK: API 34 (Android 14)
iOS: 14.0+
```

### **For Production Release**
```
Minimum Android: API 21 (Android 5.0)
Minimum iOS: 12.0
Target Android: API 34+
Target iOS: 14.0+
```

---

## 🚀 Upgrading SDKs

### **Upgrade Flutter**
```powershell
flutter upgrade
```

### **Upgrade Dart SDK** (comes with Flutter)
```powershell
flutter upgrade
```

### **Upgrade Android SDK**
1. Open Android Studio
2. Go to SDK Manager
3. Update Android SDK Platform
4. Update Android SDK Build-Tools

### **Upgrade iOS SDK**
1. Update Xcode from App Store
2. Run: `pod repo update`
3. Run: `pod install` in ios/

---

## ⚠️ Important Notes

### **Dynamic SDK Values**
Your project uses **Flutter's dynamic SDK values**:
- `flutter.compileSdkVersion`
- `flutter.minSdkVersion`
- `flutter.targetSdkVersion`
- `flutter.ndkVersion`

This means **automatically compatible** with latest Android versions when you update Flutter!

### **Java Version**
Set to **Java 11** for Kotlin compatibility and modern features

### **Architecture**
Android: **arm64 + armv7** (32-bit and 64-bit support)  
iOS: **arm64** only (64-bit)

---

## 🔍 Verification Commands

### **Verify All SDKs Installed Correctly**
```powershell
flutter doctor
```

✅ Should show green checkmarks for:
- Flutter
- Android toolchain
- Xcode (if on macOS)
- VS Code / Android Studio
- Connected device or emulator

### **Verify Project Compatibility**
```powershell
flutter analyze
```

### **Test Build**
```powershell
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

---

## 📊 SDK Summary for Your Project

```
┌─────────────────────────────────────┐
│   HEALTH RECORDS APP - SDK SETUP    │
├─────────────────────────────────────┤
│ Dart SDK:     ^3.9.2               │
│ Android Min:  API 21 (5.0)         │
│ Android Target: Latest (API 34+)   │
│ iOS Min:      12.0                 │
│ Java:         11                   │
│ Kotlin:       Latest               │
│ Architecture: arm64 (64-bit)       │
└─────────────────────────────────────┘
```

