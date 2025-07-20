#!/bin/bash

# 添加相机和照片库权限到Info.plist的脚本
# 这个脚本会在每次构建后自动运行

echo "Adding camera and photo library permissions to Info.plist..."

# 查找构建产物中的Info.plist文件
INFO_PLIST_PATHS=$(find /Users/weifu/Library/Developer/Xcode/DerivedData/AITouchGrass* -name "Info.plist" -path "*/Build/Products/*/AITouchGrass.app/Info.plist" 2>/dev/null)

for PLIST_PATH in $INFO_PLIST_PATHS; do
    echo "Processing: $PLIST_PATH"
    
    # 添加相机权限描述
    /usr/libexec/PlistBuddy -c "Delete :NSCameraUsageDescription" "$PLIST_PATH" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string 'AITouchGrass需要访问相机来拍摄自然景观，用于验证草地、天空等自然元素，从而解锁被限制的应用。'" "$PLIST_PATH"
    
    # 添加照片库权限描述
    /usr/libexec/PlistBuddy -c "Delete :NSPhotoLibraryUsageDescription" "$PLIST_PATH" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryUsageDescription string 'AITouchGrass需要访问照片库来选择包含自然景观的图片，用于验证草地、天空等自然元素，从而解锁被限制的应用。'" "$PLIST_PATH"
    
    echo "Successfully added permissions to: $PLIST_PATH"
done

echo "Permission addition completed!"