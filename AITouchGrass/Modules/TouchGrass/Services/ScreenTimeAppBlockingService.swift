import Foundation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftData
import UserNotifications

/// A comprehensive app blocking service that properly uses Screen Time API
@MainActor
final class ScreenTimeAppBlockingService: ServiceProtocol, AppBlockingServiceProtocol {
    nonisolated static let identifier = "ScreenTimeAppBlockingService"
    
    // MARK: - Published Properties
    @Published var isBlocking = false
    @Published var isAuthorized = false
    @Published var selection = FamilyActivitySelection()
    @Published var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
    
    // MARK: - Private Properties
    private let store = ManagedSettingsStore()
    private let deviceActivityCenter = DeviceActivityCenter()
    private let modelContainer: ModelContainer
    private var selectedApps: Set<AppInfo> = []
    private var currentSession: AppBlockingSession?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    private let activityName = DeviceActivityName("com.aitouchgrass.blocking")
    
    // MARK: - Initialization
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        checkAuthorizationStatus()
        setupNotifications()
    }
    
    // MARK: - ServiceProtocol
    func configure() {
        Task {
            await checkAuthorization()
        }
    }
    
    // MARK: - Authorization
    func checkAuthorization() async {
        print("📱 ScreenTimeAppBlockingService: Checking authorization")
        
        // Check current authorization status
        checkAuthorizationStatus()
        
        // Request authorization if needed
        if authorizationStatus == .notDetermined {
            await requestAuthorization()
        }
        
        isAuthorized = authorizationStatus == .approved
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        isAuthorized = authorizationStatus == .approved
    }
    
    private func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            checkAuthorizationStatus()
            print("📱 Screen Time authorization granted")
        } catch {
            print("📱 Failed to request Screen Time authorization: \(error)")
            isAuthorized = false
        }
    }
    
    // MARK: - App Blocking
    func startBlocking() {
        guard isAuthorized else {
            print("📱 Cannot start blocking: Not authorized")
            return
        }
        
        print("📱 ScreenTimeAppBlockingService: Starting blocking")
        isBlocking = true
        
        // Create blocking session
        let appNames = extractAppNames()
        currentSession = AppBlockingSession(blockedApps: appNames, natureType: "grass")
        saveSession()
        
        // Apply restrictions
        applyRestrictions()
        
        // Start monitoring device activity
        startDeviceActivityMonitoring()
        
        // Schedule notifications
        scheduleBlockingNotifications()
        
        print("📱 Blocking started for \(appNames.count) apps")
    }
    
    func stopBlocking() {
        print("📱 ScreenTimeAppBlockingService: Stopping blocking")
        isBlocking = false
        
        // End current session
        currentSession?.endSession()
        saveSession()
        
        // Clear all restrictions
        clearRestrictions()
        
        // Stop monitoring
        stopDeviceActivityMonitoring()
        
        // Cancel notifications
        cancelBlockingNotifications()
        
        print("📱 Blocking stopped")
    }
    
    // MARK: - Selection Management
    func updateSelection(_ newSelection: FamilyActivitySelection) {
        print("📱 ScreenTimeAppBlockingService: Updating selection")
        selection = newSelection
        
        if isBlocking {
            applyRestrictions()
        }
    }
    
    func updateSelectedApps(_ apps: Set<AppInfo>) {
        print("📱 ScreenTimeAppBlockingService: Updating selected apps")
        selectedApps = apps
        
        // Convert AppInfo to FamilyActivitySelection
        // Note: In a real implementation, you would need to map AppInfo to ApplicationTokens
        // This requires using FamilyActivityPicker to get the actual tokens
        // For now, we'll keep the existing selection and merge with manual selections
        
        if isBlocking {
            applyRestrictions()
        }
    }
    
    // MARK: - Temporary Unlock
    func temporaryUnlock(for duration: TimeInterval = 3600) {
        guard isAuthorized else { return }
        
        print("📱 Temporary unlock for \(duration) seconds")
        
        // Record verification in current session
        currentSession?.recordVerification(unlockDuration: duration)
        saveSession()
        
        // Temporarily clear restrictions
        clearRestrictions()
        
        // Schedule re-blocking
        scheduleReblocking(after: duration)
    }
    
    // MARK: - Private Methods
    private func applyRestrictions() {
        guard isAuthorized else { return }
        
        // Shield selected applications
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        
        // Configure additional restrictions
        configureAdditionalRestrictions()
        
        print("📱 Applied restrictions to \(selection.applicationTokens.count) apps and \(selection.categoryTokens.count) categories")
    }
    
    private func clearRestrictions() {
        guard isAuthorized else { return }
        
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        print("📱 Cleared all restrictions")
    }
    
    private func configureAdditionalRestrictions() {
        // Configure shield configuration
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        
        // You can customize the shield appearance
        // Note: This requires creating a Shield Configuration Extension
        // store.shield.applicationCategories?.shieldConfiguration = ShieldConfiguration(
        //     backgroundBlurStyle: .systemThickMaterial,
        //     backgroundColor: .systemRed,
        //     icon: nil,
        //     title: ShieldConfiguration.Label(text: "Blocked by AITouchGrass", color: .white),
        //     subtitle: ShieldConfiguration.Label(text: "Go touch grass to unlock!", color: .white),
        //     primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
        //     primaryButtonBackgroundColor: .systemBlue,
        //     secondaryButtonLabel: nil
        // )
    }
    
    private func startDeviceActivityMonitoring() {
        // Create a schedule for 24/7 monitoring
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule)
            print("📱 Started device activity monitoring")
        } catch {
            print("📱 Failed to start device activity monitoring: \(error)")
        }
    }
    
    private func stopDeviceActivityMonitoring() {
        deviceActivityCenter.stopMonitoring([activityName])
        print("📱 Stopped device activity monitoring")
    }
    
    private func extractAppNames() -> [String] {
        var appNames: [String] = []
        
        // Add manually selected apps
        appNames.append(contentsOf: selectedApps.map { $0.name })
        
        // Add apps from FamilyActivitySelection
        // Note: We can't get actual app names from tokens, so we use generic names
        for (index, _) in selection.applicationTokens.enumerated() {
            if !appNames.contains("App \(index + 1)") {
                appNames.append("App \(index + 1)")
            }
        }
        
        for (index, _) in selection.categoryTokens.enumerated() {
            appNames.append("Category \(index + 1)")
        }
        
        return appNames
    }
    
    private func scheduleReblocking(after duration: TimeInterval) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                if !isBlocking {
                    // Re-apply restrictions
                    applyRestrictions()
                    isBlocking = true
                }
            }
        }
    }
    
    // MARK: - Notifications
    private func setupNotifications() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                    options: [UNAuthorizationOptions.alert, .sound, .badge]
                )
                print("📱 Notification permission: \(granted ? "granted" : "denied")")
            } catch {
                print("📱 Error requesting notification permission: \(error)")
            }
        }
    }
    
    private func scheduleBlockingNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Apps Blocked"
        content.body = "Selected apps are now blocked. Go outside and touch grass to unlock!"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "app_blocking_started",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelBlockingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Data Persistence
    private func saveSession() {
        guard let session = currentSession else { return }
        let context = modelContainer.mainContext
        context.insert(session)
        
        do {
            try context.save()
        } catch {
            print("📱 Error saving session: \(error)")
        }
    }
    
    // MARK: - AppBlockingServiceProtocol Publishers
    var isBlockingPublisher: Published<Bool>.Publisher {
        $isBlocking
    }
    
    var isAuthorizedPublisher: Published<Bool>.Publisher {
        $isAuthorized
    }
    
    // MARK: - Statistics
    func getUsageStatistics() -> [AppUsage] {
        // This would integrate with DeviceActivity reporting
        // For now, return empty array
        return []
    }
    
    func getBlockingHistory() -> [AppBlockingSession] {
        do {
            let context = modelContainer.mainContext
            let descriptor = FetchDescriptor<AppBlockingSession>(
                sortBy: [SortDescriptor(\.startTime, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            print("📱 Error fetching blocking history: \(error)")
            return []
        }
    }
}