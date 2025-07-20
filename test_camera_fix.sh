#!/bin/bash

echo "🔍 测试相机修复状态"
echo "===================="

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
cd "$PROJECT_DIR"

echo "📋 1. 检查源代码修复..."

# 检查CameraView是否存在
if [ -f "AITouchGrass/Modules/TouchGrass/Views/CameraView.swift" ]; then
    echo "✅ 新的CameraView.swift已创建"
else
    echo "❌ CameraView.swift不存在"
fi

# 检查TouchGrassView是否使用新的CameraView
if grep -q "CameraView(image: \$selectedImage" "AITouchGrass/Modules/TouchGrass/Views/TouchGrassView.swift"; then
    echo "✅ TouchGrassView已更新使用CameraView"
else
    echo "❌ TouchGrassView未使用CameraView"
fi

# 检查是否删除了旧的ImagePicker
if ! grep -q "struct ImagePicker:" "AITouchGrass/Modules/TouchGrass/Views/TouchGrassView.swift"; then
    echo "✅ 旧的ImagePicker已删除"
else
    echo "❌ 旧的ImagePicker仍然存在"
fi

echo ""
echo "📱 2. 检查Info.plist配置..."

INFOPLIST_FILE="AITouchGrass/Info.plist"

if [ -f "$INFOPLIST_FILE" ]; then
    echo "✅ Info.plist文件存在"
    
    if /usr/libexec/PlistBuddy -c "Print :NSCameraUsageDescription" "$INFOPLIST_FILE" >/dev/null 2>&1; then
        CAMERA_DESC=$(/usr/libexec/PlistBuddy -c "Print :NSCameraUsageDescription" "$INFOPLIST_FILE")
        echo "✅ 相机权限描述: $CAMERA_DESC"
    else
        echo "❌ 缺少相机权限描述"
    fi
    
    if /usr/libexec/PlistBuddy -c "Print :NSPhotoLibraryUsageDescription" "$INFOPLIST_FILE" >/dev/null 2>&1; then
        PHOTO_DESC=$(/usr/libexec/PlistBuddy -c "Print :NSPhotoLibraryUsageDescription" "$INFOPLIST_FILE")
        echo "✅ 照片库权限描述: $PHOTO_DESC"
    else
        echo "❌ 缺少照片库权限描述"
    fi
else
    echo "❌ Info.plist文件不存在"
fi

echo ""
echo "🏗️  3. 检查项目配置..."

PROJECT_FILE="AITouchGrass.xcodeproj/project.pbxproj"

if grep -q "INFOPLIST_FILE = AITouchGrass/Info.plist" "$PROJECT_FILE"; then
    echo "✅ 项目配置引用Info.plist"
else
    echo "❌ 项目配置未引用Info.plist"
fi

if grep -q "GENERATE_INFOPLIST_FILE = NO" "$PROJECT_FILE"; then
    echo "✅ 禁用自动生成Info.plist"
else
    echo "⚠️  可能仍在自动生成Info.plist"
fi

echo ""
echo "🧪 4. 代码质量检查..."

# 检查CameraView中的权限检查
if grep -q "AVCaptureDevice.authorizationStatus" "AITouchGrass/Modules/TouchGrass/Views/CameraView.swift"; then
    echo "✅ CameraView包含权限检查"
else
    echo "❌ CameraView缺少权限检查"
fi

# 检查错误处理
if grep -q "showPermissionAlert" "AITouchGrass/Modules/TouchGrass/Views/CameraView.swift"; then
    echo "✅ CameraView包含错误处理"
else
    echo "❌ CameraView缺少错误处理"
fi

echo ""
echo "📊 修复总结:"
echo "============"

# 计算修复项目
FIXES=0
TOTAL=8

[ -f "AITouchGrass/Modules/TouchGrass/Views/CameraView.swift" ] && ((FIXES++))
grep -q "CameraView(image: \$selectedImage" "AITouchGrass/Modules/TouchGrass/Views/TouchGrassView.swift" && ((FIXES++))
! grep -q "struct ImagePicker:" "AITouchGrass/Modules/TouchGrass/Views/TouchGrassView.swift" && ((FIXES++))
[ -f "$INFOPLIST_FILE" ] && ((FIXES++))
/usr/libexec/PlistBuddy -c "Print :NSCameraUsageDescription" "$INFOPLIST_FILE" >/dev/null 2>&1 && ((FIXES++))
/usr/libexec/PlistBuddy -c "Print :NSPhotoLibraryUsageDescription" "$INFOPLIST_FILE" >/dev/null 2>&1 && ((FIXES++))
grep -q "INFOPLIST_FILE = AITouchGrass/Info.plist" "$PROJECT_FILE" && ((FIXES++))
grep -q "AVCaptureDevice.authorizationStatus" "AITouchGrass/Modules/TouchGrass/Views/CameraView.swift" && ((FIXES++))

echo "修复完成度: $FIXES/$TOTAL"

if [ $FIXES -eq $TOTAL ]; then
    echo "🎉 所有修复已完成!"
    echo ""
    echo "🚀 测试步骤:"
    echo "1. 在Xcode中打开项目"
    echo "2. Product -> Clean Build Folder"
    echo "3. 构建并运行到真机"
    echo "4. 点击'测试草坪识别'按钮"
    echo "5. 应该看到相机权限请求而不是崩溃"
elif [ $FIXES -gt 6 ]; then
    echo "✅ 大部分修复已完成，可以测试"
else
    echo "⚠️  还需要完成更多修复"
fi

echo ""
echo "🔧 重要提醒:"
echo "- 删除设备上的旧应用"
echo "- 在Xcode中Clean Build Folder"
echo "- 重新安装到真机测试"