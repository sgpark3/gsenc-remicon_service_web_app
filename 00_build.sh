echo "Building Android APK..."
fvm flutter build apk --release --target-platform android-arm,android-arm64,android-x64

# aapt 사용 (Android SDK build-tools)
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep native-code
# 예시 출력: native-code: 'armeabi-v7a' 'arm64-v8a' 'x86_64'