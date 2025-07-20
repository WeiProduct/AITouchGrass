#!/bin/bash

echo "📱 生成URL Schemes配置"
echo "======================"

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
cd "$PROJECT_DIR"

echo "为了检测更多应用，需要在项目设置中添加LSApplicationQueriesSchemes。"
echo ""

# 创建LSApplicationQueriesSchemes配置
cat > url_schemes_config.plist << 'EOF'
<!-- 将以下内容添加到项目的Info.plist中，或在Xcode项目设置的Custom iOS Target Properties中添加 -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <!-- 社交应用 -->
    <string>weixin</string>
    <string>mqq</string>
    <string>sinaweibo</string>
    <string>xhsdiscover</string>
    <string>instagram</string>
    <string>fb</string>
    <string>twitter</string>
    <string>whatsapp</string>
    <string>tg</string>
    <string>discord</string>
    <string>linkedin</string>
    <string>snapchat</string>
    <string>pinterest</string>
    <string>tumblr</string>
    <string>reddit</string>
    
    <!-- 娱乐应用 -->
    <string>snssdk1128</string>
    <string>kwai</string>
    <string>bilibili</string>
    <string>qiyi-iphone</string>
    <string>tenvideo</string>
    <string>youku</string>
    <string>youtube</string>
    <string>nflx</string>
    <string>musically</string>
    <string>twitch</string>
    <string>hulu</string>
    <string>disneyplus</string>
    <string>hbomax</string>
    <string>aiv</string>
    
    <!-- 购物应用 -->
    <string>taobao</string>
    <string>openapp.jdmobile</string>
    <string>tmall</string>
    <string>pinduoduo</string>
    <string>amazon</string>
    <string>ebay</string>
    <string>walmart</string>
    
    <!-- 金融应用 -->
    <string>alipay</string>
    <string>bocmobile</string>
    <string>cmbmobilebank</string>
    <string>paypal</string>
    <string>venmo</string>
    <string>cashapp</string>
    <string>robinhood</string>
    
    <!-- 音乐应用 -->
    <string>orpheus</string>
    <string>qqmusic</string>
    <string>kugouURL</string>
    <string>spotify</string>
    <string>music</string>
    <string>soundcloud</string>
    <string>pandora</string>
    
    <!-- 出行应用 -->
    <string>diditaxi</string>
    <string>iosamap</string>
    <string>baidumap</string>
    <string>meituangroup</string>
    <string>eleme</string>
    <string>uber</string>
    <string>lyft</string>
    <string>airbnb</string>
    <string>booking</string>
    
    <!-- 新闻应用 -->
    <string>zhihu</string>
    <string>snssdk141</string>
    <string>baiduboxapp</string>
    <string>cnn</string>
    <string>bbcnews</string>
    <string>nytimes</string>
    
    <!-- 浏览器 -->
    <string>googlechrome</string>
    <string>firefox</string>
    <string>microsoft-edge</string>
    
    <!-- 工具应用 -->
    <string>onepassword</string>
    <string>lastpass</string>
    <string>evernote</string>
    <string>notion</string>
    <string>ms-word</string>
    <string>ms-excel</string>
    <string>ms-powerpoint</string>
    <string>googledocs</string>
    <string>slack</string>
    <string>zoomus</string>
    <string>msteams</string>
    <string>googlemeet</string>
    
    <!-- 游戏 -->
    <string>smoba</string>
    <string>pubgmobile</string>
    <string>genshinimpact</string>
    <string>candycrush</string>
    <string>pokemongo</string>
    <string>clashofclans</string>
    <string>amongus</string>
    
    <!-- 健康健身 -->
    <string>nikerunclub</string>
    <string>strava</string>
    <string>myfitnesspal</string>
    <string>headspace</string>
    
    <!-- 系统应用 -->
    <string>prefs</string>
    <string>mailto</string>
    <string>tel</string>
    <string>sms</string>
    <string>camera</string>
    <string>http</string>
    <string>maps</string>
    <string>itms-apps</string>
    <string>clock</string>
    <string>calc</string>
    <string>mobilenotes</string>
    <string>x-apple-reminder</string>
    <string>calshow</string>
    <string>photos-redirect</string>
    <string>weather</string>
    <string>stocks</string>
</array>
EOF

echo "✅ 已生成 url_schemes_config.plist 文件"
echo ""

echo "📋 手动配置步骤:"
echo "================"

echo "1. 在Xcode中打开项目"
echo "2. 选择 AITouchGrass target"
echo "3. 点击 Info 标签页"
echo "4. 在 Custom iOS Target Properties 中点击 +"
echo "5. 添加 Key: LSApplicationQueriesSchemes"
echo "6. 设置 Type: Array"
echo "7. 在数组中添加以下URL schemes:"

echo ""
echo "或者，使用自动化脚本添加到项目配置中:"

# 创建自动化脚本
cat > add_url_schemes.sh << 'EOF'
#!/bin/bash

PROJECT_FILE="/Users/weifu/Desktop/AITouchGrass/AITouchGrass.xcodeproj/project.pbxproj"

# 备份项目文件
cp "$PROJECT_FILE" "$PROJECT_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# 使用Python添加URL schemes到项目配置
python3 << 'PYTHON_EOF'
import re

project_file = "/Users/weifu/Desktop/AITouchGrass/AITouchGrass.xcodeproj/project.pbxproj"

url_schemes = [
    "weixin", "mqq", "sinaweibo", "xhsdiscover", "instagram", "fb", "twitter",
    "whatsapp", "tg", "discord", "snssdk1128", "kwai", "bilibili", "taobao",
    "alipay", "orpheus", "qqmusic", "diditaxi", "iosamap", "zhihu", "youtube",
    "spotify", "uber", "amazon", "prefs", "mailto", "tel", "sms", "maps"
]

try:
    with open(project_file, 'r') as f:
        content = f.read()
    
    # 添加LSApplicationQueriesSchemes到项目配置
    schemes_string = '\\n'.join([f'\t\t\t\t\t<string>{scheme}</string>' for scheme in url_schemes])
    
    # 查找buildSettings部分并添加LSApplicationQueriesSchemes
    pattern = r'(buildSettings = \{[^}]*?)(IPHONEOS_DEPLOYMENT_TARGET = [^;]*;)'
    replacement = f'''\\1INFOPLIST_KEY_LSApplicationQueriesSchemes = (
\t\t\t\t\t{schemes_string}
\t\t\t\t);
\t\t\t\t\\2'''
    
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
    
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ URL schemes added to project configuration")
    
except Exception as e:
    print(f"❌ Failed to add URL schemes: {e}")
    import sys
    sys.exit(1)
PYTHON_EOF

echo "✅ URL schemes配置已添加到项目中"
echo "现在需要重新构建应用以使更改生效"
EOF

chmod +x add_url_schemes.sh

echo ""
echo "🚀 使用方法:"
echo "============"

echo "选择以下方法之一："
echo ""
echo "方法1 - 自动添加 (推荐):"
echo "  ./add_url_schemes.sh"
echo ""
echo "方法2 - 手动添加:"
echo "  1. 查看 url_schemes_config.plist 文件内容"
echo "  2. 在Xcode项目设置中手动添加这些schemes"
echo ""

echo "⚠️  注意事项:"
echo "============="
echo "- 添加后需要Clean Build Folder并重新构建"
echo "- iOS限制单个应用最多查询50个URL schemes"
echo "- 部分schemes可能仍无法检测到某些应用"
echo "- 这是iOS隐私保护的一部分，无法完全绕过"

echo ""
echo "完成后，应用检测功能将能够发现更多已安装的应用！"