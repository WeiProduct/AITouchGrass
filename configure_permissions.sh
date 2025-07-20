#!/bin/bash

echo "🔧 配置iOS相机权限"
echo "===================="

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
PROJECT_FILE="$PROJECT_DIR/AITouchGrass.xcodeproj/project.pbxproj"

cd "$PROJECT_DIR"

echo "📱 1. 检查项目文件..."
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ 项目文件不存在: $PROJECT_FILE"
    exit 1
fi

echo "✅ 找到项目文件"

echo "📝 2. 备份项目文件..."
cp "$PROJECT_FILE" "$PROJECT_FILE.backup.$(date +%Y%m%d_%H%M%S)"

echo "🔧 3. 清理构建缓存..."
# 清理Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass*

# 清理构建产物
if [ -d "build" ]; then
    rm -rf build
fi

echo "📋 4. 创建Info.plist配置..."

# 确保Info.plist文件存在并正确配置
INFOPLIST_FILE="$PROJECT_DIR/AITouchGrass/Info.plist"

if [ -f "$INFOPLIST_FILE" ]; then
    echo "✅ Info.plist 已存在"
    
    # 验证权限是否已添加
    if /usr/libexec/PlistBuddy -c "Print :NSCameraUsageDescription" "$INFOPLIST_FILE" >/dev/null 2>&1; then
        echo "✅ 相机权限描述已存在"
    else
        echo "❌ 添加相机权限描述"
        /usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string 'AITouchGrass需要访问相机来拍摄自然景观，用于验证草地、天空等自然元素，从而解锁被限制的应用。'" "$INFOPLIST_FILE"
    fi
    
    if /usr/libexec/PlistBuddy -c "Print :NSPhotoLibraryUsageDescription" "$INFOPLIST_FILE" >/dev/null 2>&1; then
        echo "✅ 照片库权限描述已存在"
    else
        echo "❌ 添加照片库权限描述"
        /usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryUsageDescription string 'AITouchGrass需要访问照片库来选择包含自然景观的图片，用于验证草地、天空等自然元素，从而解锁被限制的应用。'" "$INFOPLIST_FILE"
    fi
else
    echo "❌ Info.plist 不存在"
    exit 1
fi

echo "🏗️  5. 修改项目配置..."

# 使用Python脚本修改pbxproj文件以引用Info.plist
python3 << 'EOF'
import sys
import re

project_file = "/Users/weifu/Desktop/AITouchGrass/AITouchGrass.xcodeproj/project.pbxproj"

try:
    with open(project_file, 'r') as f:
        content = f.read()
    
    # 检查是否已经配置了INFOPLIST_FILE
    if 'INFOPLIST_FILE = AITouchGrass/Info.plist' not in content:
        # 找到target配置部分并添加INFOPLIST_FILE
        pattern = r'(buildSettings = \{[^}]*?)(IPHONEOS_DEPLOYMENT_TARGET = [^;]*;)'
        replacement = r'\1INFOPLIST_FILE = AITouchGrass/Info.plist;\n\t\t\t\t\2'
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
    
    # 确保GENERATE_INFOPLIST_FILE = NO
    content = re.sub(r'GENERATE_INFOPLIST_FILE = YES;', 'GENERATE_INFOPLIST_FILE = NO;', content)
    
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ 项目配置已更新")
    
except Exception as e:
    print(f"❌ 项目配置失败: {e}")
    sys.exit(1)
EOF

echo "🧹 6. 最终清理..."
# 确保没有冲突的构建文件
find . -name "*.app" -type d -exec rm -rf {} + 2>/dev/null || true

echo "✅ 权限配置完成！"
echo ""
echo "📋 接下来的步骤:"
echo "1. 打开Xcode项目"
echo "2. 在Xcode中选择 Product -> Clean Build Folder"
echo "3. 重新构建项目"
echo "4. 在真机上测试相机功能"
echo ""
echo "🔍 验证方法:"
echo "- 构建完成后，Info.plist应该包含相机权限"
echo "- 首次使用相机时应该弹出权限请求"
echo "- 不应该再出现权限相关的崩溃"

echo ""
echo "📱 如果仍有问题，请尝试:"
echo "1. 删除app从设备"
echo "2. 重启Xcode"
echo "3. 重新安装到设备"