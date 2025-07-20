import Foundation
import Combine
import FamilyControls

/// Protocol defining the interface for app blocking services
@MainActor
protocol AppBlockingServiceProtocol: AnyObject {
    var isBlocking: Bool { get }
    var isAuthorized: Bool { get }
    var selection: FamilyActivitySelection { get set }
    
    var isBlockingPublisher: Published<Bool>.Publisher { get }
    var isAuthorizedPublisher: Published<Bool>.Publisher { get }
    
    func configure()
    func checkAuthorization() async
    func startBlocking()
    func stopBlocking()
    func updateSelection(_ newSelection: FamilyActivitySelection)
}

// MARK: - Published Property Accessors
extension AppBlockingServiceProtocol {
    var isBlockingPublisher: Published<Bool>.Publisher {
        // This will be implemented by conforming types using their @Published properties
        fatalError("Must be implemented by conforming type")
    }
    
    var isAuthorizedPublisher: Published<Bool>.Publisher {
        // This will be implemented by conforming types using their @Published properties
        fatalError("Must be implemented by conforming type")
    }
}