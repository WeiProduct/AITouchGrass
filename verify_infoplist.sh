#!/bin/bash

echo "=== Verifying Info.plist Configuration ==="
echo ""

# Find the most recent build
DERIVED_DATA_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "AITouchGrass-*" -type d | head -1)

if [ -z "$DERIVED_DATA_PATH" ]; then
    echo "❌ No DerivedData found. Please build the app first."
    exit 1
fi

echo "Found DerivedData at: $DERIVED_DATA_PATH"
echo ""

# Find the app bundle
APP_PATH=$(find "$DERIVED_DATA_PATH" -name "AITouchGrass.app" -type d | grep -E "Debug|Release" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ No app bundle found. Please build the app first."
    exit 1
fi

echo "Found app bundle at: $APP_PATH"
echo ""

PLIST_PATH="$APP_PATH/Info.plist"

if [ ! -f "$PLIST_PATH" ]; then
    echo "❌ Info.plist not found in app bundle"
    exit 1
fi

echo "=== Checking LSApplicationQueriesSchemes ==="
echo ""

# Check if LSApplicationQueriesSchemes exists
if plutil -p "$PLIST_PATH" | grep -q "LSApplicationQueriesSchemes"; then
    echo "✅ LSApplicationQueriesSchemes found!"
    echo ""
    echo "URL Schemes configured:"
    plutil -p "$PLIST_PATH" | grep -A 100 "LSApplicationQueriesSchemes" | grep -E "^\s+[0-9]+ =>" | sed 's/.*=> "\(.*\)"/  - \1/'
    
    # Count schemes
    COUNT=$(plutil -p "$PLIST_PATH" | grep -A 100 "LSApplicationQueriesSchemes" | grep -E "^\s+[0-9]+ =>" | wc -l)
    echo ""
    echo "Total schemes: $COUNT"
else
    echo "❌ LSApplicationQueriesSchemes NOT FOUND in compiled Info.plist"
    echo ""
    echo "This is why the app can only detect system URL schemes!"
    echo ""
    echo "To fix this:"
    echo "1. Option A: Use the custom Info.plist file created at AITouchGrass/Info.plist"
    echo "2. Option B: Add INFOPLIST_KEY_LSApplicationQueriesSchemes to build settings"
fi

echo ""
echo "=== Other Info.plist Contents ==="
echo ""
echo "Bundle ID: $(plutil -p "$PLIST_PATH" | grep CFBundleIdentifier | cut -d'"' -f4)"
echo "Version: $(plutil -p "$PLIST_PATH" | grep CFBundleShortVersionString | cut -d'"' -f4)"

# Check for GENERATE_INFOPLIST_FILE setting
echo ""
echo "=== Build Settings Check ==="
PROJECT_FILE="AITouchGrass.xcodeproj/project.pbxproj"
if grep -q "GENERATE_INFOPLIST_FILE = YES" "$PROJECT_FILE"; then
    echo "⚠️  GENERATE_INFOPLIST_FILE is set to YES"
    echo "   This means Info.plist is auto-generated"
    echo "   You need to either:"
    echo "   - Set GENERATE_INFOPLIST_FILE to NO and use custom Info.plist"
    echo "   - Add INFOPLIST_KEY_LSApplicationQueriesSchemes to build settings"
fi