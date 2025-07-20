#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔨 Building AITouchGrass...${NC}"

# Clean build folder
echo "Cleaning build folder..."
rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*

# Build the project
echo "Building project..."
xcodebuild -project AITouchGrass.xcodeproj \
           -scheme AITouchGrass \
           -sdk iphonesimulator \
           -configuration Debug \
           -derivedDataPath build \
           CODE_SIGNING_ALLOWED=NO \
           ONLY_ACTIVE_ARCH=YES \
           build 2>&1 | grep -E "(error:|warning:|SUCCEEDED|FAILED)" || true

# Check if build succeeded
if [ -d "build/Build/Products/Debug-iphonesimulator/AITouchGrass.app" ]; then
    echo -e "${GREEN}✅ Build succeeded!${NC}"
    
    # Install to simulator
    echo "Installing to simulator..."
    xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/AITouchGrass.app
    
    # Launch the app
    echo "Launching app..."
    xcrun simctl launch booted com.yourcompany.AITouchGrass
    
    echo -e "${GREEN}🚀 App launched successfully!${NC}"
else
    echo -e "${RED}❌ Build failed. Opening Xcode...${NC}"
    open AITouchGrass.xcodeproj
fi