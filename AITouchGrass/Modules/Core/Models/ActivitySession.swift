import Foundation
import SwiftData
import CoreLocation

@Model
final class ActivitySession {
    var id: UUID = UUID()
    var startTime: Date
    var endTime: Date?
    var coordinates: [LocationCoordinate] = []
    var heartRates: [HeartRateData] = []
    var currentSpeed: Double = 0
    var averageSpeed: Double = 0
    var maxSpeed: Double = 0
    var altitude: Double = 0
    var isActive: Bool = true
    
    @Relationship(inverse: \Activity.sessions)
    var activity: Activity?
    
    init(startTime: Date = Date()) {
        self.startTime = startTime
    }
}

struct LocationCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let altitude: Double?
    let speed: Double?
    
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timestamp = location.timestamp
        self.altitude = location.altitude
        self.speed = location.speed
    }
}

struct HeartRateData: Codable, Equatable {
    let timestamp: Date
    let heartRate: Int
}