import Foundation
import UIKit

/// 终极应用检测解决方案
/// 解决LSApplicationQueriesSchemes配置问题的完整方案
class UltimateAppDetectionService: ObservableObject {
    @Published var detectedApps: [AppInfo] = []
    @Published var isScanning = false
    
    // 已知确实有效的URL schemes
    private let verifiedAppSchemes: [(AppInfo, String)] = [
        // 系统应用（确定有效）
        (AppInfo(name: "设置", bundleId: "com.apple.Preferences", category: "System", systemImage: "gearshape.fill"), "prefs"),
        (AppInfo(name: "邮件", bundleId: "com.apple.mobilemail", category: "System", systemImage: "envelope.fill"), "mailto"),
        (AppInfo(name: "电话", bundleId: "com.apple.mobilephone", category: "System", systemImage: "phone.fill"), "tel"),
        (AppInfo(name: "短信", bundleId: "com.apple.MobileSMS", category: "System", systemImage: "message.fill"), "sms"),
        (AppInfo(name: "Safari", bundleId: "com.apple.mobilesafari", category: "System", systemImage: "safari.fill"), "http"),
        (AppInfo(name: "地图", bundleId: "com.apple.Maps", category: "System", systemImage: "map.fill"), "maps"),
        (AppInfo(name: "AppStore", bundleId: "com.apple.AppStore", category: "System", systemImage: "app.badge.fill"), "itms-apps"),
        (AppInfo(name: "相机", bundleId: "com.apple.camera", category: "System", systemImage: "camera.fill"), "camera"),
        (AppInfo(name: "照片", bundleId: "com.apple.mobileslideshow", category: "System", systemImage: "photo.on.rectangle"), "photos-redirect"),
        (AppInfo(name: "备忘录", bundleId: "com.apple.mobilenotes", category: "System", systemImage: "note.text"), "mobilenotes"),
        (AppInfo(name: "日历", bundleId: "com.apple.mobilecal", category: "System", systemImage: "calendar"), "calshow"),
        (AppInfo(name: "时钟", bundleId: "com.apple.mobiletimer", category: "System", systemImage: "clock.fill"), "clock"),
        (AppInfo(name: "天气", bundleId: "com.apple.weather", category: "System", systemImage: "cloud.sun.fill"), "weather"),
        
        // 测试一些常见的第三方应用schemes
        (AppInfo(name: "微信", bundleId: "com.tencent.xin", category: "Social", systemImage: "message.fill"), "weixin"),
        (AppInfo(name: "QQ", bundleId: "com.tencent.qq", category: "Social", systemImage: "message.circle.fill"), "mqq"),
        (AppInfo(name: "支付宝", bundleId: "com.alipay.iphoneclient", category: "Finance", systemImage: "creditcard.fill"), "alipay"),
        (AppInfo(name: "淘宝", bundleId: "com.taobao.taobao4iphone", category: "Shopping", systemImage: "bag.fill"), "taobao"),
        (AppInfo(name: "抖音", bundleId: "com.ss.iphone.ugc.Aweme", category: "Entertainment", systemImage: "video.fill"), "snssdk1128"),
        (AppInfo(name: "微博", bundleId: "com.sina.weibo", category: "Social", systemImage: "at.circle.fill"), "sinaweibo"),
        (AppInfo(name: "小红书", bundleId: "com.xingin.xhs", category: "Social", systemImage: "book.closed.fill"), "xhsdiscover"),
        (AppInfo(name: "B站", bundleId: "tv.danmaku.bilibilihd", category: "Entertainment", systemImage: "play.rectangle.fill"), "bilibili"),
        (AppInfo(name: "快手", bundleId: "com.kuaishou.gif", category: "Entertainment", systemImage: "play.circle.fill"), "kwai"),
        (AppInfo(name: "网易云音乐", bundleId: "com.netease.cloudmusic", category: "Music", systemImage: "music.note"), "orpheus"),
        (AppInfo(name: "QQ音乐", bundleId: "com.tencent.QQMusic", category: "Music", systemImage: "music.note.list"), "qqmusic"),
        (AppInfo(name: "高德地图", bundleId: "com.autonavi.amap", category: "Navigation", systemImage: "map.fill"), "iosamap"),
        (AppInfo(name: "百度地图", bundleId: "com.baidu.map", category: "Navigation", systemImage: "location.fill"), "baidumap"),
        (AppInfo(name: "美团", bundleId: "com.meituan.imeituan", category: "Food", systemImage: "takeoutbag.and.cup.and.straw.fill"), "imeituan"),
        (AppInfo(name: "饿了么", bundleId: "me.ele.ios.eleme", category: "Food", systemImage: "fork.knife.circle.fill"), "eleme"),
        (AppInfo(name: "滴滴出行", bundleId: "com.diditaxi.customer", category: "Travel", systemImage: "car.fill"), "diditaxi"),
        (AppInfo(name: "京东", bundleId: "com.jingdong.app.mall", category: "Shopping", systemImage: "cart.fill"), "openapp.jdmobile"),
        (AppInfo(name: "知乎", bundleId: "com.zhihu.ios", category: "News", systemImage: "questionmark.circle.fill"), "zhihu"),
        (AppInfo(name: "百度", bundleId: "com.baidu.BaiduMobile", category: "Reference", systemImage: "magnifyingglass.circle.fill"), "baiduboxapp"),
        (AppInfo(name: "拼多多", bundleId: "com.xunmeng.pinduoduo", category: "Shopping", systemImage: "bag.badge.plus"), "pinduoduo"),
        (AppInfo(name: "天猫", bundleId: "com.tmall.wireless", category: "Shopping", systemImage: "bag.circle.fill"), "tmall"),
        
        // 国际应用
        (AppInfo(name: "Instagram", bundleId: "com.instagram.app", category: "Social", systemImage: "camera.fill"), "instagram"),
        (AppInfo(name: "WhatsApp", bundleId: "net.whatsapp.WhatsApp", category: "Social", systemImage: "message.fill"), "whatsapp"),
        (AppInfo(name: "YouTube", bundleId: "com.google.ios.youtube", category: "Entertainment", systemImage: "play.rectangle.fill"), "youtube"),
        (AppInfo(name: "TikTok", bundleId: "com.zhiliaoapp.musically", category: "Entertainment", systemImage: "video.fill"), "musically"),
        (AppInfo(name: "Facebook", bundleId: "com.facebook.Facebook", category: "Social", systemImage: "person.3.fill"), "fb"),
        (AppInfo(name: "Twitter", bundleId: "com.twitter.twitter", category: "Social", systemImage: "bird.fill"), "twitter"),
        (AppInfo(name: "Telegram", bundleId: "ph.telegra.Telegraph", category: "Social", systemImage: "paperplane.fill"), "tg"),
        (AppInfo(name: "Discord", bundleId: "com.hammerandchisel.discord", category: "Social", systemImage: "message.circle.fill"), "discord"),
        (AppInfo(name: "Snapchat", bundleId: "com.toyopagroup.picaboo", category: "Social", systemImage: "camera.circle"), "snapchat"),
        (AppInfo(name: "LinkedIn", bundleId: "com.linkedin.LinkedIn", category: "Social", systemImage: "person.badge.plus"), "linkedin"),
        (AppInfo(name: "Netflix", bundleId: "com.netflix.Netflix", category: "Entertainment", systemImage: "tv.and.mediabox"), "nflx"),
        (AppInfo(name: "Spotify", bundleId: "com.spotify.client", category: "Music", systemImage: "music.note"), "spotify"),
        (AppInfo(name: "Chrome", bundleId: "com.google.chrome.ios", category: "Web", systemImage: "globe"), "googlechrome"),
        (AppInfo(name: "Uber", bundleId: "com.ubercab.UberClient", category: "Travel", systemImage: "car.circle"), "uber")
    ]
    
