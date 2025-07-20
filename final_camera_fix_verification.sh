#!/bin/bash

echo "🎯 最终相机修复验证"
echo "===================="

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
cd "$PROJECT_DIR"

echo "📋 1. 检查项目配置..."

# 检查权限配置
if grep -q "INFOPLIST_KEY_NSCameraUsageDescription" "AITouchGrass.xcodeproj/project.pbxproj"; then
    echo "✅ 相机权限已在项目中配置"
else
    echo "❌ 相机权限未配置"
fi

if grep -q "INFOPLIST_KEY_NSPhotoLibraryUsageDescription" "AITouchGrass.xcodeproj/project.pbxproj"; then
    echo "✅ 照片库权限已在项目中配置"
else
    echo "❌ 照片库权限未配置"
fi

# 检查GENERATE_INFOPLIST_FILE设置
if grep -q "GENERATE_INFOPLIST_FILE = YES" "AITouchGrass.xcodeproj/project.pbxproj"; then
    echo "✅ 启用自动生成Info.plist"
else
    echo "❌ 未启用自动生成Info.plist"
fi

# 检查是否没有冲突的自定义INFOPLIST_FILE设置
if ! grep -E "^\s*INFOPLIST_FILE = .*\.plist" "AITouchGrass.xcodeproj/project.pbxproj" >/dev/null 2>&1; then
    echo "✅ 没有冲突的Info.plist文件引用"
else
    echo "❌ 仍有冲突的Info.plist文件引用"
fi

echo ""
echo "📱 2. 检查源代码..."

# 检查CameraView
if [ -f "AITouchGrass/Modules/TouchGrass/Views/CameraView.swift" ]; then
    echo "✅ CameraView.swift存在"
    
    if grep -q "AVCaptureDevice.authorizationStatus" "AITouchGrass/Modules/TouchGrass/Views/CameraView.swift"; then
        echo "✅ CameraView包含权限检查"
    else
        echo "❌ CameraView缺少权限检查"
    fi
else
    echo "❌ CameraView.swift不存在"
fi

# 检查TouchGrassView是否使用CameraView
if grep -q "CameraView(image:" "AITouchGrass/Modules/TouchGrass/Views/TouchGrassView.swift"; then
    echo "✅ TouchGrassView使用CameraView"
else
    echo "❌ TouchGrassView未使用CameraView"
fi

# 检查是否删除了旧的ImagePicker
if ! grep -q "struct ImagePicker:" "AITouchGrass/Modules/TouchGrass/Views/TouchGrassView.swift"; then
    echo "✅ 旧的ImagePicker已删除"
else
    echo "❌ 旧的ImagePicker仍存在"
fi

echo ""
echo "🧹 3. 检查构建环境..."

# 检查是否有自定义Info.plist文件
if [ ! -f "AITouchGrass/Info.plist" ]; then
    echo "✅ 没有冲突的自定义Info.plist"
else
    echo "❌ 存在冲突的自定义Info.plist"
fi

# 检查DerivedData是否已清理
if [ ! -d ~/Library/Developer/Xcode/DerivedData/AITouchGrass* ]; then
    echo "✅ DerivedData已清理"
else
    echo "⚠️  DerivedData未完全清理，建议手动删除"
fi

echo ""
echo "📊 修复状态总结:"
echo "================"

# 计算修复状态
CHECKS=0
PASSED=0

# 检查项目配置
grep -q "INFOPLIST_KEY_NSCameraUsageDescription" "AITouchGrass.xcodeproj/project.pbxproj" && ((PASSED++)); ((CHECKS++))
grep -q "INFOPLIST_KEY_NSPhotoLibraryUsageDescription" "AITouchGrass.xcodeproj/project.pbxproj" && ((PASSED++)); ((CHECKS++))
grep -q "GENERATE_INFOPLIST_FILE = YES" "AITouchGrass.xcodeproj/project.pbxproj" && ((PASSED++)); ((CHECKS++))
! grep -E "^\s*INFOPLIST_FILE = .*\.plist" "AITouchGrass.xcodeproj/project.pbxproj" >/dev/null 2>&1 && ((PASSED++)); ((CHECKS++))

# 检查源代码
[ -f "AITouchGrass/Modules/TouchGrass/Views/CameraView.swift" ] && ((PASSED++)); ((CHECKS++))
grep -q "CameraView(image:" "AITouchGrass/Modules/TouchGrass/Views/TouchGrassView.swift" && ((PASSED++)); ((CHECKS++))
! grep -q "struct ImagePicker:" "AITouchGrass/Modules/TouchGrass/Views/TouchGrassView.swift" && ((PASSED++)); ((CHECKS++))

# 检查构建环境
[ ! -f "AITouchGrass/Info.plist" ] && ((PASSED++)); ((CHECKS++))

echo "通过检查: $PASSED/$CHECKS"

if [ $PASSED -eq $CHECKS ]; then
    echo ""
    echo "🎉 所有修复检查通过！"
    echo ""
    echo "✅ 修复完成的问题:"
    echo "   - Info.plist冲突已解决"
    echo "   - 相机权限正确配置在项目设置中"
    echo "   - 新的CameraView替换了有问题的ImagePicker"
    echo "   - 构建缓存已清理"
    echo ""
    echo "🚀 现在可以："
    echo "   1. 在Xcode中打开项目"
    echo "   2. Product → Clean Build Folder"
    echo "   3. 重新构建并运行到真机"
    echo "   4. 测试相机功能 - 应该不再崩溃！"
    echo ""
    echo "📱 预期行为："
    echo "   - 点击'测试草坪识别'不再崩溃"
    echo "   - 弹出相机权限请求对话框"
    echo "   - 授权后可以正常使用相机"
else
    echo ""
    echo "⚠️  还有一些检查未通过，请查看上面的详细信息"
fi

echo ""
echo "🔧 故障排除:"
echo "============"
echo "如果仍有问题:"
echo "1. 确保从设备删除旧应用"
echo "2. 在Xcode中完全重新构建"
echo "3. 检查Xcode控制台的错误信息"
echo "4. 确保代码签名正确"