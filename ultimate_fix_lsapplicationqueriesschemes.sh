#!/bin/bash

echo "Ultimate fix for LSApplicationQueriesSchemes..."

# Clean everything
echo "Cleaning all build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*

# Remove the old Info.plist that's causing conflicts
rm -f AITouchGrass/Info.plist

# Create Info.plist in project root (not in AITouchGrass folder)
echo "Creating Info.plist in project root..."
cat > Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<true/>
		<key>UISceneConfigurations</key>
		<dict/>
	</dict>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>NSCameraUsageDescription</key>
	<string>AITouchGrass需要访问相机来拍摄自然景观，用于验证草地、天空等自然元素，从而解锁被限制的应用。</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>AITouchGrass需要访问照片库来选择包含自然景观的图片，用于验证草地、天空等自然元素，从而解锁被限制的应用。</string>
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>weixin</string>
		<string>wechat</string>
		<string>weixinULAPI</string>
		<string>mqq</string>
		<string>mqqapi</string>
		<string>mqqwpa</string>
		<string>mqqOpensdkSSoLogin</string>
		<string>mqqconnect</string>
		<string>alipay</string>
		<string>alipayshare</string>
		<string>sinaweibo</string>
		<string>weibosdk</string>
		<string>taobao</string>
		<string>tmall</string>
		<string>zhihu</string>
		<string>pinduoduo</string>
		<string>snssdk1128</string>
		<string>bilibili</string>
		<string>kwai</string>
		<string>orpheus</string>
		<string>qqmusic</string>
		<string>iosamap</string>
		<string>baidumap</string>
		<string>imeituan</string>
		<string>eleme</string>
		<string>diditaxi</string>
		<string>openapp.jdmobile</string>
		<string>baiduboxapp</string>
		<string>dingtalk</string>
		<string>wxwork</string>
		<string>instagram</string>
		<string>whatsapp</string>
		<string>youtube</string>
		<string>fb</string>
		<string>twitter</string>
		<string>tg</string>
		<string>googlechrome</string>
		<string>spotify</string>
		<string>snapchat</string>
		<string>linkedin</string>
		<string>discord</string>
		<string>uber</string>
		<string>prefs</string>
		<string>mailto</string>
		<string>tel</string>
		<string>sms</string>
		<string>http</string>
		<string>maps</string>
		<string>itms-apps</string>
	</array>
</dict>
</plist>
EOF

# Update project.pbxproj to use the Info.plist in root
echo "Updating project.pbxproj..."
sed -i '' 's|INFOPLIST_FILE = AITouchGrass/Info.plist;|INFOPLIST_FILE = Info.plist;|g' AITouchGrass.xcodeproj/project.pbxproj

# Build the project
echo "Building project..."
xcodebuild -project AITouchGrass.xcodeproj -scheme AITouchGrass -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' clean build 2>&1 | tail -100

# Verify
echo ""
echo "Verifying LSApplicationQueriesSchemes in compiled app..."
plutil -p ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*/Build/Products/Debug-iphonesimulator/AITouchGrass.app/Info.plist | grep -A 55 LSApplicationQueriesSchemes || echo "LSApplicationQueriesSchemes not found!"

echo ""
echo "Done! Now run the app in the simulator to test."