# iOS App Detection Troubleshooting Guide

## Problem Summary
Your iOS app can only detect 6 system apps (mailto, tel, sms, http, maps, itms-apps) but cannot detect third-party apps like WeChat, QQ, Alipay even after configuring LSApplicationQueriesSchemes.

## Root Causes & Solutions

### 1. LSApplicationQueriesSchemes Configuration Issues

#### Common Problems:
- **Wrong Info.plist**: Make sure you're editing the app target's Info.plist, not the UI tests target
- **Incorrect Format**: URL schemes must be exact and case-sensitive
- **Missing Schemes**: Some apps have multiple URL schemes that need to be whitelisted

#### Correct Configuration for Chinese Apps:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <!-- WeChat -->
    <string>wechat</string>
    <string>weixin</string>
    <string>weixinULAPI</string>
    
    <!-- QQ -->
    <string>mqqapi</string>
    <string>mqq</string>
    <string>mqqOpensdkSSoLogin</string>
    <string>mqqconnect</string>
    <string>mqqopensdkdataline</string>
    
    <!-- Alipay -->
    <string>alipay</string>
    <string>alipayshare</string>
</array>
```

### 2. iOS Version-Specific Restrictions

#### iOS 15+ Changes:
- **50 Scheme Limit**: LSApplicationQueriesSchemes is now limited to maximum 50 entries
- **Order Matters**: Ensure important schemes are in the first 50 positions
- **No Reset**: The count isn't reset even by restarting device

#### iOS 9+ Restrictions:
- Must declare URL schemes in Info.plist before using canOpenURL
- Without declaration, canOpenURL always returns false for third-party apps
- System apps (tel, sms, mailto) are exempt from this requirement

### 3. Development Build vs App Store Differences

#### Key Differences:
- Development builds may have different entitlements
- TestFlight builds behave differently than local builds
- App Store builds have stricter enforcement

#### Verification Steps:
1. Check console logs for errors:
   ```
   -canOpenURL: failed for URL: 'scheme://' - error: 'This app is not allowed to query for scheme scheme'
   ```
2. Clean build folder and rebuild
3. Delete app from device and reinstall
4. Test on physical device, not simulator

### 4. Alternative Detection Methods

#### Method 1: Skip canOpenURL Check
```swift
// Instead of checking first:
if UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url)
}

// Just open directly:
UIApplication.shared.open(url) { success in
    if success {
        // App is installed and opened
    } else {
        // App is not installed or user cancelled
    }
}
```

#### Method 2: Use Universal Links
- More reliable than custom URL schemes
- Doesn't require LSApplicationQueriesSchemes
- Works seamlessly if app is not installed

### 5. Debugging Checklist

1. **Verify Info.plist**:
   - [ ] Correct Info.plist file (app target, not tests)
   - [ ] LSApplicationQueriesSchemes array exists
   - [ ] URL schemes are correctly spelled
   - [ ] Less than 50 schemes total

2. **Test Environment**:
   - [ ] Test on physical device (not simulator)
   - [ ] Check console logs for specific errors
   - [ ] Try clean build and reinstall
   - [ ] Test with different iOS versions

3. **Code Implementation**:
   - [ ] URL format is correct (e.g., "weixin://")
   - [ ] Using correct API (canOpenURL vs openURL)
   - [ ] Handling completion callbacks properly

### 6. Common Pitfalls

1. **URL Format**: Must include "://" suffix
   ```swift
   // Wrong:
   canOpenURL(URL(string: "weixin")!)
   
   // Correct:
   canOpenURL(URL(string: "weixin://")!)
   ```

2. **Case Sensitivity**: URL schemes are case-sensitive
3. **Build Configuration**: Ensure Info.plist changes are in all build configs
4. **Simulator Testing**: Some behaviors differ on simulator

### 7. Recommended Solution

Given the limitations, the most reliable approach is:

```swift
func openAppOrFallback(urlScheme: String, fallbackURL: String) {
    guard let appURL = URL(string: "\(urlScheme)://") else { return }
    
    UIApplication.shared.open(appURL) { success in
        if !success {
            // App not installed, open App Store or web fallback
            if let url = URL(string: fallbackURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// Usage:
openAppOrFallback(
    urlScheme: "weixin",
    fallbackURL: "https://apps.apple.com/app/wechat/id414478124"
)
```

### 8. Additional Considerations

- **Privacy**: Apple intentionally limits app detection for privacy
- **App Store Review**: Excessive URL scheme checking may cause rejection
- **Future Changes**: Apple may further restrict these APIs
- **Alternative**: Consider server-side detection or user selection

### 9. Testing Protocol

1. Start with a minimal test case (1-2 URL schemes)
2. Verify console output shows no errors
3. Test on physical device with target apps installed
4. Gradually add more schemes up to your needs
5. Document which schemes work/fail for future reference

### 10. If Still Not Working

1. **Verify App Installation**: Manually confirm third-party apps are installed
2. **Check URL Scheme**: Some apps may have changed their URL schemes
3. **iOS Version**: Check if issue is specific to iOS version
4. **Contact App Developers**: Verify current URL schemes with app developers
5. **File Bug Report**: If system apps work but third-party apps don't with correct config

This issue is often related to incorrect configuration or iOS privacy restrictions rather than a bug in your code. Following these steps should help identify and resolve the problem.