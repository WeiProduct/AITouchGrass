#!/bin/bash

# Fix LSApplicationQueriesSchemes for auto-generated Info.plist
# This script adds the necessary build settings to the Xcode project

PROJECT_FILE="AITouchGrass.xcodeproj/project.pbxproj"

# Create a backup
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

echo "Adding LSApplicationQueriesSchemes to project build settings..."

# Define the URL schemes array in a format suitable for pbxproj
SCHEMES_ARRAY='(
					weixin,
					wechat,
					weixinULAPI,
					mqq,
					mqqapi,
					mqqwpa,
					mqqOpensdkSSoLogin,
					mqqconnect,
					alipay,
					alipayshare,
					sinaweibo,
					weibosdk,
					taobao,
					tmall,
					zhihu,
					pinduoduo,
					snssdk1128,
					bilibili,
					kwai,
					orpheus,
					qqmusic,
					iosamap,
					baidumap,
					imeituan,
					eleme,
					diditaxi,
					"openapp.jdmobile",
					baiduboxapp,
					dingtalk,
					wxwork,
					instagram,
					whatsapp,
					youtube,
					fb,
					twitter,
					tg,
					googlechrome,
					spotify,
					snapchat,
					linkedin,
					discord,
					uber,
					prefs,
					mailto,
					tel,
					sms,
					http,
					maps,
					"itms-apps"
				)'

# Add INFOPLIST_KEY_LSApplicationQueriesSchemes to all build configurations
perl -i -pe 's/(INFOPLIST_KEY_UILaunchScreen_Generation = YES;)/$1\n\t\t\t\tINFOPLIST_KEY_LSApplicationQueriesSchemes = '"$SCHEMES_ARRAY"';/g' "$PROJECT_FILE"

echo "LSApplicationQueriesSchemes has been added to the project."
echo "Please close and reopen Xcode, then clean and rebuild your project."
echo ""
echo "To verify the fix:"
echo "1. Open Xcode"
echo "2. Select your project target"
echo "3. Go to Build Settings"
echo "4. Search for 'INFOPLIST_KEY_LSApplicationQueriesSchemes'"
echo "5. You should see the URL schemes listed there"