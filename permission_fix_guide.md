# 相机权限修复指南

## 问题
应用崩溃，错误信息：
```
This app has crashed because it attempted to access privacy-sensitive data without a usage description. The app's Info.plist must contain an NSCameraUsageDescription key with a string value explaining to the user how the app uses this data.
```

## 临时修复（已完成）
我已经修改了构建产物中的 Info.plist 文件，添加了：
- `NSCameraUsageDescription`: 相机权限说明
- `NSPhotoLibraryUsageDescription`: 照片库权限说明

这个修复让您可以立即测试应用，但每次重新构建时会被覆盖。

## 永久修复方案

### 方案1：在Xcode中添加权限（推荐）

1. 在Xcode中打开项目
2. 选择项目根目录中的 `AITouchGrass` target
3. 点击 `Info` 标签页
4. 在 `Custom iOS Target Properties` 部分添加以下项：

   | Key | Type | Value |
   |-----|------|-------|
   | `Privacy - Camera Usage Description` | String | `AITouchGrass需要访问相机来拍摄自然景观，用于验证草地、天空等自然元素，从而解锁被限制的应用。` |
   | `Privacy - Photo Library Usage Description` | String | `AITouchGrass需要访问照片库来选择包含自然景观的图片，用于验证草地、天空等自然元素，从而解锁被限制的应用。` |

### 方案2：使用自定义Info.plist文件

我已经创建了一个 Info.plist 文件在 `/Users/weifu/Desktop/AITouchGrass/AITouchGrass/Info.plist`

要使用它：
1. 在Xcode中选择 AITouchGrass target
2. 在 `Build Settings` 中搜索 "Info.plist"
3. 将 `Generate Info.plist File` 设置为 `No`
4. 将 `Info.plist File` 设置为 `AITouchGrass/Info.plist`

## 测试步骤

修复后，测试流程：
1. 重新构建并运行应用
2. 点击 "拍摄草地解锁" 按钮
3. 应该会弹出相机权限请求对话框
4. 点击 "允许" 后应该能正常使用相机功能

## 预期行为

- ✅ 第一次点击相机按钮时会弹出权限请求
- ✅ 用户同意后可以正常拍照或选择图片
- ✅ 应用不再崩溃
- ✅ 图像处理和自然景观检测正常工作

## 如果仍有问题

如果权限修复后仍有其他问题，请查看控制台的调试输出：
```
DEBUG: Verify Nature button tapped
DEBUG: SimpleGrassDetectionService.detectNature called for 草地
DEBUG: CIImage created successfully, starting simplified detection
...
```

这将帮助我们确定是权限问题还是图像处理问题。