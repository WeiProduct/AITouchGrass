// Language translations
const translations = {
    zh: {
        // Navigation
        'nav.features': '功能',
        'nav.how-it-works': '使用方法',
        'nav.screenshots': '截图',
        'nav.faq': '常见问题',
        'nav.contact': '联系',
        'lang.switch': 'EN',
        
        // Hero Section
        'hero.title1': '让AI帮你',
        'hero.title2': '触摸真实世界',
        'hero.subtitle': '用AI识别自然景观，鼓励户外活动！通过拍摄草地或自然照片来解锁被限制的应用，培养健康的数字生活习惯。',
        'hero.download': '下载 App',
        'hero.github': '查看源码',
        
        // Features
        'features.title': '核心功能',
        'features.ai.title': 'AI智能识别',
        'features.ai.desc': '使用先进的机器学习技术，准确识别草地、树木等自然元素',
        'features.block.title': '应用锁定管理',
        'features.block.desc': '自定义选择需要限制的应用，合理管理屏幕使用时间',
        'features.stats.title': '活动统计追踪',
        'features.stats.desc': '详细记录户外活动时间和频率，可视化展示进步',
        'features.health.title': '健康数据同步',
        'features.health.desc': '与Apple Health集成，全面追踪您的健康生活方式',
        
        // How it works
        'how.title': '如何使用',
        'how.step1.title': '1. 选择应用',
        'how.step1.desc': '选择您想要限制使用的应用',
        'how.step2.title': '2. 设定目标',
        'how.step2.desc': '设置每日户外活动时间目标',
        'how.step3.title': '3. 拍摄自然',
        'how.step3.desc': 'AI识别自然景观后解锁应用',
        'how.step4.title': '4. 追踪进度',
        'how.step4.desc': '查看统计数据，保持健康习惯',
        
        // FAQ
        'faq.title': '常见问题',
        'faq.q1': 'AI识别准确吗？',
        'faq.a1': '我们使用最新的Vision框架和Core ML技术，能够准确识别草地、树木、花朵等自然元素。识别准确率超过95%。',
        'faq.q2': '可以限制哪些应用？',
        'faq.a2': '您可以选择任何已安装的应用进行限制。常见的包括社交媒体、游戏、视频等应用。',
        'faq.q3': '需要网络连接吗？',
        'faq.a3': '不需要！所有AI识别都在本地进行，保护您的隐私，无需网络连接。',
        'faq.q4': '如何确保隐私安全？',
        'faq.a4': '所有照片仅在本地处理，不会上传到任何服务器。我们非常重视您的隐私保护。',
        
        // Contact
        'contact.title': '联系我们',
        'contact.subtitle': '有任何问题或建议？我们很乐意听到您的反馈！',
        'contact.email': '邮箱',
        'contact.github': 'GitHub',
        
        // Footer
        'footer.privacy': '隐私政策',
        'footer.terms': '使用条款',
        'footer.rights': '© 2025 Wei Fu. All rights reserved.'
    },
    en: {
        // Navigation
        'nav.features': 'Features',
        'nav.how-it-works': 'How it Works',
        'nav.screenshots': 'Screenshots',
        'nav.faq': 'FAQ',
        'nav.contact': 'Contact',
        'lang.switch': '中文',
        
        // Hero Section
        'hero.title1': 'Let AI Help You',
        'hero.title2': 'Touch the Real World',
        'hero.subtitle': 'Use AI to identify natural landscapes and encourage outdoor activities! Unlock restricted apps by taking photos of grass or nature, and develop healthy digital habits.',
        'hero.download': 'Download App',
        'hero.github': 'View Source',
        
        // Features
        'features.title': 'Core Features',
        'features.ai.title': 'AI Smart Recognition',
        'features.ai.desc': 'Uses advanced machine learning to accurately identify grass, trees and other natural elements',
        'features.block.title': 'App Lock Management',
        'features.block.desc': 'Customize which apps to restrict and manage your screen time effectively',
        'features.stats.title': 'Activity Tracking',
        'features.stats.desc': 'Detailed recording of outdoor activity time and frequency with visual progress',
        'features.health.title': 'Health Data Sync',
        'features.health.desc': 'Integrates with Apple Health to comprehensively track your healthy lifestyle',
        
        // How it works
        'how.title': 'How to Use',
        'how.step1.title': '1. Select Apps',
        'how.step1.desc': 'Choose the apps you want to restrict',
        'how.step2.title': '2. Set Goals',
        'how.step2.desc': 'Set daily outdoor activity time goals',
        'how.step3.title': '3. Capture Nature',
        'how.step3.desc': 'AI recognizes natural scenery to unlock apps',
        'how.step4.title': '4. Track Progress',
        'how.step4.desc': 'View statistics and maintain healthy habits',
        
        // FAQ
        'faq.title': 'Frequently Asked Questions',
        'faq.q1': 'Is the AI recognition accurate?',
        'faq.a1': 'We use the latest Vision framework and Core ML technology to accurately identify grass, trees, flowers and other natural elements. Recognition accuracy exceeds 95%.',
        'faq.q2': 'Which apps can be restricted?',
        'faq.a2': 'You can select any installed app for restriction. Common ones include social media, games, video apps, etc.',
        'faq.q3': 'Is internet connection required?',
        'faq.a3': 'No! All AI recognition is done locally on your device, protecting your privacy without needing internet.',
        'faq.q4': 'How is privacy ensured?',
        'faq.a4': 'All photos are processed locally only and never uploaded to any server. We take your privacy very seriously.',
        
        // Contact
        'contact.title': 'Contact Us',
        'contact.subtitle': 'Have questions or suggestions? We\'d love to hear your feedback!',
        'contact.email': 'Email',
        'contact.github': 'GitHub',
        
        // Footer
        'footer.privacy': 'Privacy Policy',
        'footer.terms': 'Terms of Use',
        'footer.rights': '© 2025 Wei Fu. All rights reserved.'
    }
};

