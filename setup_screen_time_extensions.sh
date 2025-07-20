#!/bin/bash

# Script to help set up Screen Time API extensions for AITouchGrass
# This script provides guidance for manual steps needed in Xcode

echo "🌿 AITouchGrass Screen Time API Setup Helper"
echo "==========================================="
echo ""
echo "This script will guide you through setting up the Screen Time API extensions."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📁 Extension files have been created in:${NC}"
echo "   - AITouchGrassMonitor/ (Device Activity Monitor)"
echo "   - AITouchGrassShield/ (Shield Configuration)"
echo ""

echo -e "${YELLOW}⚠️  Manual Steps Required in Xcode:${NC}"
echo ""

echo -e "${GREEN}1. Add Device Activity Monitor Extension:${NC}"
echo "   a. Open AITouchGrass.xcodeproj in Xcode"
echo "   b. File → New → Target"
echo "   c. Search for 'Device Activity Monitor Extension'"
echo "   d. Name: AITouchGrassMonitor"
echo "   e. Bundle ID: com.aitouchgrass.AITouchGrassMonitor"
echo "   f. Language: Swift"
echo "   g. Embed in Application: AITouchGrass"
echo ""

echo -e "${GREEN}2. Add Shield Configuration Extension:${NC}"
echo "   a. File → New → Target"
echo "   b. Search for 'Shield Configuration Extension'"
echo "   c. Name: AITouchGrassShield"
echo "   d. Bundle ID: com.aitouchgrass.AITouchGrassShield"
echo "   e. Language: Swift"
echo "   f. Embed in Application: AITouchGrass"
echo ""

echo -e "${GREEN}3. Replace Default Extension Files:${NC}"
echo "   a. Delete the default files Xcode created for each extension"
echo "   b. Add the files from AITouchGrassMonitor/ to the Monitor target"
echo "   c. Add the files from AITouchGrassShield/ to the Shield target"
echo "   d. Make sure to add them to the correct target membership"
echo ""

echo -e "${GREEN}4. Configure App Groups:${NC}"
echo "   a. Select the main AITouchGrass target"
echo "   b. Go to Signing & Capabilities tab"
echo "   c. Click + Capability → App Groups"
echo "   d. Add group: group.com.aitouchgrass"
echo "   e. Repeat for both extension targets"
echo ""

echo -e "${GREEN}5. Update Bundle Display Names:${NC}"
echo "   a. Select AITouchGrassMonitor target → Info"
echo "   b. Add 'Bundle display name': 'Activity Monitor'"
echo "   c. Select AITouchGrassShield target → Info"
echo "   d. Add 'Bundle display name': 'Touch Grass Shield'"
echo ""

echo -e "${GREEN}6. Verify Entitlements:${NC}"
echo "   - Main app should have all three entitlements:"
echo "     • com.apple.developer.family-controls"
echo "     • com.apple.developer.managed-settings"
echo "     • com.apple.developer.device-activity.monitoring"
echo "   - Monitor extension needs:"
echo "     • com.apple.developer.family-controls"
echo "     • com.apple.developer.device-activity.monitoring"
echo "   - Shield extension needs:"
echo "     • com.apple.developer.family-controls"
echo ""

echo -e "${GREEN}7. Update Deployment Target:${NC}"
echo "   - Set all targets to iOS 16.0 minimum"
echo ""

echo -e "${BLUE}📱 Testing Instructions:${NC}"
echo "1. Clean build folder (Cmd+Shift+K)"
echo "2. Build and run on a REAL DEVICE (not simulator)"
echo "3. When prompted, approve Screen Time access in Settings"
echo "4. Test app blocking functionality"
echo ""

echo -e "${YELLOW}⚠️  Important Notes:${NC}"
echo "• Screen Time API only works on real devices"
echo "• User must grant permission in Settings app"
echo "• Test thoroughly before App Store submission"
echo ""

echo "✅ Setup guide complete! Follow the steps above in Xcode."