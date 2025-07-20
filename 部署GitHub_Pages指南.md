# 部署 GitHub Pages 网站指南

## 🚀 快速部署步骤

### 1. 将代码推送到 GitHub

```bash
# 进入项目目录
cd /Users/weifu/Desktop/AITouchGrass

# 初始化 git（如果还没有）
git init

# 添加远程仓库
git remote add origin https://github.com/WeiProduct/AITouchGrass.git

# 添加所有文件
git add .

# 提交
git commit -m "Add website and complete app implementation"

# 推送到 GitHub
git push -u origin main
```

### 2. 启用 GitHub Pages

1. 打开 https://github.com/WeiProduct/AITouchGrass
2. 点击 **Settings**（设置）
3. 左侧菜单找到 **Pages**
4. Source 选择：**Deploy from a branch**
5. Branch 选择：**main**
6. Folder 选择：**/docs**
7. 点击 **Save**

### 3. 访问你的网站

- 如果你有自己的域名，网站会在：https://aitouchgrass.com
- 如果没有域名，网站会在：https://weiproduct.github.io/AITouchGrass/

## 📝 网站内容

### 已创建的页面

1. **首页** (`index.html`)
   - 英雄区域with下载按钮
   - 核心功能介绍
   - 使用步骤说明
   - 应用截图展示
   - 常见问题解答
   - 联系方式

2. **隐私政策** (`privacy.html`)
   - 详细的隐私保护说明
   - 数据收集和使用
   - 用户权利

3. **使用条款** (`terms.html`)
   - 服务条款
   - 使用限制
   - 免责声明

### 需要添加的内容

1. **应用截图**
   在 `docs/images/` 目录下添加：
   - `app-mockup.png` - 手机模型图
   - `screenshot-1.png` - 主界面截图
   - `screenshot-2.png` - 应用选择界面
   - `screenshot-3.png` - AI识别界面
   - `screenshot-4.png` - 统计界面

2. **图标文件**
   - `apple-touch-icon.png` (180x180)
   - `favicon-32x32.png` (32x32)
   - `favicon-16x16.png` (16x16)

## 🎨 自定义修改

### 修改配色
在 `styles.css` 中修改：
```css
:root {
    --primary-color: #22c55e;  /* 主色调 - 绿色 */
    --secondary-color: #16a34a; /* 次要色调 */
}
```

### 更新 App Store 链接
当应用上架后，在 `index.html` 中更新：
```html
<a href="https://apps.apple.com/app/idXXXXXXXXX" class="btn btn-primary">
```

### 添加域名
如果你购买了域名：
1. 修改 `docs/CNAME` 文件内容为你的域名
2. 在域名提供商处添加 CNAME 记录指向 `weiproduct.github.io`

## 🔧 本地测试

```bash
# 安装 http-server（如果没有）
npm install -g http-server

# 进入 docs 目录
cd docs

# 启动本地服务器
http-server

# 访问 http://localhost:8080
```

## 📱 响应式设计

网站已完全适配：
- 💻 桌面设备
- 📱 手机设备
- 📱 平板设备

## 🚨 注意事项

1. **更新邮箱地址**
   将 `support@aitouchgrass.com` 替换为你的真实邮箱

2. **添加 Google Analytics**（可选）
   在 `</head>` 前添加：
   ```html
   <!-- Google Analytics -->
   <script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
   <script>
     window.dataLayer = window.dataLayer || [];
     function gtag(){dataLayer.push(arguments);}
     gtag('js', new Date());
     gtag('config', 'GA_MEASUREMENT_ID');
   </script>
   ```

3. **SEO 优化**
   - 已添加 meta 标签
   - 已添加 Open Graph 标签
   - 建议提交到 Google Search Console

## 🎉 完成！

你的网站现在已经准备好了！推送到 GitHub 后，几分钟内就能通过 GitHub Pages 访问。

记得在 App Store Connect 中更新：
- Support URL: https://weiproduct.github.io/AITouchGrass/ (或你的域名)
- Marketing URL: https://github.com/WeiProduct/AITouchGrass