import Foundation
import UIKit

struct AppSchemeVariant {
    let name: String
    let schemes: [String]  // Multiple possible schemes for the same app
    let category: String
    let systemImage: String
}

class EnhancedAppDetectionService {
    
    // Comprehensive list with multiple URL scheme variants
    static let appVariants: [AppSchemeVariant] = [
        // Chinese Social Media
        AppSchemeVariant(name: "微信", schemes: ["weixin", "wechat", "weixinULAPI", "weixin://", "wechat://"], category: "社交", systemImage: "message.fill"),
        AppSchemeVariant(name: "QQ", schemes: ["mqq", "mqqapi", "mqqwpa", "mqqconnect", "mqq://"], category: "社交", systemImage: "message.circle.fill"),
        AppSchemeVariant(name: "微博", schemes: ["sinaweibo", "weibosdk", "weibosdk2.5", "weibosdk3.3", "sinaweibohd"], category: "社交", systemImage: "text.bubble.fill"),
        AppSchemeVariant(name: "抖音", schemes: ["snssdk1128", "douyinopensdk", "douyinsharesdk", "aweme"], category: "社交", systemImage: "play.rectangle.fill"),
        AppSchemeVariant(name: "抖音极速版", schemes: ["snssdk2329"], category: "社交", systemImage: "play.rectangle.fill"),
        AppSchemeVariant(name: "小红书", schemes: ["xhsdiscover", "xiaohongshu", "rednote"], category: "社交", systemImage: "book.fill"),
        AppSchemeVariant(name: "快手", schemes: ["kwai", "kwaiAuth2", "kwaiopenapi", "gifshow", "kuaishou"], category: "社交", systemImage: "video.fill"),
        AppSchemeVariant(name: "知乎", schemes: ["zhihu", "zhihu-app"], category: "社交", systemImage: "questionmark.circle.fill"),
        
        // Chinese E-commerce
        AppSchemeVariant(name: "淘宝", schemes: ["taobao", "tbopen"], category: "购物", systemImage: "cart.fill"),
        AppSchemeVariant(name: "天猫", schemes: ["tmall", "tmall://"], category: "购物", systemImage: "bag.fill"),
        AppSchemeVariant(name: "京东", schemes: ["openapp.jdmobile", "jdmobile", "openApp.jdMobile"], category: "购物", systemImage: "bag.circle.fill"),
        AppSchemeVariant(name: "拼多多", schemes: ["pinduoduo", "pddopen"], category: "购物", systemImage: "cart.circle.fill"),
        AppSchemeVariant(name: "闲鱼", schemes: ["fleamarket"], category: "购物", systemImage: "fish.fill"),
        
        // Chinese Food & Services
        AppSchemeVariant(name: "美团", schemes: ["imeituan", "meituanwaimai"], category: "生活", systemImage: "fork.knife"),
        AppSchemeVariant(name: "饿了么", schemes: ["eleme", "elemebiz"], category: "生活", systemImage: "takeoutbag.and.cup.and.straw.fill"),
        AppSchemeVariant(name: "大众点评", schemes: ["dianping"], category: "生活", systemImage: "star.fill"),
        
        // Chinese Transportation
        AppSchemeVariant(name: "滴滴出行", schemes: ["diditaxi", "didi", "dache"], category: "出行", systemImage: "car.fill"),
        AppSchemeVariant(name: "高德地图", schemes: ["iosamap", "amapuri"], category: "出行", systemImage: "map.fill"),
        AppSchemeVariant(name: "百度地图", schemes: ["baidumap", "bdmap"], category: "出行", systemImage: "map.circle.fill"),
        AppSchemeVariant(name: "哈啰", schemes: ["hellobike"], category: "出行", systemImage: "bicycle"),
        
        // Chinese Entertainment
        AppSchemeVariant(name: "B站", schemes: ["bilibili", "bilibili://"], category: "娱乐", systemImage: "tv.fill"),
        AppSchemeVariant(name: "爱奇艺", schemes: ["qiyi-iphone", "iqiyi", "qiyitvios"], category: "娱乐", systemImage: "tv.circle.fill"),
        AppSchemeVariant(name: "腾讯视频", schemes: ["tenvideo", "tencentvideo"], category: "娱乐", systemImage: "play.tv.fill"),
        AppSchemeVariant(name: "优酷", schemes: ["youku", "youku://"], category: "娱乐", systemImage: "tv"),
        AppSchemeVariant(name: "芒果TV", schemes: ["imgotv"], category: "娱乐", systemImage: "tv.and.mediabox.fill"),
        
        // Chinese Music
        AppSchemeVariant(name: "网易云音乐", schemes: ["orpheus", "orpheuswidget", "cloudmusic"], category: "音乐", systemImage: "music.note"),
        AppSchemeVariant(name: "QQ音乐", schemes: ["qqmusic", "tencentqqmusic"], category: "音乐", systemImage: "music.note.list"),
        AppSchemeVariant(name: "酷狗音乐", schemes: ["kugou", "kugouURL"], category: "音乐", systemImage: "music.quarternote.3"),
        AppSchemeVariant(name: "酷我音乐", schemes: ["kuwo"], category: "音乐", systemImage: "music.mic"),
        
        // Chinese Finance
        AppSchemeVariant(name: "支付宝", schemes: ["alipay", "alipayshare", "alipays"], category: "金融", systemImage: "creditcard.fill"),
        AppSchemeVariant(name: "云闪付", schemes: ["upwallet"], category: "金融", systemImage: "creditcard.circle.fill"),
        
        // Chinese Productivity
        AppSchemeVariant(name: "钉钉", schemes: ["dingtalk", "dingtalk-open"], category: "办公", systemImage: "briefcase.fill"),
        AppSchemeVariant(name: "企业微信", schemes: ["wxwork", "wework"], category: "办公", systemImage: "briefcase.circle.fill"),
        AppSchemeVariant(name: "飞书", schemes: ["lark", "feishu"], category: "办公", systemImage: "doc.text.fill"),
        
        // Chinese Search & Tools
        AppSchemeVariant(name: "百度", schemes: ["baiduboxapp", "BaiduSSO", "baidumap"], category: "工具", systemImage: "magnifyingglass"),
        AppSchemeVariant(name: "百度网盘", schemes: ["baiduyun"], category: "工具", systemImage: "icloud.fill"),
        AppSchemeVariant(name: "唯品会", schemes: ["vipshop"], category: "购物", systemImage: "bag.badge.plus"),
        AppSchemeVariant(name: "大众点评", schemes: ["dianping"], category: "生活", systemImage: "star.fill"),
        AppSchemeVariant(name: "酷狗音乐", schemes: ["kugou", "kugouURL"], category: "音乐", systemImage: "music.quarternote.3"),
        
        // Chinese Games
        AppSchemeVariant(name: "王者荣耀", schemes: ["smoba", "tencentsmoba"], category: "游戏", systemImage: "gamecontroller.fill"),
        AppSchemeVariant(name: "和平精英", schemes: ["pubgmobile"], category: "游戏", systemImage: "gamecontroller"),
        AppSchemeVariant(name: "原神", schemes: ["genshinimpact", "mihoyogenshin"], category: "游戏", systemImage: "sparkles"),
        
        // International Apps
        AppSchemeVariant(name: "Instagram", schemes: ["instagram", "instagram-stories"], category: "社交", systemImage: "camera.fill"),
        AppSchemeVariant(name: "WhatsApp", schemes: ["whatsapp", "whatsapp://"], category: "社交", systemImage: "message.fill"),
        AppSchemeVariant(name: "Facebook", schemes: ["fb", "facebook"], category: "社交", systemImage: "person.2.fill"),
        AppSchemeVariant(name: "Twitter", schemes: ["twitter", "twitterrific"], category: "社交", systemImage: "text.bubble.fill"),
        AppSchemeVariant(name: "X", schemes: ["twitter", "x-com"], category: "社交", systemImage: "text.bubble.fill"),
        AppSchemeVariant(name: "Telegram", schemes: ["tg", "telegram"], category: "社交", systemImage: "paperplane.fill"),
        AppSchemeVariant(name: "Discord", schemes: ["discord", "com.hammerandchisel.discord"], category: "社交", systemImage: "bubble.left.and.bubble.right.fill"),
        AppSchemeVariant(name: "Snapchat", schemes: ["snapchat"], category: "社交", systemImage: "camera.circle.fill"),
        AppSchemeVariant(name: "LinkedIn", schemes: ["linkedin", "linkedin-sdk"], category: "社交", systemImage: "briefcase.fill"),
        AppSchemeVariant(name: "YouTube", schemes: ["youtube", "vnd.youtube"], category: "娱乐", systemImage: "play.rectangle.fill"),
        AppSchemeVariant(name: "TikTok", schemes: ["snssdk1233", "musically", "tiktok"], category: "娱乐", systemImage: "music.note.tv.fill"),
        AppSchemeVariant(name: "Netflix", schemes: ["nflx"], category: "娱乐", systemImage: "tv.fill"),
        AppSchemeVariant(name: "Spotify", schemes: ["spotify", "spotify-action"], category: "音乐", systemImage: "music.note.list"),
        AppSchemeVariant(name: "Google Chrome", schemes: ["googlechrome", "googlechromes", "chrome"], category: "工具", systemImage: "globe"),
        AppSchemeVariant(name: "Gmail", schemes: ["googlegmail"], category: "工具", systemImage: "envelope.fill"),
        AppSchemeVariant(name: "Google Maps", schemes: ["googlemaps", "comgooglemaps"], category: "出行", systemImage: "map.fill"),
        AppSchemeVariant(name: "Uber", schemes: ["uber"], category: "出行", systemImage: "car.fill"),
        
        // System Apps
        AppSchemeVariant(name: "设置", schemes: ["prefs", "app-settings", "App-prefs"], category: "系统", systemImage: "gear"),
        AppSchemeVariant(name: "邮件", schemes: ["mailto"], category: "系统", systemImage: "envelope.fill"),
        AppSchemeVariant(name: "电话", schemes: ["tel", "telprompt"], category: "系统", systemImage: "phone.fill"),
        AppSchemeVariant(name: "短信", schemes: ["sms"], category: "系统", systemImage: "message.fill"),
        AppSchemeVariant(name: "Safari", schemes: ["http", "https"], category: "系统", systemImage: "safari.fill"),
        AppSchemeVariant(name: "地图", schemes: ["maps", "map"], category: "系统", systemImage: "map.fill"),
        AppSchemeVariant(name: "App Store", schemes: ["itms-apps", "itms", "itms-appss"], category: "系统", systemImage: "bag.fill")
    ]
    
