#!/bin/bash

echo "🔧 安全添加URL Schemes到项目配置"
echo "================================"

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
cd "$PROJECT_DIR"

PROJECT_FILE="AITouchGrass.xcodeproj/project.pbxproj"
BACKUP_FILE="AITouchGrass.xcodeproj/project.pbxproj.backup.$(date +%Y%m%d_%H%M%S)"

# 创建备份
echo "📋 创建项目文件备份..."
cp "$PROJECT_FILE" "$BACKUP_FILE"
echo "✅ 备份创建: $BACKUP_FILE"

echo ""
echo "📝 需要在Xcode中手动添加的LSApplicationQueriesSchemes："
echo "=================================================="

# 创建一个方便复制的schemes列表
cat > url_schemes_list.txt << 'EOF'
weixin
mqq
alipay
taobao
snssdk1128
sinaweibo
xhsdiscover
bilibili
kwai
orpheus
iosamap
imeituan
eleme
diditaxi
openapp.jdmobile
qqmusic
zhihu
snssdk141
baiduboxapp
baidumap
pinduoduo
tmall
qiyi-iphone
tenvideo
youku
instagram
whatsapp
youtube
musically
fb
twitter
tg
nflx
spotify
googlechrome
smoba
pubgmobile
genshinimpact
discord
snapchat
linkedin
uber
prefs
mailto
tel
sms
http
maps
itms-apps
EOF

echo "✅ URL schemes列表已保存到 url_schemes_list.txt"

echo ""
echo "🎯 在Xcode中的具体操作步骤："
echo "============================"
echo "1. 在Xcode中打开项目"
echo "2. 选择左侧的 'AITouchGrass' 项目"
echo "3. 选择 'AITouchGrass' target"
echo "4. 点击 'Info' 标签页"
echo "5. 在 'Custom iOS Target Properties' 下："
echo "   - 点击 '+' 按钮"
echo "   - 输入 Key: LSApplicationQueriesSchemes"
echo "   - 选择 Type: Array"
echo "6. 展开LSApplicationQueriesSchemes数组"
echo "7. 对于 url_schemes_list.txt 中的每一行："
echo "   - 点击数组的 '+' 按钮"
echo "   - 输入scheme名称（不包含://）"
echo "   - 重复直到添加完所有48个schemes"

echo ""
echo "⚠️ 重要提醒："
echo "============"
echo "- 总共需要添加48个URL schemes"
echo "- 不要包含 '://' 后缀"
echo "- 确保每个scheme都是独立的字符串项"
echo "- 添加完成后保存项目"

echo ""
echo "🔍 验证方法："
echo "============"
echo "添加完成后，你可以在project.pbxproj文件中搜索'LSApplicationQueriesSchemes'"
echo "应该能看到类似这样的条目："
echo 'INFOPLIST_KEY_LSApplicationQueriesSchemes = (weixin, mqq, alipay, ...);'

echo ""
echo "📱 测试步骤："
echo "============"
echo "1. Clean Build Folder (Product → Clean Build Folder)"
echo "2. 构建并安装到真机"
echo "3. 打开应用，进入'选择要锁定的应用'"
echo "4. 观察检测到的应用数量是否显著增加"

echo ""
echo "💡 预期结果："
echo "============"
echo "- 应该检测到20-35个应用（取决于你的安装情况）"
echo "- 主流中国应用（微信、QQ、支付宝等）应该都能检测到"
echo "- 常用国际应用也应该能检测到"

echo ""
echo "📋 完成！"
echo "========"
echo "现在请按照上述步骤在Xcode中手动添加URL schemes。"
echo "这是确保项目文件不被损坏的最安全方法。"