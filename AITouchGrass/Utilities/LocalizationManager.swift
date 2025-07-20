import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("preferredLanguage") private var preferredLanguage: String = "zh-Hans"
    @Published var currentLanguage: String = "zh-Hans"
    
    private init() {
        currentLanguage = preferredLanguage
    }
    
    func toggleLanguage() {
        if currentLanguage == "zh-Hans" {
            currentLanguage = "en"
            preferredLanguage = "en"
        } else {
            currentLanguage = "zh-Hans"
            preferredLanguage = "zh-Hans"
        }
        
        // Force app to refresh UI
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    func localizedString(_ key: String) -> String {
        // English translations
        let englishTranslations: [String: String] = [
            // App Name and Core
            "AITouchGrass": "AITouchGrass",
            "让AI帮你戒掉手机瘾": "Let AI help you break phone addiction",
            
            // Main View
            "已锁定 %d 个应用": "Locked %d apps",
            "选择要锁定的应用": "Select apps to lock",
            "开始户外之旅": "Start outdoor journey",
            "统计数据": "Statistics",
            
            // App Selection
            "选择应用": "Select Apps",
            "搜索应用": "Search apps",
            "完成": "Done",
            "取消": "Cancel",
            
            // Touch Grass View
            "拍摄自然照片": "Take a nature photo",
            "拍摄一张包含草地或自然景观的照片来解锁应用": "Take a photo with grass or nature to unlock apps",
            "拍照": "Take Photo",
            "从相册选择": "Choose from Gallery",
            "正在分析图片...": "Analyzing image...",
            "太棒了！": "Awesome!",
            "检测到自然元素，应用已解锁！": "Nature detected, apps unlocked!",
            "再试一次": "Try again",
            "未检测到足够的自然元素": "Not enough nature detected",
            "请拍摄包含更多自然景观的照片": "Please take a photo with more nature",
            "检测到：": "Detected:",
            
            // Statistics View
            "使用统计": "Usage Statistics",
            "今日": "Today",
            "本周": "This Week",
            "全部": "All Time",
            "户外活动": "Outdoor Activities",
            "次": "times",
            "解锁应用": "Apps Unlocked",
            "今日活动": "Today's Activities",
            "还没有记录": "No records yet",
            "快去户外走走吧！": "Go outside and explore!",
            "%@ 在 %@": "%@ at %@",
            
            // Settings
            "设置": "Settings",
            "语言": "Language",
            "中文": "Chinese",
            "English": "English",
            "隐私政策": "Privacy Policy",
            "使用条款": "Terms of Use",
            "关于": "About",
            "版本": "Version",
            
            // Home View
            "今日天气": "Today's Weather",
            "今日": "Today",
            "活动": "Activities",
            "连续": "Streak",
            "天": "Days",
            "户外时间": "Outdoor Time",
            "周目标": "Weekly Goal",
            "完成": "Complete",
            "快速开始": "Quick Start",
            "步行": "Walk",
            "跑步": "Run",
            "骑行": "Cycle",
            "自定义": "Custom",
            "最近活动": "Recent Activities",
            "还没有活动记录。开始你的第一次户外活动吧！": "No activities yet. Start your first outdoor activity!",
            
            // TouchGrass View
            "专注": "Focus",
            "提示": "Notice",
            "确定": "OK",
            "演示模式": "Demo Mode",
            "当前在模拟器中运行，使用演示模式": "Running in simulator, using demo mode",
            "Family Controls API 不可用，使用演示模式": "Family Controls API unavailable, using demo mode",
            "应用阻塞功能为模拟效果（仅发送通知提醒）": "App blocking simulated (notifications only)",
            "在真机上可获得完整功能": "Full features available on real device",
            "需要iOS设备和开发者账号": "Requires iOS device and developer account",
            "Family Controls需要特殊Apple权限": "Family Controls requires special Apple permission",
            "需要申请Screen Time entitlement": "Need to apply for Screen Time entitlement",
            "当前使用演示模式进行体验": "Currently using demo mode for experience",
            "需要授权": "Authorization Required",
            "使用此功能需要屏幕使用时间权限": "This feature requires Screen Time permission",
            "授权屏幕使用时间": "Authorize Screen Time",
            "锁定状态": "Lock Status",
            "已启用": "Enabled",
            "未启用": "Disabled",
            "临时解锁剩余时间": "Remaining unlock time",
            "需要屏幕使用时间权限": "Screen Time permission required",
            "立即授权": "Authorize Now",
            "锁定的内容": "Locked Content",
            "项": "items",
            "选择的应用": "Selected Apps"
        ]
        
        if currentLanguage == "en" {
            return englishTranslations[key] ?? key
        }
        
        return key
    }
}

// Convenience function
func L(_ key: String) -> String {
    LocalizationManager.shared.localizedString(key)
}

// SwiftUI View Extension
extension View {
    func localized() -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force view refresh
        }
    }
}