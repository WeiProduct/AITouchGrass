#!/bin/bash

echo "=== Verifying LSApplicationQueriesSchemes Fix ==="
echo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Info.plist exists in correct location
echo "1. Checking Info.plist location..."
if [ -f "AITouchGrass/Info.plist" ]; then
    echo -e "${GREEN}✓ Info.plist found in AITouchGrass directory${NC}"
else
    echo -e "${RED}✗ Info.plist NOT found in AITouchGrass directory${NC}"
    exit 1
fi

# Check if LSApplicationQueriesSchemes is present
echo
echo "2. Checking LSApplicationQueriesSchemes in Info.plist..."
if grep -q "LSApplicationQueriesSchemes" "AITouchGrass/Info.plist"; then
    echo -e "${GREEN}✓ LSApplicationQueriesSchemes found in Info.plist${NC}"
    
    # Count number of schemes
    SCHEME_COUNT=$(xmllint --xpath "count(//key[text()='LSApplicationQueriesSchemes']/following-sibling::array[1]/string)" AITouchGrass/Info.plist 2>/dev/null)
    echo -e "${GREEN}✓ Found $SCHEME_COUNT URL schemes${NC}"
    
    # Show first few schemes
    echo
    echo "First 10 URL schemes:"
    xmllint --xpath "//key[text()='LSApplicationQueriesSchemes']/following-sibling::array[1]/string[position()<=10]/text()" AITouchGrass/Info.plist 2>/dev/null | while read scheme; do
        echo "  - $scheme"
    done
else
    echo -e "${RED}✗ LSApplicationQueriesSchemes NOT found in Info.plist${NC}"
    exit 1
fi

# Check project.pbxproj
echo
echo "3. Checking project.pbxproj configuration..."
if grep -q "INFOPLIST_FILE = AITouchGrass/Info.plist;" "AITouchGrass.xcodeproj/project.pbxproj"; then
    echo -e "${GREEN}✓ project.pbxproj correctly references AITouchGrass/Info.plist${NC}"
else
    echo -e "${RED}✗ project.pbxproj does not reference AITouchGrass/Info.plist${NC}"
    exit 1
fi

# Build and check
echo
echo "4. Building project to verify configuration..."
echo -e "${YELLOW}Building...${NC}"

# Clean build
xcodebuild clean -project AITouchGrass.xcodeproj -scheme AITouchGrass -destination "platform=iOS Simulator,name=iPhone 15" > /dev/null 2>&1

# Build
if xcodebuild build -project AITouchGrass.xcodeproj -scheme AITouchGrass -destination "platform=iOS Simulator,name=iPhone 15" -quiet; then
    echo -e "${GREEN}✓ Build successful${NC}"
    
    # Check if LSApplicationQueriesSchemes is in the built app
    APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/AITouchGrass-*/Build/Products/Debug-iphonesimulator/AITouchGrass.app"
    APP_INFO_PLIST=$(find $APP_PATH -name "Info.plist" 2>/dev/null | head -1)
    
    if [ -f "$APP_INFO_PLIST" ]; then
        echo
        echo "5. Checking compiled app's Info.plist..."
        if plutil -extract LSApplicationQueriesSchemes xml1 "$APP_INFO_PLIST" -o - 2>/dev/null | grep -q "string"; then
            echo -e "${GREEN}✓ LSApplicationQueriesSchemes successfully included in compiled app${NC}"
            
            # Count schemes in compiled app
            COMPILED_SCHEME_COUNT=$(plutil -extract LSApplicationQueriesSchemes raw "$APP_INFO_PLIST" 2>/dev/null | grep -c "^[[:space:]]*[0-9]")
            echo -e "${GREEN}✓ Compiled app contains $COMPILED_SCHEME_COUNT URL schemes${NC}"
        else
            echo -e "${RED}✗ LSApplicationQueriesSchemes NOT found in compiled app${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠ Could not find compiled app's Info.plist${NC}"
    fi
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo
echo -e "${GREEN}=== All checks passed! LSApplicationQueriesSchemes should now work correctly ===${NC}"
echo
echo "Next steps:"
echo "1. Run the app in Xcode"
echo "2. Test app detection functionality"
echo "3. Third-party apps should now be detected properly"