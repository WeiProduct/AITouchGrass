import DeviceActivity
import ManagedSettings
import Foundation

/// Device Activity Monitor Extension for AITouchGrass
/// This extension monitors app usage and enforces blocking rules
class DeviceActivityMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    // MARK: - Activity Started
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        print("📱 Monitor: Activity interval started for \(activity.rawValue)")
        
        // The blocking rules are already applied by the main app
        // This is called when the monitoring interval starts
    }
    
    // MARK: - Activity Ended
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        print("📱 Monitor: Activity interval ended for \(activity.rawValue)")
        
        // Clean up any temporary states if needed
    }
    
    // MARK: - Event Reached
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        print("📱 Monitor: Event threshold reached for \(event.rawValue)")
        
        // Handle when usage thresholds are reached
        // For example, you could send a notification or update blocking
    }
    
    // MARK: - Warning
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        print("📱 Monitor: Interval will start warning for \(activity.rawValue)")
        
        // Send a warning notification before blocking starts
        sendNotification(
            title: "App Blocking Starting Soon",
            body: "Your selected apps will be blocked in 5 minutes. Time to wrap up!"
        )
    }
    
    // MARK: - End Warning
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        print("📱 Monitor: Interval will end warning for \(activity.rawValue)")
        
        // Notify that blocking period is ending soon
        sendNotification(
            title: "App Blocking Ending Soon",
            body: "Your apps will be unblocked in 5 minutes."
        )
    }
    
    // MARK: - Helper Methods
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("📱 Monitor: Failed to send notification: \(error)")
            }
        }
    }
}

// MARK: - Extension Info
extension DeviceActivityMonitor {
    static let extensionBundleIdentifier = "com.aitouchgrass.AITouchGrassMonitor"
}