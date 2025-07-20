# 调试相机崩溃问题

## 问题描述
点击 "拍摄草地解锁" 按钮时应用崩溃。

## 已添加的调试信息
我已经在代码中添加了详细的调试日志，这些日志会帮助我们确定崩溃发生的具体位置。

## 修复的潜在问题
1. **颜色资源引用问题**: 修复了 `NatureType.color` 中对已删除颜色资源的引用
2. **类型不匹配**: 修复了 `showUnlockSuccess` 方法的参数类型问题
3. **添加了错误处理**: 在图像处理的各个步骤中添加了详细的错误处理

## 测试步骤
1. 运行应用
2. 点击 "拍摄草地解锁" 按钮
3. 选择一张图片（从相册或拍摄）
4. 查看控制台输出的调试信息

## 预期的调试输出
```
DEBUG: Verify Nature button tapped
DEBUG: verifyGrassImage called
DEBUG: Starting nature detection for 草地
DEBUG: Calling grassDetectionService.detectNature
DEBUG: GrassDetectionService.detectNature called for 草地
DEBUG: CIImage created successfully, starting detection
DEBUG: Detecting grass
DEBUG: Starting grass detection analysis
DEBUG: Green color ratio: [数值]
DEBUG: Texture score: [数值]
DEBUG: Grass detection - isValid: [true/false], confidence: [数值]
DEBUG: Detection completed with result: [结果]
DEBUG: Detection result - isValid: [true/false], confidence: [数值]
DEBUG: [High confidence detection - unlocking apps] 或 [Low confidence detection]
DEBUG: GrassDetectionService.detectNature finished
DEBUG: verifyGrassImage finished
```

## 如果仍然崩溃
请查看 Xcode 控制台中的：
1. 崩溃日志和调用栈
2. 上述调试输出到哪一步停止了
3. 是否有其他错误信息

## 可能的崩溃原因
1. **图像处理内存问题**: 图像太大导致内存不足
2. **CIContext 线程问题**: 在错误的线程上调用 Core Image
3. **像素数据处理**: 在处理像素数据时出现数组越界
4. **异步操作问题**: 在 continuation 中发生异常

## 紧急修复选项
如果问题仍然存在，我可以提供一个简化的检测版本，跳过复杂的图像分析：

```swift
// 简化版本 - 总是返回成功
private func detectGrass(in ciImage: CIImage) async throws -> NatureDetectionResult {
    // 简单的模拟检测，总是返回成功
    return NatureDetectionResult(
        natureType: .grass,
        isValid: true,
        confidence: 0.8,
        colorScore: 0.7,
        textureScore: 0.9,
        timestamp: Date()
    )
}
```

请运行应用并告诉我控制台输出的内容，这样我就能确定问题出现在哪里。