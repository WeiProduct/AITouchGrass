# Screen Time API Implementation Guide

## Overview
This guide explains how to properly set up and use the Screen Time API (Family Controls) in AITouchGrass for actual app blocking functionality.

## Implementation Components

### 1. Main App Service
- **File**: `ScreenTimeAppBlockingService.swift`
- **Purpose**: Manages app blocking using ManagedSettingsStore
- **Features**:
  - Authorization handling
  - App selection management
  - Blocking/unblocking functionality
  - Temporary unlock mechanism
  - Integration with DeviceActivity monitoring

### 2. Device Activity Monitor Extension
- **Directory**: `AITouchGrassMonitor/`
- **Main File**: `DeviceActivityMonitor.swift`
- **Purpose**: Monitors app usage and enforces blocking rules
- **Features**:
  - Activity interval monitoring
  - Event threshold handling
  - Warning notifications

### 3. Shield Configuration Extension
- **Directory**: `AITouchGrassShield/`
- **Main File**: `ShieldConfigurationDataSource.swift`
- **Purpose**: Customizes the appearance of blocked apps
- **Features**:
  - Custom shield UI with grass/nature theme
  - Informative messages for users
  - Green color scheme matching app theme

## Setup Instructions

### 1. Add Extension Targets to Xcode Project

#### Device Activity Monitor Extension:
1. In Xcode, go to File → New → Target
2. Choose "Device Activity Monitor Extension"
3. Name it "AITouchGrassMonitor"
4. Set the bundle identifier to: `com.aitouchgrass.AITouchGrassMonitor`
5. Add the files from `AITouchGrassMonitor/` directory

#### Shield Configuration Extension:
1. In Xcode, go to File → New → Target
2. Choose "Shield Configuration Extension"
3. Name it "AITouchGrassShield"
4. Set the bundle identifier to: `com.aitouchgrass.AITouchGrassShield`
5. Add the files from `AITouchGrassShield/` directory

### 2. Configure App Groups
1. In your main app target, go to Signing & Capabilities
2. Add "App Groups" capability
3. Create a new app group: `group.com.aitouchgrass`
4. Enable the same app group for both extensions

### 3. Update Info.plist
Ensure your main app's Info.plist includes:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>This app needs to track app usage to help you manage screen time.</string>
```

### 4. Request Authorization
The app will automatically request Screen Time authorization when:
- The user first attempts to block apps
- The app is launched and detects no authorization

### 5. Testing on Device
**Important**: Screen Time API features only work on real devices, not simulators.

1. Build and run on a physical iOS device (iOS 16.0+)
2. When prompted, approve Screen Time access in Settings
3. Select apps to block using the FamilyActivityPicker
4. Test blocking and unlocking functionality

## Usage Flow

1. **Initial Setup**:
   - App requests Screen Time authorization
   - User approves in Settings app
   - App confirms authorization status

2. **Blocking Apps**:
   - User selects apps via FamilyActivityPicker
   - App applies restrictions using ManagedSettingsStore
   - Device Activity Monitor starts monitoring
   - Selected apps show custom shield when opened

3. **Unlocking Apps**:
   - User captures nature photo
   - App validates the photo
   - Temporary unlock is granted
   - Apps become accessible for specified duration
   - Automatic re-blocking after timeout

## Troubleshooting

### Authorization Issues
- Ensure all entitlements are properly configured
- Check that the device is running iOS 16.0+
- Verify Screen Time is enabled in device settings

### Extensions Not Working
- Clean build folder (Cmd+Shift+K)
- Delete derived data
- Ensure bundle identifiers match exactly
- Check that extensions are embedded in main app

### App Not Blocking
- Verify authorization status in the app
- Check console logs for errors
- Ensure selected apps are installed on device
- Try removing and re-adding app selections

## Important Notes

1. **Simulator Limitations**: The Screen Time API does not work in simulators. Always test on real devices.

2. **Authorization Required**: Users must explicitly grant Screen Time permissions in Settings.

3. **Privacy**: The app cannot see which specific apps are selected due to privacy protections. It only receives opaque tokens.

4. **Extension Communication**: Use App Groups or other IPC mechanisms if you need to share data between the main app and extensions.

## Code Architecture

The implementation follows a clean architecture pattern:

```
ScreenTimeAppBlockingService (Main App)
    ├── Manages FamilyActivitySelection
    ├── Controls ManagedSettingsStore
    ├── Handles authorization
    └── Coordinates with extensions

DeviceActivityMonitor (Extension)
    ├── Monitors app usage events
    ├── Sends notifications
    └── Enforces time-based rules

ShieldConfigurationDataSource (Extension)
    ├── Customizes blocked app UI
    └── Provides user-friendly messages
```

## Next Steps

1. Test the implementation thoroughly on various iOS devices
2. Consider adding more sophisticated scheduling options
3. Implement usage statistics using DeviceActivity reports
4. Add parental control features if needed
5. Submit for App Store review with proper justification for Screen Time API usage