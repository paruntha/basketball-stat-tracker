#!/bin/bash

# Basketball Stat Tracker - Quick Setup Script

echo "🏀 Basketball Stat Tracker Setup"
echo "================================="
echo ""

# Check Flutter installation
echo "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -1)"
echo ""

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to get dependencies"
    exit 1
fi

echo "✅ Dependencies installed"
echo ""

# Check for Firebase CLI
echo "Checking Firebase CLI..."
if command -v flutterfire &> /dev/null; then
    echo "✅ FlutterFire CLI found"
    echo ""
    echo "📝 Do you want to configure Firebase now? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Running flutterfire configure..."
        flutterfire configure
    else
        echo "⏭️  Skipping Firebase setup (app will work with local storage only)"
    fi
else
    echo "⚠️  FlutterFire CLI not found"
    echo "   App will work with local storage only"
    echo "   To enable cloud sync later, run:"
    echo "   dart pub global activate flutterfire_cli"
    echo "   flutterfire configure"
fi

echo ""
echo "================================="
echo "✅ Setup Complete!"
echo ""
echo "To run the app:"
echo "  flutter run                 # Default device"
echo "  flutter run -d android      # Android"
echo "  flutter run -d ios          # iOS"
echo "  flutter run -d chrome       # Web"
echo "  flutter run -d macos        # macOS"
echo "  flutter run -d windows      # Windows"
echo ""
echo "🏀 Happy tracking!"
