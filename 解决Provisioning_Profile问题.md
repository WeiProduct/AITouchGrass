# 解决 Provisioning Profile Entitlements 问题

## 🚨 问题分析

错误信息：
```
Provisioning profile "AITouchGrass_Dev_v2" doesn't include the 
com.apple.developer.device-activity.monitoring and 
com.apple.developer.managed-settings entitlements.
```

这意味着：
1. 你的 entitlements 文件包含了 Family Controls 权限
2. 但是你的 Provisioning Profile 没有这些权限
3. 因为 Apple 还没有批准你的 Family Controls 申请

## 🔧 临时解决方案

### 方案 1：移除 Family Controls Entitlements（推荐）

暂时移除这些 entitlements，等 Apple 批准后再添加：

1. **编辑 entitlements 文件**
2. **注释或删除以下权限**：
   - com.apple.developer.family-controls
   - com.apple.developer.managed-settings
   - com.apple.developer.device-activity.monitoring

### 方案 2：创建两个版本的 Entitlements

1. **AITouchGrass.entitlements**（当前使用）
   - 不包含 Family Controls 权限
   - 用于提交 App Store

2. **AITouchGrass-ScreenTime.entitlements**（未来使用）
   - 包含所有 Family Controls 权限
   - 等批准后使用

## 📝 立即执行步骤

### 1. 备份当前 entitlements
```bash
cp AITouchGrass/AITouchGrass.entitlements AITouchGrass/AITouchGrass-ScreenTime.entitlements
```

### 2. 修改当前 entitlements
从 `AITouchGrass.entitlements` 中移除：
- com.apple.developer.device-activity.monitoring
- com.apple.developer.family-controls
- com.apple.developer.managed-settings

只保留：
- com.apple.developer.devicecheck.appattest-environment

### 3. 重新生成 Provisioning Profile
1. 登录 [Apple Developer](https://developer.apple.com)
2. Certificates, Identifiers & Profiles
3. 创建新的 Provisioning Profile
4. 下载并在 Xcode 中安装

## 🎯 完整的解决流程

### 现在（提交 App Store）
1. ✅ 使用简化的 entitlements（无 Family Controls）
2. ✅ 使用 RealAppBlockingService（通知提醒）
3. ✅ 成功提交到 App Store Connect
4. ✅ 通过审核并发布

### 申请批准后
1. ⏳ Family Controls entitlement 获批
2. ⏳ 更新 App ID 配置
3. ⏳ 使用完整的 entitlements
4. ⏳ 启用 ScreenTimeAppBlockingService
5. ⏳ 发布更新版本

## 📋 修改后的 Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.devicecheck.appattest-environment</key>
    <string>development</string>
</dict>
</plist>
```

## 💡 重要提示

1. **这是正常流程**
   - Touch Grass 也经历了同样的过程
   - 先发布基础版本，后添加高级功能

2. **不影响核心功能**
   - 通知提醒系统正常工作
   - 草地识别功能完整
   - 使用统计功能可用

3. **用户体验**
   - 在应用说明中诚实告知当前限制
   - 承诺未来会添加真正的应用阻止功能
   - 强调现有功能的价值

## 🚀 行动计划

1. **立即**：修改 entitlements，重新构建
2. **今天**：提交到 App Store Connect
3. **本周**：提交 Family Controls 申请
4. **1-3月后**：获批后发布 2.0 版本

## 📝 App Store 描述建议

```
AITouchGrass - 让AI帮你养成户外习惯

【核心功能】
• 智能提醒：在您使用手机过度时温馨提醒
• AI识别：拍摄草地、树木等自然景观解锁应用
• 健康追踪：记录户外活动时间和频率
• 使用统计：了解您的数字生活习惯

【即将推出】
• 真正的应用限制功能（需要系统权限，正在申请中）
• 家长控制模式
• 更多户外活动挑战

让我们一起，少看屏幕，多看风景！
```

记住：即使没有 Family Controls，你的应用依然很有价值！