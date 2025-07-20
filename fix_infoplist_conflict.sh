#!/bin/bash

echo "🔧 修复Info.plist冲突"
echo "===================="

PROJECT_DIR="/Users/weifu/Desktop/AITouchGrass"
PROJECT_FILE="$PROJECT_DIR/AITouchGrass.xcodeproj/project.pbxproj"

cd "$PROJECT_DIR"

echo "📝 1. 备份项目文件..."
cp "$PROJECT_FILE" "$PROJECT_FILE.backup.conflict.$(date +%Y%m%d_%H%M%S)"

echo "🧹 2. 清理冲突的配置..."

# 使用Python脚本修复项目配置
python3 << 'EOF'
import re

project_file = "/Users/weifu/Desktop/AITouchGrass/AITouchGrass.xcodeproj/project.pbxproj"

try:
    with open(project_file, 'r') as f:
        content = f.read()
    
    # 移除所有INFOPLIST_FILE配置
    content = re.sub(r'\s*INFOPLIST_FILE = [^;]*;', '', content)
    
    # 确保GENERATE_INFOPLIST_FILE = YES (让Xcode自动生成)
    content = re.sub(r'GENERATE_INFOPLIST_FILE = NO;', 'GENERATE_INFOPLIST_FILE = YES;', content)
    
    # 在buildSettings中添加权限配置
    # 查找buildSettings部分
    pattern = r'(buildSettings = \{[^}]*?)(IPHONEOS_DEPLOYMENT_TARGET = [^;]*;)'
    
    # 添加权限描述到build settings
    replacement = r'''\1INFOPLIST_KEY_NSCameraUsageDescription = "AITouchGrass需要访问相机来拍摄自然景观，用于验证草地、天空等自然元素，从而解锁被限制的应用。";
				INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "AITouchGrass需要访问照片库来选择包含自然景观的图片，用于验证草地、天空等自然元素，从而解锁被限制的应用。";
				\2'''
    
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
    
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ 项目配置已修复")
    
except Exception as e:
    print(f"❌ 修复失败: {e}")
    import sys
    sys.exit(1)
EOF

echo "🧹 3. 清理构建缓存..."
# 删除所有构建产物和缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass*
rm -rf build

echo "✅ Info.plist冲突修复完成！"
echo ""
echo "📋 修复内容:"
echo "- 移除了自定义Info.plist文件"
echo "- 启用Xcode自动生成Info.plist"
echo "- 在项目设置中添加权限描述"
echo "- 清理了所有构建缓存"
echo ""
echo "🚀 下一步:"
echo "1. 在Xcode中打开项目"
echo "2. Product -> Clean Build Folder"
echo "3. 重新构建项目"
echo "4. 应该不再有Info.plist冲突错误"
echo ""
echo "🔍 验证方法:"
echo "- 构建应该成功"
echo "- 应用启动时会请求相机权限"
echo "- 不会再有'Multiple commands produce Info.plist'错误"