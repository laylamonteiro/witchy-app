#!/bin/bash
echo "=== Limpeza completa do projeto ==="
flutter clean

echo ""
echo "=== Removendo build Android ==="
rm -rf build/
rm -rf android/.gradle
rm -rf android/app/build

echo ""
echo "=== Obtendo dependências ==="
flutter pub get

echo ""
echo "=== Gerando APK release ==="
flutter build apk --release

echo ""
echo "=== APK gerado em: ==="
ls -lh build/app/outputs/flutter-apk/app-release.apk