    static func detectInstalledApps() async -> [AppInfo] {
        var detectedApps: [AppInfo] = []
        var processedApps = Set<String>() // To avoid duplicates
        
        for appVariant in appVariants {
            var detected = false
            var workingScheme: String?
            
            // Try each scheme variant
            for scheme in appVariant.schemes {
                if await canOpenURLScheme(scheme) {
                    detected = true
                    workingScheme = scheme
                    break
                }
            }
            
            if detected, !processedApps.contains(appVariant.name) {
                processedApps.insert(appVariant.name)
                print("✅ Detected: \(appVariant.name) using scheme: \(workingScheme ?? "")")
                
                let app = AppInfo(
                    name: appVariant.name,
                    bundleId: "detected.app.\(appVariant.name)",
                    category: appVariant.category,
                    systemImage: appVariant.systemImage
                )
                detectedApps.append(app)
            }
        }
        
        print("📱 Enhanced detection completed. Found \(detectedApps.count) apps")
        return detectedApps
    }
    
    static func canOpenURLScheme(_ scheme: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let urlString = scheme.hasSuffix("://") ? scheme : "\(scheme)://"
                guard let url = URL(string: urlString) else {
                    continuation.resume(returning: false)
                    return
                }
                
                let canOpen = UIApplication.shared.canOpenURL(url)
                continuation.resume(returning: canOpen)
            }
        }
    }
    
    // Test specific app with all its variants
    static func testAppSchemes(appName: String) async -> [(scheme: String, canOpen: Bool)] {
        guard let appVariant = appVariants.first(where: { $0.name == appName }) else {
            return []
        }
        
        var results: [(scheme: String, canOpen: Bool)] = []
        
        for scheme in appVariant.schemes {
            let canOpen = await canOpenURLScheme(scheme)
            results.append((scheme: scheme, canOpen: canOpen))
            print("Testing \(appName) - Scheme: \(scheme) - Can open: \(canOpen)")
        }
        
        return results
    }
}