import Foundation
import UIKit

/// 真实应用检测服务 - 基于用户手动选择
/// 不自动扫描，避免iOS 50个URL scheme限制
class RealAppDetectionService: ObservableObject {
    @Published var detectedApps: [AppInfo] = []
    @Published var isScanning = false
    
    /// 检测用户选择的应用是否已安装
    func checkSelectedApps(_ selectedApps: Set<AppInfo>) async {
        await MainActor.run {
            isScanning = true
        }
        
        print("DEBUG: 检查用户选择的 \(selectedApps.count) 个应用...")
        
        let installedApps = await UserSelectedAppDetectionService.detectUserSelectedApps(selectedApps)
        
        await MainActor.run {
            self.detectedApps = installedApps.sorted { $0.name < $1.name }
            self.isScanning = false
            print("DEBUG: 检测完成。已安装: \(installedApps.count)/\(selectedApps.count)")
        }
    }
    
    /// 获取检测到的应用列表
    func getDetectedApps() -> [AppInfo] {
        return detectedApps
    }
    
    /// 检查特定应用是否已安装
    func isAppInstalled(appName: String) async -> Bool {
        let result = await UserSelectedAppDetectionService.checkAppInstalled(appName: appName)
        return result.installed
    }
    
    /// 打开指定应用
    func openApp(appName: String) async -> Bool {
        return await UserSelectedAppDetectionService.openApp(appName: appName)
    }
}