import Foundation
import Combine
import FamilyControls
import ManagedSettings

@MainActor
final class SimpleAppBlockingService: ServiceProtocol, AppBlockingServiceProtocol {
    nonisolated static let identifier = "AppBlockingService"
    
    @Published var isBlocking = false
    @Published var isAuthorized = false
    @Published var selection = FamilyActivitySelection()
    
    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared
    
    init() {
        Task {
            await checkAuthorization()
        }
    }
    
    func configure() {
        Task {
            await requestAuthorization()
        }
    }
    
    func checkAuthorization() async {
        do {
            switch center.authorizationStatus {
            case .approved:
                isAuthorized = true
                print("DEBUG: Family Controls authorization approved")
            case .denied:
                isAuthorized = false
                print("DEBUG: Family Controls authorization denied")
            case .notDetermined:
                isAuthorized = false
                print("DEBUG: Family Controls authorization not determined")
            @unknown default:
                isAuthorized = false
                print("DEBUG: Family Controls authorization unknown status")
            }
        } catch {
            print("DEBUG: Error checking authorization: \(error)")
            isAuthorized = false
        }
    }
    
    private func requestAuthorization() async {
        do {
            print("DEBUG: Requesting Family Controls authorization...")
            try await center.requestAuthorization(for: .individual)
            await checkAuthorization()
            print("DEBUG: Authorization request completed")
        } catch {
            print("DEBUG: Authorization failed with error: \(error)")
            print("DEBUG: Error domain: \(error._domain)")
            print("DEBUG: Error code: \(error._code)")
            isAuthorized = false
        }
    }
    
    func startBlocking() {
        guard isAuthorized else { 
            print("Not authorized to block apps")
            return 
        }
        
        isBlocking = true
        
        // Apply the shield configuration
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
    }
    
    func stopBlocking() {
        isBlocking = false
        
        // Clear all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
    
    func updateSelection(_ newSelection: FamilyActivitySelection) {
        selection = newSelection
        if isBlocking {
            startBlocking()
        }
    }
    
    // MARK: - AppBlockingServiceProtocol Publishers
    var isBlockingPublisher: Published<Bool>.Publisher {
        return $isBlocking
    }
    
    var isAuthorizedPublisher: Published<Bool>.Publisher {
        return $isAuthorized
    }
}