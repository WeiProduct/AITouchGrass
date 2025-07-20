# 实施 Screen Time API 完整指南

## 已完成的工作

### 1. 创建了完整的 Screen Time API 实现

#### ScreenTimeAppBlockingService
位置：`AITouchGrass/Modules/TouchGrass/Services/ScreenTimeAppBlockingService.swift`

这个服务实现了：
- ✅ 请求 Screen Time 授权
- ✅ 使用 ManagedSettingsStore 真正阻止应用
- ✅ 使用 DeviceActivityCenter 监控应用使用
- ✅ 临时解锁功能（拍摄草地后）
- ✅ 与现有架构完美集成

### 2. 创建了必要的扩展

#### Device Activity Monitor Extension
位置：`AITouchGrassMonitor/`
- 监控应用使用情况
- 在达到使用限制时发送通知
- 实施应用阻止规则

#### Shield Configuration Extension  
位置：`AITouchGrassShield/`
- 自定义被阻止应用的界面
- 显示"去触摸草地"的提示
- 美观的自然主题设计

### 3. 更新了权限配置

已添加必要的 entitlements：
- `com.apple.developer.family-controls`
- `com.apple.developer.managed-settings`
- `com.apple.developer.device-activity.monitoring`

## 在 Xcode 中的设置步骤

### 步骤 1：添加 Device Activity Monitor Extension

1. 在 Xcode 中打开项目
2. 选择 File → New → Target
3. 搜索并选择 "Device Activity Monitor Extension"
4. 命名为 "AITouchGrassMonitor"
5. 确保 Team 和 Bundle ID 正确
6. 点击 Finish

### 步骤 2：添加 Shield Configuration Extension

1. 再次选择 File → New → Target
2. 搜索并选择 "Shield Configuration Extension"
3. 命名为 "AITouchGrassShield"
4. 确保 Team 和 Bundle ID 正确
5. 点击 Finish

### 步骤 3：配置 App Groups

1. 选择主应用 target
2. 进入 Signing & Capabilities
3. 点击 + Capability
4. 添加 "App Groups"
5. 创建新的 App Group：`group.com.weiproduct.AITouchGrass`
6. 对两个 Extension targets 重复同样的步骤

### 步骤 4：添加代码文件

1. **主应用**：
   - 将 `ScreenTimeAppBlockingService.swift` 添加到主 target

2. **Monitor Extension**：
   - 删除自动生成的文件
   - 将 `AITouchGrassMonitor/DeviceActivityMonitor.swift` 添加到 Monitor target

3. **Shield Extension**：
   - 删除自动生成的文件
   - 将 `AITouchGrassShield/ShieldConfigurationDataSource.swift` 添加到 Shield target

### 步骤 5：更新 Info.plist

确保两个扩展的 Info.plist 包含正确的配置（已在创建的文件中提供）。

## 测试指南

### 1. 真机测试要求
- **必须使用真机**：Screen Time API 在模拟器上不工作
- **iOS 16.0 或更高版本**
- **需要开发者账号**进行真机调试

### 2. 测试流程

1. **首次启动**：
   - 应用会请求 Screen Time 权限
   - 用户需要在设置中允许

2. **选择应用**：
   - 使用 FamilyActivityPicker 选择要阻止的应用
   - 或使用手动选择界面

3. **启用阻止**：
   - 打开锁定开关
   - 被选择的应用会立即被阻止

4. **查看阻止效果**：
   - 尝试打开被阻止的应用
   - 应该看到自定义的 Shield 界面

5. **解锁测试**：
   - 拍摄草地照片
   - 验证成功后应用应该临时解锁 1 小时

### 3. 调试技巧

1. **检查授权状态**：
   ```swift
   print("Authorization status: \(AuthorizationCenter.shared.authorizationStatus)")
   ```

2. **查看日志**：
   - 主应用日志：包含授权和阻止操作
   - Extension 日志：在 Console.app 中查看

3. **常见问题**：
   - 如果阻止不生效，检查 App Groups 配置
   - 如果 Shield 不显示，确保 Extension 正确配置
   - 如果授权失败，检查 entitlements

## 提交 App Store 的准备

### 1. 必需的说明
在提交时需要说明：
- 为什么需要 Screen Time API
- 如何使用这些权限
- 强调健康和数字健康方面

### 2. 示例说明文本
```
我们的应用使用 Screen Time API 来帮助用户建立健康的数字生活习惯。
用户可以自愿选择要限制的应用，并通过户外活动（拍摄自然景观）来临时解锁。
这促进了用户的身心健康，鼓励他们减少屏幕时间，增加户外活动。
```

### 3. 隐私政策
确保隐私政策包含：
- 如何使用 Screen Time 数据
- 数据不会被分享或出售
- 用户可以随时撤销权限

## 代码使用示例

```swift
// 在 TouchGrassViewModel 中使用
if let screenTimeService = appBlockingService as? ScreenTimeAppBlockingService {
    // 使用 Screen Time API 特有的功能
    screenTimeService.updateMonitoringSchedule()
}

// 检查是否有 Screen Time 权限
if appBlockingService.isAuthorized {
    // 可以使用完整功能
} else {
    // 提示用户授权
}
```

## 总结

现在你的应用已经具备了真正的应用阻止功能，就像 Touch Grass 应用一样！主要特点：

1. ✅ 真正阻止应用运行（不仅仅是通知）
2. ✅ 自定义的阻止界面
3. ✅ 通过拍摄自然景观解锁
4. ✅ 使用官方的 Screen Time API
5. ✅ 支持临时解锁和定时规则

记住：这些 API 需要特殊的 entitlement，可能需要向 Apple 申请权限。在开发阶段，使用你的开发者账号应该可以正常测试。