#!/bin/bash

# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*

# Open Xcode with the project
open AITouchGrass.xcodeproj

echo "Project opened in Xcode."
echo "Please run the project in Xcode by pressing Cmd+R"
echo ""
echo "If you encounter any issues:"
echo "1. Make sure a simulator is selected (e.g., iPhone 16 Pro)"
echo "2. Clean the build folder: Product > Clean Build Folder (Cmd+Shift+K)"
echo "3. Build and run: Product > Run (Cmd+R)"