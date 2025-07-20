import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ServiceProtocol {
    nonisolated static let identifier = "LocationService"
    private let locationManager: CLLocationManager
    private var cancellables = Set<AnyCancellable>()
    private var isConfigured = false
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isTracking = false
    @Published var locations: [CLLocation] = []
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        // Don't setup immediately to avoid initialization issues
    }
    
    func configure() {
        guard !isConfigured else { return }
        isConfigured = true
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10 // meters
        // Only enable background updates if the app has the proper background mode capability
        // locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestAuthorization() {
        configure() // Ensure configuration before use
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        configure() // Ensure configuration before use
        guard authorizationStatus == .authorizedWhenInUse || 
              authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        
        isTracking = true
        locations.removeAll()
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }
    
    func calculateDistance() -> Double {
        guard locations.count > 1 else { return 0 }
        
        var totalDistance: Double = 0
        for i in 1..<locations.count {
            totalDistance += locations[i].distance(from: locations[i-1])
        }
        
        return totalDistance
    }
    
    func calculateSpeed() -> Double {
        guard let location = currentLocation else { return 0 }
        return max(0, location.speed)
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            currentLocation = location
            
            if isTracking {
                self.locations.append(location)
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}