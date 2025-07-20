# LSApplicationQueriesSchemes Solution Guide

## Problem Summary
Your app is only detecting 6 system apps despite having LSApplicationQueriesSchemes configured. This is because:
1. Your project uses `GENERATE_INFOPLIST_FILE = YES` (auto-generated Info.plist)
2. LSApplicationQueriesSchemes is not being included in the generated Info.plist
3. iOS simulator may have additional restrictions

## Solution Options

### Option 1: Add Custom Info.plist (Recommended)
I've created a custom Info.plist file at `/AITouchGrass/Info.plist` with all the URL schemes.

**Steps to implement:**
1. In Xcode, select your project target
2. Go to "Build Settings"
3. Search for "GENERATE_INFOPLIST_FILE"
4. Change it from "YES" to "NO"
5. Search for "INFOPLIST_FILE"
6. Set it to "AITouchGrass/Info.plist"
7. Clean build folder (Cmd+Shift+K)
8. Build and run

### Option 2: Use Build Settings (For Auto-Generated Info.plist)
If you want to keep using auto-generated Info.plist:

1. Run the fix script:
   ```bash
   ./fix_lsapplicationqueriesschemes.sh
   ```

2. Or manually in Xcode:
   - Select your project target
   - Go to "Build Settings"
   - Click the "+" button at the bottom
   - Add "INFOPLIST_KEY_LSApplicationQueriesSchemes"
   - Set it as an array with all the URL schemes

### Option 3: Alternative Detection Methods
Since iOS has restrictions, consider these alternatives:

1. **Skip canOpenURL check** - Directly try to open URLs:
   ```swift
   UIApplication.shared.open(url, options: [:]) { success in
       // App is installed if success is true
   }
   ```

2. **Use App Groups** - If you control multiple apps
3. **Server-side detection** - Track app installations server-side

## Verification Steps

### 1. Check Compiled Info.plist
After building, verify the Info.plist in the app bundle:
```bash
# Find the built app
find ~/Library/Developer/Xcode/DerivedData -name "AITouchGrass.app" -type d

# Check the Info.plist
plutil -p [path-to-app]/Info.plist | grep -A 50 LSApplicationQueriesSchemes
```

### 2. Test Detection
```swift
// Test a specific URL scheme
let url = URL(string: "weixin://")!
let canOpen = UIApplication.shared.canOpenURL(url)
print("Can open WeChat: \(canOpen)")
```

### 3. Console Logs
Check Xcode console for these messages:
- If you see "-canOpenURL: failed for URL: "xxx://" - error: "This app is not allowed to query for scheme xxx"" - the scheme is not in LSApplicationQueriesSchemes
- If canOpenURL returns false with no error - the app is not installed

## Important Notes

1. **50 URL Scheme Limit**: iOS 15+ limits LSApplicationQueriesSchemes to 50 entries
2. **Simulator Limitations**: Some URL schemes may not work properly in simulator
3. **Case Sensitivity**: URL schemes are case-sensitive
4. **Format**: Use only the scheme part (e.g., "weixin" not "weixin://")

## Common Issues

### Issue 1: Still Only Detecting System Apps
**Cause**: LSApplicationQueriesSchemes not properly configured
**Fix**: Use Option 1 (custom Info.plist) and verify it's included in the build

### Issue 2: canOpenURL Always Returns False
**Cause**: Missing from LSApplicationQueriesSchemes or app not installed
**Fix**: Add the scheme to Info.plist and test on real device

### Issue 3: Works on Device but Not Simulator
**Cause**: Simulator doesn't have third-party apps installed
**Fix**: Test on real device with apps installed

## Testing Code
```swift
// Test all configured schemes
let schemes = ["weixin", "mqq", "alipay", "taobao", "snssdk1128"]
for scheme in schemes {
    if let url = URL(string: "\(scheme)://") {
        let canOpen = UIApplication.shared.canOpenURL(url)
        print("\(scheme): \(canOpen ? "✅ Installed" : "❌ Not installed")")
    }
}
```

## Alternative Implementation
If LSApplicationQueriesSchemes continues to fail, use the bypass method in `bypass_lsapplicationqueriesschemes.swift` which uses `openURL` instead of `canOpenURL`.