#!/bin/bash

PROJECT_FILE="/Users/weifu/Desktop/AITouchGrass/AITouchGrass.xcodeproj/project.pbxproj"

# 备份项目文件
cp "$PROJECT_FILE" "$PROJECT_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# 使用Python添加URL schemes到项目配置
python3 << 'PYTHON_EOF'
import re

project_file = "/Users/weifu/Desktop/AITouchGrass/AITouchGrass.xcodeproj/project.pbxproj"

url_schemes = [
    "weixin", "mqq", "sinaweibo", "xhsdiscover", "instagram", "fb", "twitter",
    "whatsapp", "tg", "discord", "snssdk1128", "kwai", "bilibili", "taobao",
    "alipay", "orpheus", "qqmusic", "diditaxi", "iosamap", "zhihu", "youtube",
    "spotify", "uber", "amazon", "prefs", "mailto", "tel", "sms", "maps"
]

try:
    with open(project_file, 'r') as f:
        content = f.read()
    
    # 添加LSApplicationQueriesSchemes到项目配置
    schemes_string = '\\n'.join([f'\t\t\t\t\t<string>{scheme}</string>' for scheme in url_schemes])
    
    # 查找buildSettings部分并添加LSApplicationQueriesSchemes
    pattern = r'(buildSettings = \{[^}]*?)(IPHONEOS_DEPLOYMENT_TARGET = [^;]*;)'
    replacement = f'''\\1INFOPLIST_KEY_LSApplicationQueriesSchemes = (
\t\t\t\t\t{schemes_string}
\t\t\t\t);
\t\t\t\t\\2'''
    
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
    
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ URL schemes added to project configuration")
    
except Exception as e:
    print(f"❌ Failed to add URL schemes: {e}")
    import sys
    sys.exit(1)
PYTHON_EOF

echo "✅ URL schemes配置已添加到项目中"
echo "现在需要重新构建应用以使更改生效"
