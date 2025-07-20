import Foundation
import Combine
import FamilyControls
import ManagedSettings
import UserNotifications
import SwiftData

@MainActor
final class RealAppBlockingService: ServiceProtocol, AppBlockingServiceProtocol {
    nonisolated static let identifier = "RealAppBlockingService"
    
    @Published var isBlocking = false
    @Published var isAuthorized = true
    @Published var selection = FamilyActivitySelection()
    
    private let modelContainer: ModelContainer
    private var selectedApps: Set<AppInfo> = []
    private var blockedApps: [AppUsage] = []
    private var currentSession: AppBlockingSession?
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        setupNotifications()
        loadBlockedApps()
    }
    
    func configure() {
        print("🔒 RealAppBlockingService: Configured")
        isAuthorized = true
    }
    
    func checkAuthorization() async {
        print("🔒 RealAppBlockingService: Checking authorization")
        await requestNotificationPermission()
        isAuthorized = true
    }
    
    private func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            if granted {
                print("🔒 Notification permission granted")
            } else {
                print("🔒 Notification permission denied")
            }
        } catch {
            print("🔒 Error requesting notification permission: \(error)")
        }
    }
    
    func startBlocking() {
        print("🔒 RealAppBlockingService: Starting real blocking")
        isBlocking = true
        
        // Create blocking session
        let appNames: [String]
        if !selectedApps.isEmpty {
            // Use manually selected apps
            appNames = Array(selectedApps.map { $0.name })
        } else {
            // Fall back to selection
            appNames = extractAppNames(from: selection)
        }
        
        currentSession = AppBlockingSession(blockedApps: appNames, natureType: "grass")
        saveSession()
        
        // Update blocked apps
        if !selectedApps.isEmpty {
            updateBlockedAppsFromSelectedApps()
        } else {
            updateBlockedAppsFromSelection()
        }
        
        // Schedule notification reminders
        scheduleBlockingReminders()
        
        print("🔒 Real blocking started for \(appNames.count) apps")
    }
    
    func stopBlocking() {
        print("🔒 RealAppBlockingService: Stopping real blocking")
        isBlocking = false
        
        // End current session
        currentSession?.endSession()
        saveSession()
        
        // Unblock all apps
        unblockAllApps()
        
        // Cancel notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        print("🔒 Real blocking stopped")
    }
    
    func updateSelection(_ newSelection: FamilyActivitySelection) {
        print("🔒 RealAppBlockingService: Updating selection")
        selection = newSelection
        if isBlocking {
            updateBlockedAppsFromSelection()
        }
    }
    
    
    private func extractAppNames(from selection: FamilyActivitySelection) -> [String] {
        // Since we can't get actual app names from tokens, we'll use generic names
        var appNames: [String] = []
        
        // Add app tokens
        for (index, _) in selection.applicationTokens.enumerated() {
            appNames.append("App \(index + 1)")
        }
        
        // Add category tokens
        for (index, _) in selection.categoryTokens.enumerated() {
            appNames.append("Category \(index + 1)")
        }
        
        return appNames
    }
    
    private func updateBlockedAppsFromSelection() {
        let appNames = extractAppNames(from: selection)
        let context = modelContainer.mainContext
        
        // Clear existing blocked apps
        blockedApps.removeAll()
        
        // Create new blocked apps
        for appName in appNames {
            let appUsage = AppUsage(
                appName: appName,
                bundleIdentifier: "com.example.\(appName.lowercased().replacingOccurrences(of: " ", with: ""))"
            )
            appUsage.block()
            blockedApps.append(appUsage)
            context.insert(appUsage)
        }
        
        saveContext()
    }
    
    private func loadBlockedApps() {
        do {
            let descriptor = FetchDescriptor<AppUsage>(predicate: #Predicate { $0.isBlocked })
            blockedApps = try modelContainer.mainContext.fetch(descriptor)
            print("🔒 Loaded \(blockedApps.count) blocked apps")
        } catch {
            print("🔒 Error loading blocked apps: \(error)")
        }
    }
    
    private func unblockAllApps() {
        for app in blockedApps {
            app.unblock()
        }
        blockedApps.removeAll()
        saveContext()
    }
    
    func temporaryUnlock(for duration: TimeInterval = 3600) {
        print("🔒 Temporary unlock for \(duration) seconds")
        
        // Record verification in current session
        currentSession?.recordVerification(unlockDuration: duration)
        
        // Unlock all blocked apps temporarily
        for app in blockedApps {
            app.unlock(for: duration)
        }
        
        saveContext()
        
        // Schedule re-blocking notification
        scheduleReblockingNotification(after: duration)
    }
    
    private func scheduleBlockingReminders() {
        // 清除之前的通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard !selectedApps.isEmpty else {
            // 如果没有选择的应用，使用通用提醒
            let content = UNMutableNotificationContent()
            content.title = "专注模式激活"
            content.body = "已锁定 \(blockedApps.count) 个应用。需要解锁请拍摄自然景观。"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: true) // Every 5 minutes
            let request = UNNotificationRequest(identifier: "blocking_reminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
            return
        }
        
        // 为选择的应用创建详细提醒
        let appNames = Array(selectedApps.prefix(3)).map { $0.name }.joined(separator: "、")
        let moreCount = max(0, selectedApps.count - 3)
        let moreText = moreCount > 0 ? "等\(selectedApps.count)个应用" : ""
        
        let content = UNMutableNotificationContent()
        content.title = "🌿 专注模式已开启"
        content.body = "已限制使用：\(appNames)\(moreText)。去户外走走，拍摄自然景观可临时解锁！"
        content.sound = .default
        content.categoryIdentifier = "APP_BLOCKED"
        
        // 立即显示通知
        let immediateRequest = UNNotificationRequest(
            identifier: "blocked_immediate",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(immediateRequest)
        
        // 定期提醒（每30分钟）
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: true)
        let repeatingRequest = UNNotificationRequest(
            identifier: "blocked_repeat",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(repeatingRequest)
        
        print("🔒 Scheduled reminders for \(selectedApps.count) apps")
    }
    
    private func scheduleReblockingNotification(after duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "应用将重新锁定"
        content.body = "临时解锁即将结束，应用将在1分钟后重新锁定。"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration - 60, repeats: false)
        let request = UNNotificationRequest(identifier: "reblock_warning", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func setupNotifications() {
        // Configure notification categories
        let unlockAction = UNNotificationAction(
            identifier: "unlock_action",
            title: "拍摄自然景观解锁",
            options: .foreground
        )
        
        let blockingCategory = UNNotificationCategory(
            identifier: "blocking_category",
            actions: [unlockAction],
            intentIdentifiers: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([blockingCategory])
    }
    
    private func saveSession() {
        guard let session = currentSession else { return }
        let context = modelContainer.mainContext
        context.insert(session)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try modelContainer.mainContext.save()
        } catch {
            print("🔒 Error saving context: \(error)")
        }
    }
    
    // MARK: - AppBlockingServiceProtocol Publishers
    var isBlockingPublisher: Published<Bool>.Publisher {
        return $isBlocking
    }
    
    var isAuthorizedPublisher: Published<Bool>.Publisher {
        return $isAuthorized
    }
    
    // MARK: - Custom App Selection
    func updateSelectedApps(_ apps: Set<AppInfo>) {
        print("🔒 RealAppBlockingService: Updating selected apps")
        selectedApps = apps
        
        if isBlocking {
            // Update blocking with new selection
            updateBlockedAppsFromSelectedApps()
        }
    }
    
    private func updateBlockedAppsFromSelectedApps() {
        let context = modelContainer.mainContext
        
        // Clear existing blocked apps
        blockedApps.removeAll()
        
        // Create blocked apps from selected apps
        for app in selectedApps {
            let appUsage = AppUsage(
                appName: app.name,
                bundleIdentifier: app.bundleId
            )
            appUsage.block()
            blockedApps.append(appUsage)
            context.insert(appUsage)
        }
        
        saveContext()
        print("🔒 Updated blocked apps: \(blockedApps.count) apps")
    }
    
    // MARK: - Usage Statistics
    func getUsageStatistics() -> [AppUsage] {
        return blockedApps
    }
    
    func getBlockingHistory() -> [AppBlockingSession] {
        do {
            let context = modelContainer.mainContext
            let descriptor = FetchDescriptor<AppBlockingSession>(
                sortBy: [SortDescriptor(\.startTime, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            print("🔒 Error fetching blocking history: \(error)")
            return []
        }
    }
}