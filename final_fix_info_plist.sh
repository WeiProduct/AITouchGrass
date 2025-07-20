#!/bin/bash

echo "🔧 最终修复 Info.plist 冲突"
echo "=========================="

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
cd "$PROJECT_DIR"

echo "✅ 问题分析："
echo "============"
echo "- 'Multiple commands produce Info.plist' 错误"
echo "- 原因：GENERATE_INFOPLIST_FILE = YES 与自定义 Info.plist 冲突"

echo ""
echo "🛠️ 解决方案："
echo "============"
echo "使用自动生成的 Info.plist，配置已在 project.pbxproj 中"

echo ""
echo "📋 已完成的操作："
echo "==============="
echo "1. 备份了自定义 Info.plist 到 Info.plist.backup"
echo "2. 保留 GENERATE_INFOPLIST_FILE = YES"
echo "3. LSApplicationQueriesSchemes 在 project.pbxproj 中配置"

echo ""
echo "🚀 立即执行以下步骤："
echo "===================="
echo "1. 关闭 Xcode"
echo "2. 清理 DerivedData："
echo "   rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*"
echo "3. 重新打开 Xcode"
echo "4. Clean Build Folder (Shift+Cmd+K)"
echo "5. 从设备完全删除应用"
echo "6. 构建并运行"

echo ""
echo "🔍 验证步骤："
echo "============"
echo "构建成功后，验证 Info.plist 包含 LSApplicationQueriesSchemes："
echo ""
echo "find ~/Library/Developer/Xcode/DerivedData -name 'AITouchGrass.app' -type d | head -1 | xargs -I {} plutil -p {}/Info.plist | grep -A 50 LSApplicationQueriesSchemes"

echo ""
echo "⚠️ 重要提醒："
echo "==========="
echo "- 必须完全删除并重新安装应用"
echo "- 必须在真机上测试"
echo "- 确保测试设备上安装了要检测的应用"

echo ""
echo "✅ 冲突已解决！"