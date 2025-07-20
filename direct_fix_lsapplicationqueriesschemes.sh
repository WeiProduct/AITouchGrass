#!/bin/bash

echo "🔧 直接修复LSApplicationQueriesSchemes配置问题"
echo "=========================================="

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
cd "$PROJECT_DIR"

PROJECT_FILE="AITouchGrass.xcodeproj/project.pbxproj"
BACKUP_FILE="AITouchGrass.xcodeproj/project.pbxproj.backup.direct.$(date +%Y%m%d_%H%M%S)"

echo "📋 创建备份..."
cp "$PROJECT_FILE" "$BACKUP_FILE"
echo "✅ 备份创建: $BACKUP_FILE"

echo ""
echo "🔍 检查当前配置状态..."

# 检查是否已经有LSApplicationQueriesSchemes配置
if grep -q "INFOPLIST_KEY_LSApplicationQueriesSchemes" "$PROJECT_FILE"; then
    echo "⚠️ 发现现有LSApplicationQueriesSchemes配置，将替换"
    # 删除现有配置
    sed -i '' '/INFOPLIST_KEY_LSApplicationQueriesSchemes/d' "$PROJECT_FILE"
else
    echo "ℹ️ 未发现LSApplicationQueriesSchemes配置，将添加新配置"
fi

echo ""
echo "📝 添加LSApplicationQueriesSchemes配置..."

# 创建URL schemes配置字符串
SCHEMES_CONFIG='				INFOPLIST_KEY_LSApplicationQueriesSchemes = (weixin,wechat,weixinULAPI,mqq,mqqapi,mqqwpa,mqqOpensdkSSoLogin,mqqconnect,alipay,alipayshare,sinaweibo,weibosdk,taobao,tmall,zhihu,pinduoduo,snssdk1128,bilibili,kwai,orpheus,qqmusic,iosamap,baidumap,imeituan,eleme,diditaxi,"openapp.jdmobile",baiduboxapp,dingtalk,wxwork,instagram,whatsapp,youtube,fb,twitter,tg,googlechrome,spotify,snapchat,linkedin,discord,uber,prefs,mailto,tel,sms,http,maps,"itms-apps");'

# 在Debug配置中添加
sed -i '' "/751125592E23EAE400D18849.*Debug.*buildSettings = {/,/}/ {
    /INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;/i\\
$SCHEMES_CONFIG
}" "$PROJECT_FILE"

# 在Release配置中添加
sed -i '' "/7511255A2E23EAE400D18849.*Release.*buildSettings = {/,/}/ {
    /INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;/i\\
$SCHEMES_CONFIG
}" "$PROJECT_FILE"

echo ""
echo "🔍 验证配置..."
if grep -q "INFOPLIST_KEY_LSApplicationQueriesSchemes" "$PROJECT_FILE"; then
    echo "✅ LSApplicationQueriesSchemes已成功添加"
    
    # 计算schemes数量
    SCHEME_COUNT=$(grep "INFOPLIST_KEY_LSApplicationQueriesSchemes" "$PROJECT_FILE" | head -1 | tr ',' '\n' | wc -l)
    echo "✅ 添加了 $SCHEME_COUNT 个URL schemes"
    
    echo ""
    echo "📋 添加的URL schemes包括："
    echo "- 微信相关: weixin, wechat, weixinULAPI"
    echo "- QQ相关: mqq, mqqapi, mqqwpa, mqqOpensdkSSoLogin, mqqconnect"
    echo "- 支付宝: alipay, alipayshare"
    echo "- 微博: sinaweibo, weibosdk"
    echo "- 购物: taobao, tmall, pinduoduo"
    echo "- 娱乐: snssdk1128, bilibili, kwai"
    echo "- 音乐: orpheus, qqmusic"
    echo "- 地图: iosamap, baidumap"
    echo "- 外卖: imeituan, eleme"
    echo "- 出行: diditaxi"
    echo "- 购物: openapp.jdmobile"
    echo "- 搜索: baiduboxapp"
    echo "- 办公: dingtalk, wxwork"
    echo "- 国际应用: instagram, whatsapp, youtube, fb, twitter, tg"
    echo "- 浏览器: googlechrome"
    echo "- 音乐: spotify"
    echo "- 社交: snapchat, linkedin, discord"
    echo "- 出行: uber"
    echo "- 系统: prefs, mailto, tel, sms, http, maps, itms-apps"
    
else
    echo "❌ 配置添加失败"
    echo "正在恢复备份..."
    cp "$BACKUP_FILE" "$PROJECT_FILE"
    echo "已恢复到修改前状态"
    exit 1
fi

echo ""
echo "🧪 测试项目构建..."
if xcodebuild -list > /dev/null 2>&1; then
    echo "✅ 项目文件格式正确"
else
    echo "❌ 项目文件损坏，正在恢复..."
    cp "$BACKUP_FILE" "$PROJECT_FILE"
    echo "已恢复到修改前状态"
    exit 1
fi

echo ""
echo "🚀 下一步操作："
echo "==============="
echo "1. 在Xcode中Clean Build Folder (Product → Clean Build Folder)"
echo "2. 重新构建应用"
echo "3. 确保在真机上测试（不是模拟器）"
echo "4. 检查调试输出"

echo ""
echo "📊 预期结果："
echo "============"
echo "现在应该能检测到更多已安装的应用："
echo "- 微信、QQ、支付宝、淘宝等中国应用"
echo "- Instagram、WhatsApp、YouTube等国际应用"
echo "- 系统应用继续正常工作"

echo ""
echo "🔍 故障排除："
echo "============"
echo "如果仍然只检测到6个应用："
echo "1. 确保在真机而不是模拟器上测试"
echo "2. 确保这些应用确实安装在设备上"
echo "3. 尝试重新安装应用"
echo "4. 检查设备iOS版本是否为最新"
echo "5. 查看Xcode控制台是否有权限相关错误"

echo ""
echo "💡 关键提醒："
echo "============"
echo "- 必须在真机上测试"
echo "- 必须安装对应的应用"
echo "- Clean Build后重新安装应用"
echo "- 某些应用可能使用不同的URL schemes"

echo ""
echo "✅ LSApplicationQueriesSchemes配置完成！"
echo "现在请重新构建并在真机上测试。"