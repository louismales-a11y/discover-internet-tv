#!/bin/bash
cd "$(dirname "$0")"

# Auto-increment version
OLD_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
MAJOR=$(echo $OLD_VERSION | cut -d'.' -f1)
MINOR=$(echo $OLD_VERSION | cut -d'.' -f2)
PATCH=$(echo $OLD_VERSION | cut -d'+' -f1 | cut -d'.' -f3)
BUILD=$(echo $OLD_VERSION | cut -d'+' -f2)
NEW_BUILD=$((BUILD + 1))
NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}+${NEW_BUILD}"

sed -i "s/version: ${OLD_VERSION}/version: ${NEW_VERSION}/" pubspec.yaml

JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"
ANDROID_SDK_ROOT="/c/Users/lousc/AppData/Local/Android/Sdk"
FLUTTER_ROOT="/c/Users/lousc/Downloads/flutter_windows_3.44.2-stable/flutter"
PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$FLUTTER_ROOT/bin:$PATH"

echo "══════════════════════════════════════════════════"
echo "  Discover Internet TV — Build v${NEW_VERSION}"
echo "  (was v${OLD_VERSION})"
echo "══════════════════════════════════════════════════"

# Android
echo "🔨 Building Android APK..."
flutter build apk --release 2>&1 | tail -1
if [ $? -eq 0 ]; then
  cp build/app/outputs/flutter-apk/app-release.apk "build/app/outputs/flutter-apk/Discover-Internet-TV-v${NEW_VERSION}.apk"
  echo "✅ Android: Discover-Internet-TV-v${NEW_VERSION}.apk"
else
  echo "❌ Android build failed"
fi

# Windows
echo ""
echo "🔨 Building Windows EXE..."
flutter build windows --release 2>&1 | tail -1
if [ $? -eq 0 ]; then
  cd build/windows/x64/runner
  tar -czf "Discover-Internet-TV-Windows-v${NEW_VERSION}.tar.gz" Release/
  echo "✅ Windows: Discover-Internet-TV-Windows-v${NEW_VERSION}.tar.gz"
  cd ../../../..
else
  echo "❌ Windows build failed"
fi

echo ""
echo "══════════════════════════════════════════════════"
echo "  Build Complete — v${NEW_VERSION}"
echo "══════════════════════════════════════════════════"
ls -lh build/app/outputs/flutter-apk/Discover-Internet-TV-v${NEW_VERSION}.apk
ls -lh build/windows/x64/runner/Discover-Internet-TV-Windows-v${NEW_VERSION}.tar.gz 2>/dev/null
