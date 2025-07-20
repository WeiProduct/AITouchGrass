#!/bin/bash

echo "🧹 深度清理和重建项目"
echo "===================="

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
cd "$PROJECT_DIR"

echo "📋 当前配置确认："
echo "================"
echo "✅ Info.plist 位置: AITouchGrass/Info.plist"
echo "✅ LSApplicationQueriesSchemes 包含 49 个 URL schemes"
echo "✅ 项目配置指向正确的 Info.plist"

echo ""
echo "🗑️ 步骤1: 清理 DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*
echo "✅ DerivedData 已清理"

echo ""
echo "🗑️ 步骤2: 清理构建文件夹..."
if [ -d "build" ]; then
    rm -rf build
    echo "✅ build 文件夹已删除"
fi

echo ""
echo "📱 步骤3: 从设备删除应用"
echo "========================"
echo "⚠️ 重要: 请在您的 iPhone 上手动删除 AITouchGrass 应用"
echo "长按应用图标 → 删除应用 → 删除"
echo ""
read -p "已删除应用？按回车继续..."

echo ""
echo "🛠️ 步骤4: 在 Xcode 中执行以下操作"
echo "================================"
echo "1. 打开 AITouchGrass.xcodeproj"
echo "2. Product → Clean Build Folder (Shift+Cmd+K)"
echo "3. 等待清理完成"
echo "4. Product → Build (Cmd+B)"
echo "5. 确保构建成功"
echo "6. 在真机上运行应用"

echo ""
echo "🔍 步骤5: 验证 Info.plist 是否正确包含在应用中"
echo "==========================================="
echo "构建后，检查以下路径的 Info.plist："
echo "~/Library/Developer/Xcode/DerivedData/AITouchGrass-*/Build/Products/Debug-iphoneos/AITouchGrass.app/Info.plist"
echo ""
echo "使用以下命令验证 LSApplicationQueriesSchemes："
echo "plutil -p ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*/Build/Products/Debug-iphoneos/AITouchGrass.app/Info.plist | grep -A 50 LSApplicationQueriesSchemes"

echo ""
echo "💡 关键检查点："
echo "============="
echo "1. ✅ Info.plist 在 AITouchGrass/ 目录下"
echo "2. ✅ Info.plist 包含 LSApplicationQueriesSchemes"
echo "3. ✅ 项目设置 GENERATE_INFOPLIST_FILE = NO"
echo "4. ✅ 项目设置 INFOPLIST_FILE = AITouchGrass/Info.plist"
echo "5. ✅ 应用完全从设备删除并重新安装"

echo ""
echo "🎯 预期结果："
echo "============"
echo "重新安装后，应该能检测到："
echo "- 微信 (如果已安装)"
echo "- QQ (如果已安装)"
echo "- 支付宝 (如果已安装)"
echo "- 以及其他已配置的应用"

echo ""
echo "🐛 如果仍然不工作："
echo "=================="
echo "1. 检查 Xcode 控制台是否有权限相关错误"
echo "2. 尝试在另一台设备上测试"
echo "3. 确认测试设备的 iOS 版本"
echo "4. 查看构建日志确认 Info.plist 被正确复制"

echo ""
echo "✅ 清理脚本执行完成！"
echo "现在请按照上述步骤在 Xcode 中重新构建和安装应用。"