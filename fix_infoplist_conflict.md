# 修复Info.plist冲突问题

## 问题
```
Multiple commands produce '/Users/weifu/Library/Developer/Xcode/DerivedData/AITouchGrass-coxnbyienrlhinesizvkntzombop/Build/Products/Debug-iphoneos/AITouchGrass.app/Info.plist'
```

## 原因
项目配置为自动生成Info.plist文件 (`GENERATE_INFOPLIST_FILE = YES`)，但我们创建了自定义的Info.plist文件，导致冲突。

## 解决方案

### 方案1：使用Xcode项目设置添加权限（推荐）

1. 在Xcode中打开项目
2. 选择 `AITouchGrass` target
3. 点击 `Info` 标签页
4. 在 `Custom iOS Target Properties` 部分点击 `+` 添加：

   - **Key**: `Privacy - Camera Usage Description`
   - **Type**: `String`
   - **Value**: `AITouchGrass需要访问相机来拍摄自然景观，用于验证草地、天空等自然元素，从而解锁被限制的应用。`

   - **Key**: `Privacy - Photo Library Usage Description`  
   - **Type**: `String`
   - **Value**: `AITouchGrass需要访问照片库来选择包含自然景观的图片，用于验证草地、天空等自然元素，从而解锁被限制的应用。`

### 方案2：通过Build Settings添加（命令行）

如果无法使用Xcode界面，可以通过修改项目文件来添加这些设置。

## 临时解决方案

我已经删除了冲突的自定义Info.plist文件，现在应该可以正常构建。权限描述已经添加到构建产物中，应该可以正常工作。

## 验证步骤

1. 清理并重新构建项目：
   ```bash
   cd /Users/weifu/Desktop/AITouchGrass
   xcodebuild -scheme AITouchGrass -destination 'platform=iOS,name=iPhone (4)' clean build
   ```

2. 检查权限是否正确添加：
   ```bash
   /usr/libexec/PlistBuddy -c "Print :NSCameraUsageDescription" "/Users/weifu/Library/Developer/Xcode/DerivedData/AITouchGrass*/Build/Products/*/AITouchGrass.app/Info.plist"
   ```

3. 如果权限不存在，运行我们的脚本：
   ```bash
   /Users/weifu/Desktop/AITouchGrass/add_permissions.sh
   ```

## 长期解决方案

为了永久解决这个问题，建议在Xcode中手动添加这些权限描述到项目设置中，这样每次构建都会自动包含这些权限。