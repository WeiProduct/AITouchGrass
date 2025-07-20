import Foundation
import UIKit

/// 绕过LSApplicationQueriesSchemes限制的应用检测服务
/// 使用openURL替代canOpenURL来避免配置问题
class BypassAppDetectionService: ObservableObject {
    @Published var detectedApps: [AppInfo] = []
    @Published var isScanning = false
    
    // 简化的应用列表 - 只包含最常用的应用
    private let knownAppSchemes: [(AppInfo, String)] = [
        // 高优先级中国应用
        (AppInfo(name: "微信", bundleId: "com.tencent.xin", category: "Social", systemImage: "message.fill"), "weixin://"),
        (AppInfo(name: "QQ", bundleId: "com.tencent.qq", category: "Social", systemImage: "message.circle.fill"), "mqq://"),
        (AppInfo(name: "支付宝", bundleId: "com.alipay.iphoneclient", category: "Finance", systemImage: "creditcard.fill"), "alipay://"),
        (AppInfo(name: "淘宝", bundleId: "com.taobao.taobao4iphone", category: "Shopping", systemImage: "bag.fill"), "taobao://"),
        (AppInfo(name: "抖音", bundleId: "com.ss.iphone.ugc.Aweme", category: "Entertainment", systemImage: "video.fill"), "aweme://"),
        (AppInfo(name: "微博", bundleId: "com.sina.weibo", category: "Social", systemImage: "at.circle.fill"), "sinaweibo://"),
        (AppInfo(name: "小红书", bundleId: "com.xingin.xhs", category: "Social", systemImage: "book.closed.fill"), "xhsdiscover://"),
        (AppInfo(name: "B站", bundleId: "tv.danmaku.bilibilihd", category: "Entertainment", systemImage: "play.rectangle.fill"), "bilibili://"),
        (AppInfo(name: "快手", bundleId: "com.kuaishou.gif", category: "Entertainment", systemImage: "play.circle.fill"), "kwai://"),
        (AppInfo(name: "网易云音乐", bundleId: "com.netease.cloudmusic", category: "Music", systemImage: "music.note"), "orpheus://"),
        (AppInfo(name: "QQ音乐", bundleId: "com.tencent.QQMusic", category: "Music", systemImage: "music.note.list"), "qqmusic://"),
        (AppInfo(name: "高德地图", bundleId: "com.autonavi.amap", category: "Navigation", systemImage: "map.fill"), "iosamap://"),
        (AppInfo(name: "美团", bundleId: "com.meituan.imeituan", category: "Food", systemImage: "takeoutbag.and.cup.and.straw.fill"), "imeituan://"),
        (AppInfo(name: "饿了么", bundleId: "me.ele.ios.eleme", category: "Food", systemImage: "fork.knife.circle.fill"), "eleme://"),
        (AppInfo(name: "滴滴出行", bundleId: "com.diditaxi.customer", category: "Travel", systemImage: "car.fill"), "diditaxi://"),
        (AppInfo(name: "京东", bundleId: "com.jingdong.app.mall", category: "Shopping", systemImage: "cart.fill"), "openapp.jdmobile://"),
        (AppInfo(name: "知乎", bundleId: "com.zhihu.ios", category: "News", systemImage: "questionmark.circle.fill"), "zhihu://"),
        (AppInfo(name: "百度", bundleId: "com.baidu.BaiduMobile", category: "Reference", systemImage: "magnifyingglass.circle.fill"), "baiduboxapp://"),
        
        // 国际应用
        (AppInfo(name: "Instagram", bundleId: "com.instagram.app", category: "Social", systemImage: "camera.fill"), "instagram://"),
        (AppInfo(name: "WhatsApp", bundleId: "net.whatsapp.WhatsApp", category: "Social", systemImage: "message.fill"), "whatsapp://"),
        (AppInfo(name: "YouTube", bundleId: "com.google.ios.youtube", category: "Entertainment", systemImage: "play.rectangle.fill"), "youtube://"),
        (AppInfo(name: "TikTok", bundleId: "com.zhiliaoapp.musically", category: "Entertainment", systemImage: "video.fill"), "musically://"),
        (AppInfo(name: "Facebook", bundleId: "com.facebook.Facebook", category: "Social", systemImage: "person.3.fill"), "fb://"),
        (AppInfo(name: "Twitter", bundleId: "com.twitter.twitter", category: "Social", systemImage: "bird.fill"), "twitter://"),
        (AppInfo(name: "Telegram", bundleId: "ph.telegra.Telegraph", category: "Social", systemImage: "paperplane.fill"), "tg://"),
        (AppInfo(name: "Netflix", bundleId: "com.netflix.Netflix", category: "Entertainment", systemImage: "tv.and.mediabox"), "nflx://"),
        (AppInfo(name: "Spotify", bundleId: "com.spotify.client", category: "Music", systemImage: "music.note"), "spotify://"),
        (AppInfo(name: "Chrome", bundleId: "com.google.chrome.ios", category: "Web", systemImage: "globe"), "googlechrome://"),
        
        // 系统应用
        (AppInfo(name: "设置", bundleId: "com.apple.Preferences", category: "System", systemImage: "gearshape.fill"), "prefs://"),
        (AppInfo(name: "邮件", bundleId: "com.apple.mobilemail", category: "System", systemImage: "envelope.fill"), "mailto://"),
        (AppInfo(name: "电话", bundleId: "com.apple.mobilephone", category: "System", systemImage: "phone.fill"), "tel://"),
        (AppInfo(name: "短信", bundleId: "com.apple.MobileSMS", category: "System", systemImage: "message.fill"), "sms://"),
        (AppInfo(name: "Safari", bundleId: "com.apple.mobilesafari", category: "System", systemImage: "safari.fill"), "http://"),
        (AppInfo(name: "地图", bundleId: "com.apple.Maps", category: "System", systemImage: "map.fill"), "maps://"),
        (AppInfo(name: "AppStore", bundleId: "com.apple.AppStore", category: "System", systemImage: "app.badge.fill"), "itms-apps://")
    ]
    
