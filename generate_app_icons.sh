#!/bin/bash

# App Icon Generator Script for iOS
# This script generates all required icon sizes for iOS apps

SOURCE_IMAGE="/Users/weifu/Desktop/AITouchGrass/AppIcon.png"
ICON_SET_PATH="/Users/weifu/Desktop/AITouchGrass/AITouchGrass/Assets.xcassets/AppIcon.appiconset"

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image not found at $SOURCE_IMAGE"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Installing ImageMagick..."
    brew install imagemagick
fi

echo "Generating iOS app icons..."

# iPhone icons
convert "$SOURCE_IMAGE" -resize 40x40 "$ICON_SET_PATH/icon-40.png"
convert "$SOURCE_IMAGE" -resize 60x60 "$ICON_SET_PATH/icon-60.png"
convert "$SOURCE_IMAGE" -resize 58x58 "$ICON_SET_PATH/icon-58.png"
convert "$SOURCE_IMAGE" -resize 87x87 "$ICON_SET_PATH/icon-87.png"
convert "$SOURCE_IMAGE" -resize 80x80 "$ICON_SET_PATH/icon-80.png"
convert "$SOURCE_IMAGE" -resize 120x120 "$ICON_SET_PATH/icon-120.png"
convert "$SOURCE_IMAGE" -resize 180x180 "$ICON_SET_PATH/icon-180.png"

# iPad icons
convert "$SOURCE_IMAGE" -resize 20x20 "$ICON_SET_PATH/icon-20.png"
convert "$SOURCE_IMAGE" -resize 40x40 "$ICON_SET_PATH/icon-40.png"
convert "$SOURCE_IMAGE" -resize 76x76 "$ICON_SET_PATH/icon-76.png"
convert "$SOURCE_IMAGE" -resize 152x152 "$ICON_SET_PATH/icon-152.png"
convert "$SOURCE_IMAGE" -resize 167x167 "$ICON_SET_PATH/icon-167.png"

# App Store icon
convert "$SOURCE_IMAGE" -resize 1024x1024 "$ICON_SET_PATH/icon-1024.png"

# Create Contents.json
cat > "$ICON_SET_PATH/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "icon-40.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-60.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-58.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-87.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-80.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-120.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-120.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "icon-180.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "icon-20.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-40.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-58.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-58.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-40.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-80.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-76.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "icon-152.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "icon-167.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "icon-1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ App icons generated successfully!"
echo "Icons saved to: $ICON_SET_PATH"