#!/bin/bash

# Script to properly fix LSApplicationQueriesSchemes configuration

echo "Fixing LSApplicationQueriesSchemes configuration..."

# Clean build folder
echo "Cleaning build folder..."
rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*

# Create a proper Info.plist file
echo "Creating Info.plist with LSApplicationQueriesSchemes..."
cat > AITouchGrass/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
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

# Update project.pbxproj to use Info.plist instead of generating it
echo "Updating project.pbxproj to use Info.plist..."
sed -i '' 's/GENERATE_INFOPLIST_FILE = YES;/GENERATE_INFOPLIST_FILE = NO;\
				INFOPLIST_FILE = AITouchGrass\/Info.plist;/g' AITouchGrass.xcodeproj/project.pbxproj

# Remove the INFOPLIST_KEY_LSApplicationQueriesSchemes lines since we're using Info.plist
sed -i '' '/INFOPLIST_KEY_LSApplicationQueriesSchemes/d' AITouchGrass.xcodeproj/project.pbxproj

# Add the Info.plist to the project files if not already there
if ! grep -q "Info.plist" AITouchGrass.xcodeproj/project.pbxproj; then
    # This is more complex and would require proper PBXFileReference addition
    echo "Note: You may need to manually add Info.plist to the project in Xcode"
fi

echo "Building project..."
xcodebuild -project AITouchGrass.xcodeproj -scheme AITouchGrass -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' clean build

echo "Verifying LSApplicationQueriesSchemes in compiled app..."
plutil -p ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*/Build/Products/Debug-iphonesimulator/AITouchGrass.app/Info.plist | grep -A 55 LSApplicationQueriesSchemes

echo "Done!"