# 解决 Screen Time API 权限问题

## 问题分析

你遇到的错误：
```
The connection to service named com.apple.FamilyControlsAgent was invalidated: failed at lookup with error 159 - Sandbox restriction.
```

这表明应用无法访问 Screen Time API 的系统服务，原因是：

1. **Family Controls entitlement 需要特殊批准**
2. **开发环境配置问题**
3. **App ID 配置不正确**

## 解决方案

### 方案 1：申请 Family Controls Entitlement（推荐）

1. **登录 Apple Developer 账号**
   - 访问 https://developer.apple.com/contact/request/family-controls-distribution

2. **填写申请表**
   - 说明你的应用如何使用 Family Controls
   - 强调数字健康和户外活动的益处
   - 提供应用的详细描述

3. **等待批准**
   - Apple 会审核你的申请
   - 批准后，你的 App ID 才能使用这些 entitlements

### 方案 2：开发阶段临时解决方案

1. **在 Xcode 中配置**：
   ```
   1. 选择你的项目
   2. 选择主 target
   3. 进入 Signing & Capabilities
   4. 确保使用自动签名
   5. Team 选择你的开发者账号
   ```

2. **创建新的 App ID**：
   ```
   1. 登录 Apple Developer
   2. Certificates, Identifiers & Profiles
   3. 创建新的 App ID
   4. 启用 Family Controls capability
   ```

3. **更新 Info.plist**：
   ```xml
   <key>NSUserTrackingUsageDescription</key>
   <string>This app needs to monitor app usage to help you maintain digital wellness.</string>
   ```

### 方案 3：使用替代实现（立即可用）

既然 Screen Time API 需要特殊权限，我们可以先使用替代方案：

```swift
// 在 ServiceContainer.swift 中临时修改
private static func createAppBlockingService(modelContainer: ModelContainer) -> AppBlockingServiceProtocol {
    // 暂时使用 RealAppBlockingService，等待 Screen Time API 权限
    return RealAppBlockingService(modelContainer: modelContainer)
}
```

这样可以：
- ✅ 使用通知提醒
- ✅ 记录使用统计
- ✅ 实现临时解锁逻辑
- ❌ 但无法真正阻止应用

## Touch Grass 应用是如何做到的？

Touch Grass 应用能够使用 Screen Time API 是因为：

1. **已获得 Apple 批准**
   - 他们申请并获得了 Family Controls entitlement
   - 这需要向 Apple 说明使用场景

2. **正确的 Bundle ID 配置**
   - Bundle ID 必须与申请时提供的一致
   - Provisioning Profile 包含正确的 entitlements

3. **Production 环境**
   - 某些功能可能只在 TestFlight 或 App Store 版本中工作

## 建议的开发流程

### 第一阶段：功能开发
1. 使用 `RealAppBlockingService` 开发核心功能
2. 实现所有 UI 和用户体验
3. 完善草地识别和解锁逻辑

### 第二阶段：申请权限
1. 准备详细的应用说明
2. 录制演示视频
3. 向 Apple 申请 Family Controls entitlement

### 第三阶段：集成 Screen Time API
1. 获得批准后更新 entitlements
2. 使用 `ScreenTimeAppBlockingService`
3. 在 TestFlight 中测试

## 临时测试方案

如果你想看到类似的效果，可以：

1. **使用快捷指令**
   ```
   创建一个快捷指令，当打开特定应用时：
   - 显示提醒
   - 打开你的应用
   ```

2. **使用 Focus Mode API**
   ```swift
   // 可以建议用户设置专注模式
   import Intents
   
   let intent = INFocusStatusIntent()
   // 引导用户设置
   ```

3. **使用 ScreenTime 的公开 API**
   ```swift
   // 可以读取屏幕使用时间数据（如果用户允许）
   import FamilyControls
   
   // 显示使用统计，帮助用户自我管理
   ```

## 总结

1. **Screen Time API 需要特殊权限** - 不是所有开发者都能立即使用
2. **Touch Grass 已获得批准** - 这就是它能真正阻止应用的原因
3. **先开发核心功能** - 使用替代方案完成应用开发
4. **申请权限** - 准备好后向 Apple 申请
5. **逐步升级** - 获得权限后再集成完整的 Screen Time API

记住：即使没有 Screen Time API，你的应用仍然可以通过创新的方式帮助用户建立健康的数字习惯！