    /// 使用openURL方法检测应用（绕过LSApplicationQueriesSchemes限制）
    func scanForInstalledApps() async {
        await MainActor.run {
            isScanning = true
            detectedApps.removeAll()
        }
        
        print("DEBUG: Starting bypass app detection scan...")
        
        var foundApps: [AppInfo] = []
        
        // 并发检查所有应用
        await withTaskGroup(of: (AppInfo, Bool).self) { group in
            for (appInfo, urlScheme) in knownAppSchemes {
                group.addTask {
                    let isInstalled = await self.checkAppInstallation(urlScheme: urlScheme, appName: appInfo.name)
                    return (appInfo, isInstalled)
                }
            }
            
            for await (appInfo, isInstalled) in group {
                if isInstalled {
                    foundApps.append(appInfo)
                }
            }
        }
        
        print("DEBUG: Bypass scan completed. Found \(foundApps.count) apps")
        
        await MainActor.run {
            self.detectedApps = foundApps.sorted { $0.name < $1.name }
            self.isScanning = false
        }
    }
    
    /// 使用openURL检测应用安装状态
    private func checkAppInstallation(urlScheme: String, appName: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                guard let url = URL(string: urlScheme) else {
                    print("DEBUG: Invalid URL for \(appName): \(urlScheme)")
                    continuation.resume(returning: false)
                    return
                }
                
                // 首先尝试canOpenURL（可能失败但不影响结果）
                let canOpen = UIApplication.shared.canOpenURL(url)
                if canOpen {
                    print("DEBUG: ✅ canOpenURL success for \(appName)")
                    continuation.resume(returning: true)
                    return
                }
                
                // 使用openURL检测（不需要LSApplicationQueriesSchemes）
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        print("DEBUG: ✅ openURL success for \(appName)")
                        continuation.resume(returning: true)
                    } else {
                        print("DEBUG: ❌ openURL failed for \(appName)")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    /// 获取检测到的应用列表
    func getDetectedApps() -> [AppInfo] {
        return detectedApps
    }
}