#!/bin/bash

echo "🔧 手动修复项目配置"
echo "=================="

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
cd "$PROJECT_DIR"

echo "✅ 项目文件已从备份恢复"

echo ""
echo "📋 手动添加URL Schemes的步骤："
echo "=============================="

echo "由于自动化脚本导致项目文件损坏，现在需要手动添加URL schemes。"
echo ""

echo "**Xcode中的操作步骤：**"
echo ""
echo "1. 在Xcode中打开项目"
echo "2. 选择左侧的 'AITouchGrass' 项目"
echo "3. 选择 'AITouchGrass' target (不是test targets)"
echo "4. 点击 'Info' 标签页"
echo "5. 在 'Custom iOS Target Properties' 部分，点击 '+' 按钮"
echo "6. 添加新的Key: 'LSApplicationQueriesSchemes'"
echo "7. 设置Type为 'Array'"
echo "8. 在数组中添加以下字符串项目（不包括://后缀）："

echo ""
echo "**需要添加的URL Schemes:**"
echo "=========================="

cat << 'EOF'
weixin
mqq
sinaweibo
xhsdiscover
instagram
fb
twitter
whatsapp
tg
discord
snssdk1128
kwai
bilibili
taobao
alipay
orpheus
qqmusic
diditaxi
iosamap
zhihu
youtube
spotify
uber
amazon
prefs
mailto
tel
sms
maps
googlechrome
baidumap
eleme
meituangroup
EOF

echo ""
echo "**重要提醒：**"
echo "============"

echo "- 只需要添加scheme名称，不要包含 '://' 后缀"
echo "- 例如：添加 'weixin' 而不是 'weixin://'"
echo "- 每个scheme作为数组中的一个字符串项目"
echo "- 总共需要添加约30个schemes"

echo ""
echo "**完成后：**"
echo "=========="

echo "1. 保存项目设置"
echo "2. Clean Build Folder (Product → Clean Build Folder)"
echo "3. 重新构建应用"
echo "4. 测试应用选择功能"

echo ""
echo "**验证方法：**"
echo "============"

echo "在应用中打开'选择要锁定的应用'界面，应该能看到："
echo "- '正在扫描已安装的应用...' 提示"
echo "- 扫描完成后显示检测到的应用数量"
echo "- 只显示您设备上真正安装的应用"
echo "- 每个应用都有绿色'已安装'标签"

echo ""
echo "如果您不想手动添加这么多schemes，也可以只添加您最常用的几个："
echo "微信: weixin"
echo "QQ: mqq" 
echo "微博: sinaweibo"
echo "抖音: snssdk1128"
echo "淘宝: taobao"
echo "支付宝: alipay"
echo "地图: maps"
echo "设置: prefs"

echo ""
echo "这样至少可以检测到一些基本的应用。"