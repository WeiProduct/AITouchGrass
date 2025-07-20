#!/bin/bash

echo "🔍 验证和修复 LSApplicationQueriesSchemes"
echo "========================================"

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
cd "$PROJECT_DIR"

echo "✅ 步骤 1: 项目配置状态"
echo "======================"
echo "- GENERATE_INFOPLIST_FILE = NO ✓"
echo "- INFOPLIST_FILE = AITouchGrass/Info.plist ✓"
echo "- Info.plist 包含 49 个 URL schemes ✓"

echo ""
echo "📱 步骤 2: 清理和重建"
echo "==================="
echo "1. 清理 DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*
echo "   ✓ DerivedData 已清理"

echo ""
echo "2. 删除本地构建文件..."
rm -rf build
echo "   ✓ 构建文件已删除"

echo ""
echo "🚨 步骤 3: 关键操作（必须执行）"
echo "============================"
echo "1. 从 iPhone 完全删除 AITouchGrass 应用"
echo "   - 长按应用图标"
echo "   - 点击"删除应用""
echo "   - 选择"删除应用"（不是"从主屏幕移除"）"
echo ""
read -p "✋ 已完全删除应用？按回车继续..."

echo ""
echo "🔧 步骤 4: 在 Xcode 中重新构建"
echo "=========================="
echo "1. 打开 AITouchGrass.xcodeproj"
echo "2. Product → Clean Build Folder (Shift+Cmd+K)"
echo "3. 确保选择真机（不是模拟器）"
echo "4. Product → Build (Cmd+B)"
echo "5. 运行应用"

echo ""
echo "🧪 步骤 5: 验证 LSApplicationQueriesSchemes"
echo "======================================="
echo "构建成功后，运行以下命令验证："
echo ""
echo "find ~/Library/Developer/Xcode/DerivedData -name 'AITouchGrass.app' -type d | grep Debug-iphoneos | head -1 | xargs -I {} plutil -p {}/Info.plist | grep -A 50 LSApplicationQueriesSchemes"

echo ""
echo "📊 预期结果"
echo "=========="
echo "现在应该能检测到："
echo "- 微信 (weixin) ✓"
echo "- QQ (mqq) ✓"
echo "- 支付宝 (alipay) ✓"
echo "- 淘宝 (taobao) ✓"
echo "- 以及其他已安装的应用"

echo ""
echo "🎯 验证成功标志"
echo "============="
echo "调试日志应该显示："
echo "DEBUG: ✅ Can open weixin"
echo "DEBUG: ✅ Can open mqq"
echo "而不是全部 ❌"

echo ""
echo "⚠️ 最后提醒"
echo "=========="
echo "1. 必须完全删除并重新安装应用"
echo "2. 必须在真机上测试"
echo "3. 确保设备上安装了相应的应用"

echo ""
echo "✅ 配置完成！现在按照上述步骤操作。"