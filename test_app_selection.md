# 应用选择功能测试指南

## 修复内容

1. **添加了 `updateSelectedApps` 方法**
   - 在 `RealAppBlockingService` 中实现了手动选择应用的功能
   - 用户选择的应用会保存到 `selectedApps` 集合中

2. **更新了 `startBlocking` 方法**
   - 优先使用用户手动选择的应用
   - 如果没有手动选择，则使用 FamilyActivitySelection

3. **支持手动选择界面**
   - `ManualAppSelectionView` 显示70+个常用应用
   - 用户可以搜索、按类别筛选和选择应用
   - 选择的应用会传递给 ViewModel 进行保存

## 测试步骤

1. **打开应用**
   - 运行 AITouchGrass 应用
   - 进入"专注"标签页

2. **选择应用**
   - 点击"选择要锁定的应用"按钮
   - 在弹出的界面中：
     - 可以搜索应用名称
     - 可以按类别筛选（社交、购物、生活等）
     - 点击应用行进行选择/取消选择
     - 底部会显示已选择的应用数量

3. **确认选择**
   - 选择完成后点击"完成"
   - 应用会保存选择的应用列表

4. **启用锁定**
   - 打开锁定开关
   - 系统会根据选择的应用创建锁定规则

## 关键代码位置

- `RealAppBlockingService.swift`: 
  - `updateSelectedApps()` - 保存用户选择的应用
  - `startBlocking()` - 启动锁定时使用选择的应用

- `TouchGrassViewModel.swift`:
  - `updateBlockedApps()` - 处理应用选择更新

- `ManualAppSelectionView.swift`:
  - 手动选择应用的UI界面

## 注意事项

1. 这种方法绕过了iOS的50个URL scheme限制
2. 实际的应用锁定功能仍然需要特殊权限
3. 在模拟器中会使用演示模式

## 实际限制

根据搜索结果，iOS应用锁定的实际限制：

1. **Screen Time API 限制**
   - 需要特殊的 Family Controls entitlement
   - 需要苹果审核批准
   - 主要用于家长控制应用

2. **替代方案**
   - DNS 过滤（阻止应用网络请求）
   - 监督模式（Supervised Mode）
   - 配置文件（Configuration Profiles）
   
3. **用户体验**
   - 手动选择应用可以绕过50个URL scheme的限制
   - 但实际锁定功能仍需要系统权限
   - 当前实现主要是界面演示和记录用户选择