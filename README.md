# moxie_fitness

A new Flutter project.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

## Helpful Commands

### Jaguar Seriazlier

`flutter packages pub run build_runner build`
`flutter packages pub run build_runner watch --delete-conflicting-outputs`

### Updating icon during CI/CD

`flutter packages pub run flutter_launcher_icons:main -f pubspec.yaml`

### Build release apk
- Flutter defaults to release build
1. Update the pubspec.yaml version and versionCode (+#)
<!-- 2. run `flutter clean && flutter build apk` -->
1. To build App Bundle: `flutter build appbundle` 
2. Get apk file from `/build/app/outputs/apk`

### Keytool comands

- Generate SHA for a Keystore (current release)
  - `keytool -exportcert -list -v -alias key -keystore ./android/mf-key.jks`
- Generate for debug.keystore, for when debugging on different PC emulators.
  - `keytool -exportcert -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android`