// Language switching functionality
let currentLang = localStorage.getItem('lang') || 'zh';

function setLanguage(lang) {
    currentLang = lang;
    localStorage.setItem('lang', lang);
    document.documentElement.setAttribute('data-lang', lang);
    document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';
    
    // Update all elements with data-lang-key
    document.querySelectorAll('[data-lang-key]').forEach(element => {
        const key = element.getAttribute('data-lang-key');
        if (translations[lang][key]) {
            element.textContent = translations[lang][key];
        }
    });
    
    // Update meta tags
    if (lang === 'en') {
        document.querySelector('meta[name="description"]').content = 'AITouchGrass - Let AI help you develop healthy digital habits. Take photos of nature to unlock restricted apps.';
        document.querySelector('meta[property="og:title"]').content = 'AITouchGrass - AI-Powered Digital Wellness Assistant';
        document.querySelector('meta[property="og:description"]').content = 'Use AI to identify natural landscapes and encourage outdoor activities! Let technology help you develop healthy digital habits.';
        document.title = 'AITouchGrass - AI-Powered Digital Wellness Assistant';
    } else {
        document.querySelector('meta[name="description"]').content = 'AITouchGrass - 用AI帮你养成健康的数字生活习惯。拍摄自然景观，解锁被限制的应用。';
        document.querySelector('meta[property="og:title"]').content = 'AITouchGrass - AI驱动的数字健康助手';
        document.querySelector('meta[property="og:description"]').content = '用AI识别自然景观，鼓励户外活动！让科技帮你养成健康的数字生活习惯。';
        document.title = 'AITouchGrass - AI驱动的数字健康助手';
    }
}

// Function to bind language toggle events
function bindLanguageToggle() {
    // Find all language toggle buttons (including in mobile menu)
    document.querySelectorAll('#langToggle, .lang-btn').forEach(btn => {
        // Remove existing listeners to avoid duplicates
        btn.replaceWith(btn.cloneNode(true));
    });
    
    // Re-bind events to all language toggle buttons
    document.querySelectorAll('#langToggle, .lang-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const newLang = currentLang === 'zh' ? 'en' : 'zh';
            setLanguage(newLang);
        });
    });
}

// Initialize language on page load
document.addEventListener('DOMContentLoaded', () => {
    setLanguage(currentLang);
    
    // Wait a bit for script.js to create mobile menu
    setTimeout(() => {
        bindLanguageToggle();
    }, 100);
});

// Also bind when window loads completely
window.addEventListener('load', () => {
    bindLanguageToggle();
});