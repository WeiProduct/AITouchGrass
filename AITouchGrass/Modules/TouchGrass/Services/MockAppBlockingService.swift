import Foundation
import Combine
import FamilyControls
import ManagedSettings

/// Mock implementation for development and testing when Family Controls is not available
@MainActor
final class MockAppBlockingService: ServiceProtocol, AppBlockingServiceProtocol {
    nonisolated static let identifier = "MockAppBlockingService"
    
    @Published var isBlocking = false
    @Published var isAuthorized = true // Always authorized in mock mode
    @Published var selection = FamilyActivitySelection()
    
    private var mockBlockedApps: [String] = []
    
    init() {
        print("🎭 MockAppBlockingService: Initialized in demo mode")
    }
    
    func configure() {
        print("🎭 MockAppBlockingService: Configure called - demo mode active")
        isAuthorized = true
    }
    
    func checkAuthorization() async {
        print("🎭 MockAppBlockingService: Checking authorization - always approved in demo mode")
        isAuthorized = true
    }
    
    private func requestAuthorization() async {
        print("🎭 MockAppBlockingService: Mock authorization granted")
        isAuthorized = true
    }
    
    func startBlocking() {
        print("🎭 MockAppBlockingService: Demo blocking started")
        print("🎭 Selected apps: \(selection.applicationTokens.count) applications")
        print("🎭 Selected categories: \(selection.categoryTokens.count) categories")
        
        isBlocking = true
        
        // Simulate blocking behavior
        mockBlockedApps = Array(0..<selection.applicationTokens.count).map { "MockApp\($0)" }
        
        // Show user notification about demo mode
        print("🎭 Demo Mode: Apps would be blocked now")
    }
    
    func stopBlocking() {
        print("🎭 MockAppBlockingService: Demo blocking stopped")
        isBlocking = false
        mockBlockedApps.removeAll()
        
        print("🎭 Demo Mode: Apps would be unblocked now")
    }
    
    func updateSelection(_ newSelection: FamilyActivitySelection) {
        print("🎭 MockAppBlockingService: Updated selection")
        print("🎭 Applications: \(newSelection.applicationTokens.count)")
        print("🎭 Categories: \(newSelection.categoryTokens.count)")
        
        selection = newSelection
        if isBlocking {
            startBlocking()
        }
    }
    
    // Additional demo functionality
    func getBlockedAppsCount() -> Int {
        return mockBlockedApps.count
    }
    
    func isAppBlocked(_ appName: String) -> Bool {
        return isBlocking && mockBlockedApps.contains(appName)
    }
    
    // MARK: - AppBlockingServiceProtocol Publishers
    var isBlockingPublisher: Published<Bool>.Publisher {
        return $isBlocking
    }
    
    var isAuthorizedPublisher: Published<Bool>.Publisher {
        return $isAuthorized
    }
}