# LSApplicationQueriesSchemes Fix Summary

## Problem
The app could only detect 6 system apps (Settings, Safari, Maps, Mail, Phone, Messages) but returned "Cannot open" for all third-party apps like WeChat, QQ, Alipay, etc.

## Root Cause
LSApplicationQueriesSchemes was not being properly included in the compiled app's Info.plist, even though it was configured in the project settings. The auto-generated Info.plist approach wasn't including the URL schemes array correctly.

## Solution Implemented

### 1. Created a Custom Info.plist
Created a proper Info.plist file in the project root with the following structure:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Standard app configuration -->
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <!-- ... other standard keys ... -->
    
    <!-- Critical: LSApplicationQueriesSchemes array -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>weixin</string>
        <string>wechat</string>
        <string>weixinULAPI</string>
        <string>mqq</string>
        <string>mqqapi</string>
        <!-- ... 44 more URL schemes ... -->
    </array>
    
    <!-- Permission descriptions -->
    <key>NSCameraUsageDescription</key>
    <string>AITouchGrass需要访问相机来拍摄自然景观...</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>AITouchGrass需要访问照片库来选择包含自然景观的图片...</string>
</dict>
</plist>
```

### 2. Updated Project Configuration
Modified the project.pbxproj to:
- Set `GENERATE_INFOPLIST_FILE = NO` (disable auto-generation)
- Set `INFOPLIST_FILE = Info.plist` (use custom Info.plist)
- Removed the INFOPLIST_KEY_LSApplicationQueriesSchemes entries

### 3. Verified the Fix
After rebuilding, verified that LSApplicationQueriesSchemes is now properly included in the compiled app bundle at:
`~/Library/Developer/Xcode/DerivedData/AITouchGrass-*/Build/Products/Debug-iphonesimulator/AITouchGrass.app/Info.plist`

The compiled Info.plist now contains all 49 URL schemes.

## Key Insights from Research

1. **50 Scheme Limit**: iOS 15+ limits LSApplicationQueriesSchemes to 50 entries maximum
2. **No Runtime Changes**: LSApplicationQueriesSchemes cannot be modified at runtime
3. **Exact Scheme Names**: Must use exact scheme names without "://" suffix
4. **Build Cache Issues**: Sometimes requires cleaning DerivedData for changes to take effect
5. **Info.plist Location**: Must be in the main app target, not in test targets or frameworks

## Testing Steps

1. Clean build folder and DerivedData
2. Build and run the app
3. Go to app selection screen
4. Verify third-party apps now show their correct status instead of "Cannot open"

## Files Created/Modified

1. `/Info.plist` - Custom Info.plist with LSApplicationQueriesSchemes
2. `/AITouchGrass.xcodeproj/project.pbxproj` - Updated to use custom Info.plist
3. Various fix scripts created during troubleshooting (can be removed)

The app should now properly detect installed third-party apps using the configured URL schemes.