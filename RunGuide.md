# AITouchGrass 运行指南

## 🚀 快速开始

### 1. 在 Xcode 中打开项目
项目应该已经在 Xcode 中打开了。如果没有，请运行：
```bash
open AITouchGrass.xcodeproj
```

### 2. 解决编译错误

当你在 Xcode 中看到编译错误时，大多数都可以通过以下方式快速修复：

#### 常见错误和解决方案：

**错误 1: "Non-sendable result type"**
- 点击错误
- 选择 "Fix" 或添加 `@MainActor` 到相关函数

**错误 2: "Type 'Date' has no member 'today'"**
- 将 `.today` 改为 `Date()`

**错误 3: "Instance method requires that X conform to Y"**
- 点击错误
- 选择 "Add protocol stubs"

### 3. 清理和构建
- 按 `Cmd+Shift+K` 清理构建文件夹
- 按 `Cmd+B` 构建项目

### 4. 运行应用
- 选择 iPhone 模拟器（顶部工具栏）
- 按 `Cmd+R` 运行

## 🛠 手动修复步骤

如果自动修复不起作用，可以手动进行以下修改：

### 1. 在 HomeViewModel.swift 中
找到 `loadDashboardData()` 函数，确保它有 `@MainActor` 标记：
```swift
@MainActor
private func loadDashboardData() async {
    // ...
}
```

### 2. 在 ActivityCoordinator.swift 中
确保 view creation 不包含设置 coordinator 的代码：
```swift
case .tracking:
    ActivityTrackingView(viewModel: ActivityTrackingViewModel(
        activityService: serviceContainer.activityService,
        locationService: serviceContainer.locationService,
        healthKitService: serviceContainer.healthKitService
    ))
```

### 3. 在 QuickAction 枚举中
确保它符合 Identifiable：
```swift
enum QuickAction: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    // ...
}
```

## 📱 应用功能测试

一旦应用成功运行，你可以测试以下功能：

1. **首页标签**
   - 查看仪表板统计
   - 点击快速开始按钮

2. **活动标签**
   - 选择运动类型
   - 开始活动跟踪

3. **统计标签**
   - 查看图表
   - 切换时间范围

4. **我的标签**
   - 查看个人信息
   - 编辑设置

## ⚠️ 注意事项

- 首次运行会请求权限，请允许位置和健康数据访问
- 模拟器的GPS功能有限，某些功能可能无法完全测试
- 如果遇到崩溃，请检查控制台日志

## 🆘 如果还是无法运行

1. 确保 Xcode 版本是 15.0 或更高
2. 确保选择了正确的开发团队（如果需要）
3. 尝试重启 Xcode
4. 删除 DerivedData：
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/AITouchGrass-*
   ```

祝你运行成功！🎉