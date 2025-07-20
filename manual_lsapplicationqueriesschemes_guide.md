# 手动配置LSApplicationQueriesSchemes指南

## 问题确认
从调试日志看出，所有第三方应用都显示 `❌ Cannot open`，只有系统应用显示 `✅ Can open`。这说明 **LSApplicationQueriesSchemes 没有正确配置**。

## 解决方案：在Xcode中手动添加

### 步骤1：打开项目配置
1. 在Xcode中打开 AITouchGrass 项目
2. 在左侧项目导航器中选择 **AITouchGrass** 项目（顶层文件夹）
3. 选择 **AITouchGrass** target（不是 Tests targets）
4. 点击 **Info** 标签页

### 步骤2：添加LSApplicationQueriesSchemes
1. 在 "Custom iOS Target Properties" 部分，点击 **"+"** 按钮
2. 在Key栏输入：`LSApplicationQueriesSchemes`
3. 将Type改为：**Array**（默认可能是String）
4. 点击LSApplicationQueriesSchemes左边的箭头展开数组

### 步骤3：添加URL Schemes（49个）
对于数组中的每一项，点击 **"+"** 按钮并输入以下URL schemes（不包含 `://`）：

**中国高优先级应用：**
```
weixin
wechat
weixinULAPI
mqq
mqqapi
mqqwpa
mqqOpensdkSSoLogin
mqqconnect
alipay
alipayshare
sinaweibo
weibosdk
taobao
tmall
zhihu
pinduoduo
snssdk1128
bilibili
kwai
orpheus
qqmusic
iosamap
baidumap
imeituan
eleme
diditaxi
openapp.jdmobile
baiduboxapp
dingtalk
wxwork
```

**国际应用：**
```
instagram
whatsapp
youtube
fb
twitter
tg
googlechrome
spotify
snapchat
linkedin
discord
uber
```

**系统应用：**
```
prefs
mailto
tel
sms
http
maps
itms-apps
```

### 步骤4：保存并测试
1. 保存项目（Cmd+S）
2. Clean Build Folder（Product → Clean Build Folder）
3. 重新构建应用
4. 在真机上测试

## 重要提醒

1. **不要包含 "://"**：输入 `weixin` 而不是 `weixin://`
2. **每个scheme是独立的字符串**：每个scheme占数组的一行
3. **总共49个schemes**：在iOS 50个限制内
4. **必须在真机测试**：模拟器上某些schemes可能不工作

## 预期结果

配置成功后，调试日志应该显示：
- `✅ Can open weixin` （如果安装了微信）
- `✅ Can open mqq` （如果安装了QQ）
- `✅ Can open alipay` （如果安装了支付宝）
- 等等...

应该能检测到20-30个已安装的应用，而不是只有6个系统应用。

## 验证方法

在Xcode项目配置完成后，可以在项目文件中搜索 `LSApplicationQueriesSchemes` 来确认配置是否正确添加。

## 故障排除

如果仍然检测不到应用：
1. 确保应用真的安装在测试设备上
2. 确保在真机而不是模拟器上测试
3. 尝试重新安装应用
4. 检查Xcode控制台是否还有错误消息

---

这是解决第三方应用检测问题的唯一正确方法。LSApplicationQueriesSchemes是iOS的强制要求，无法绕过。