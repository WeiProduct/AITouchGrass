import Foundation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

// Use the ApplicationToken from ManagedSettings
typealias ApplicationToken = ManagedSettings.ApplicationToken

@MainActor
final class AppBlockingService: ServiceProtocol {
    nonisolated static let identifier = "AppBlockingService"
    
    @Published var isBlocking = true // 默认开启锁定
    @Published var blockedApps: Set<ApplicationToken> = []
    @Published var lastUnlockTime: Date?
    @Published var unlockDuration: TimeInterval = 3600 // 1 hour default
    @Published var isTemporarilyUnlocked = false
    @Published var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
    
    private var unlockTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let store = ManagedSettingsStore()
    private let deviceActivityCenter = DeviceActivityCenter()
    
    init() {
        // 启动时检查是否需要重新锁定
        checkAndRelock()
        checkAuthorizationStatus()
    }
    
    func configure() {
        Task {
            await requestFamilyControlsAuthorization()
        }
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }
    
    private func requestFamilyControlsAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        } catch {
            print("Failed to request Family Controls authorization: \(error)")
        }
    }
    
    private func checkAndRelock() {
        if let lastUnlock = lastUnlockTime {
            let elapsed = Date().timeIntervalSince(lastUnlock)
            if elapsed >= unlockDuration {
                // 解锁时间已过，重新锁定
                isTemporarilyUnlocked = false
                if !blockedApps.isEmpty {
                    startBlocking(apps: blockedApps)
                }
            } else {
                // 仍在解锁时间内
                isTemporarilyUnlocked = true
                let remaining = unlockDuration - elapsed
                startUnlockTimer(duration: remaining)
            }
        }
    }
    
    func startBlocking(apps: Set<ApplicationToken>) {
        guard authorizationStatus == .approved else {
            print("Family Controls not authorized")
            return
        }
        
        blockedApps = apps
        isBlocking = true
        
        // Convert ApplicationTokens to FamilyActivitySelection
        var selection = FamilyActivitySelection()
        for app in apps {
            selection.applicationTokens.insert(app)
        }
        
        // Apply restrictions using ManagedSettings
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        
        // Configure device activity schedule for monitoring
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        let activityName = DeviceActivityName("touchgrass.blocking")
        do {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule)
        } catch {
            print("Failed to start monitoring: \(error)")
        }
        
        print("Blocking \(apps.count) apps")
    }
    
    func stopBlocking() {
        guard authorizationStatus == .approved else { return }
        
        isBlocking = false
        
        // Clear all restrictions
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        
        // Stop monitoring
        let activityName = DeviceActivityName("touchgrass.blocking")
        deviceActivityCenter.stopMonitoring([activityName])
        
        print("Stopped blocking apps")
    }
    
    func unlockTemporarily(for duration: TimeInterval) {
        guard authorizationStatus == .approved else { return }
        
        lastUnlockTime = Date()
        unlockDuration = duration
        isTemporarilyUnlocked = true
        
        // Temporarily remove restrictions
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        
        print("Apps unlocked for \(duration) seconds")
        
        startUnlockTimer(duration: duration)
    }
    
    private func startUnlockTimer(duration: TimeInterval) {
        // Cancel existing timer
        unlockTimer?.invalidate()
        
        // Set new timer to re-enable blocking
        unlockTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.isTemporarilyUnlocked = false
                if !self.blockedApps.isEmpty {
                    self.startBlocking(apps: self.blockedApps)
                }
            }
        }
    }
    
    func isCurrentlyUnlocked() -> Bool {
        guard let lastUnlock = lastUnlockTime else { return false }
        return Date().timeIntervalSince(lastUnlock) < unlockDuration
    }
    
    func getRemainingUnlockTime() -> TimeInterval? {
        guard let lastUnlock = lastUnlockTime else { return nil }
        let elapsed = Date().timeIntervalSince(lastUnlock)
        let remaining = unlockDuration - elapsed
        return remaining > 0 ? remaining : nil
    }
    
    func addBlockedApp(_ app: ApplicationToken) {
        blockedApps.insert(app)
        if isBlocking {
            startBlocking(apps: blockedApps)
        }
    }
    
    func removeBlockedApp(_ app: ApplicationToken) {
        blockedApps.remove(app)
        if isBlocking {
            startBlocking(apps: blockedApps)
        }
    }
    
    func toggleAppBlocking(for app: ApplicationToken) {
        if blockedApps.contains(app) {
            removeBlockedApp(app)
        } else {
            addBlockedApp(app)
        }
    }
}

enum AppBlockingError: LocalizedError {
    case authorizationFailed
    case blockingFailed
    case invalidConfiguration
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed:
            return "屏幕时间授权失败"
        case .blockingFailed:
            return "应用锁定失败"
        case .invalidConfiguration:
            return "配置无效"
        }
    }
}