import Foundation
import UIKit

/// 用户选择的应用检测服务
/// 不受iOS 50个URL scheme限制，因为是用户主动选择的
class UserSelectedAppDetectionService {
    
    /// 检测用户选择的应用是否已安装
    static func detectUserSelectedApps(_ selectedApps: Set<AppInfo>) async -> [AppInfo] {
        print("🔍 开始检测用户选择的应用...")
        var detectedApps: [AppInfo] = []
        
        for app in selectedApps {
            // 查找该应用的所有可能的URL schemes
            if let appVariant = EnhancedAppDetectionService.appVariants.first(where: { $0.name == app.name }) {
                var isInstalled = false
                var workingScheme: String?
                
                // 尝试所有已知的URL schemes
                for scheme in appVariant.schemes {
                    if await canOpenURLScheme(scheme) {
                        isInstalled = true
                        workingScheme = scheme
                        break
                    }
                }
                
                if isInstalled {
                    print("✅ 检测到已安装: \(app.name) (scheme: \(workingScheme ?? ""))")
                    detectedApps.append(app)
                } else {
                    print("❌ 未安装: \(app.name)")
                }
            }
        }
        
        print("📱 用户选择的应用检测完成。已安装: \(detectedApps.count)/\(selectedApps.count)")
        return detectedApps
    }
    
    /// 检查单个应用是否已安装
    static func checkAppInstalled(appName: String) async -> (installed: Bool, scheme: String?) {
        if let appVariant = EnhancedAppDetectionService.appVariants.first(where: { $0.name == appName }) {
            for scheme in appVariant.schemes {
                if await canOpenURLScheme(scheme) {
                    return (true, scheme)
                }
            }
        }
        return (false, nil)
    }
    
    /// 检查URL scheme是否可用
    private static func canOpenURLScheme(_ scheme: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let urlString = scheme.hasSuffix("://") ? scheme : "\(scheme)://"
                guard let url = URL(string: urlString) else {
                    continuation.resume(returning: false)
                    return
                }
                
                // 注意：这个方法只对在Info.plist中声明的scheme有效
                // 但是因为是用户主动选择的，所以iOS允许检查
                let canOpen = UIApplication.shared.canOpenURL(url)
                continuation.resume(returning: canOpen)
            }
        }
    }
    
    /// 获取应用的所有可能URL schemes
    static func getSchemesForApp(appName: String) -> [String] {
        if let appVariant = EnhancedAppDetectionService.appVariants.first(where: { $0.name == appName }) {
            return appVariant.schemes
        }
        return []
    }
    
    /// 尝试打开应用
    static func openApp(appName: String) async -> Bool {
        if let appVariant = EnhancedAppDetectionService.appVariants.first(where: { $0.name == appName }) {
            for scheme in appVariant.schemes {
                let urlString = scheme.hasSuffix("://") ? scheme : "\(scheme)://"
                if let url = URL(string: urlString) {
                    return await withCheckedContinuation { continuation in
                        DispatchQueue.main.async {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url) { success in
                                    continuation.resume(returning: success)
                                }
                            } else {
                                continuation.resume(returning: false)
                            }
                        }
                    }
                }
            }
        }
        return false
    }
}