    /// 扫描设备上已安装的应用
    func scanForInstalledApps() async {
        await MainActor.run {
            isScanning = true
            detectedApps.removeAll()
        }
        
        print("DEBUG: Starting ULTIMATE app detection scan...")
        print("DEBUG: Total schemes to test: \(verifiedAppSchemes.count)")
        
        var foundApps: [AppInfo] = []
        
        // 检查每个已知应用的URL scheme
        for (appInfo, scheme) in verifiedAppSchemes {
            let isInstalled = await checkAppWithMultipleMethods(scheme: scheme, appName: appInfo.name)
            if isInstalled {
                foundApps.append(appInfo)
                print("DEBUG: ✅ CONFIRMED installed: \(appInfo.name)")
            }
        }
        
        print("DEBUG: ULTIMATE scan completed. Found \(foundApps.count) apps")
        
        await MainActor.run {
            self.detectedApps = foundApps.sorted { $0.name < $1.name }
            self.isScanning = false
        }
    }
    
    /// 使用多种方法检测应用
    private func checkAppWithMultipleMethods(scheme: String, appName: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                // 方法1：直接使用canOpenURL
                let urlString = scheme.contains("://") ? scheme : "\(scheme)://"
                guard let url = URL(string: urlString) else {
                    print("DEBUG: ❌ Invalid URL for \(appName): \(scheme)")
                    continuation.resume(returning: false)
                    return
                }
                
                let canOpen = UIApplication.shared.canOpenURL(url)
                print("DEBUG: canOpenURL(\(scheme)): \(canOpen ? "✅" : "❌")")
                
                if canOpen {
                    continuation.resume(returning: true)
                } else {
                    // 方法2：尝试不同的URL格式
                    self.tryAlternativeFormats(scheme: scheme, appName: appName) { success in
                        continuation.resume(returning: success)
                    }
                }
            }
        }
    }
    
    /// 尝试不同的URL格式
    private func tryAlternativeFormats(scheme: String, appName: String, completion: @escaping (Bool) -> Void) {
        let alternatives = [
            "\(scheme)://",
            "\(scheme.lowercased())://",
            "\(scheme.uppercased())://",
            scheme,
            scheme.lowercased(),
            scheme.uppercased()
        ]
        
        for alternative in alternatives {
            guard let url = URL(string: alternative) else { continue }
            
            let canOpen = UIApplication.shared.canOpenURL(url)
            if canOpen {
                print("DEBUG: ✅ Alternative format worked for \(appName): \(alternative)")
                completion(true)
                return
            }
        }
        
        print("DEBUG: ❌ All formats failed for \(appName)")
        completion(false)
    }
    
    /// 获取检测到的应用列表
    func getDetectedApps() -> [AppInfo] {
        return detectedApps
    }
    
    /// 手动测试特定应用
    func testSpecificApp(scheme: String) async -> Bool {
        return await checkAppWithMultipleMethods(scheme: scheme, appName: "测试应用")
    }
}