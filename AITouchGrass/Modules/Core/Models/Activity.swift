import Foundation
import SwiftData
import CoreLocation

@Model
final class Activity {
    var id: UUID = UUID()
    var name: String
    var type: ActivityType
    var startDate: Date
    var endDate: Date?
    var duration: TimeInterval
    var distance: Double?
    var calories: Double?
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var notes: String?
    var weatherCondition: String?
    var temperature: Double?
    
    @Relationship(deleteRule: .cascade)
    var sessions: [ActivitySession] = []
    
    var date: Date { startDate }
    
    init(
        name: String,
        type: ActivityType,
        startDate: Date = Date(),
        duration: TimeInterval = 0,
        distance: Double? = nil,
        calories: Double? = nil
    ) {
        self.name = name
        self.type = type
        self.startDate = startDate
        self.duration = duration
        self.distance = distance
        self.calories = calories
    }
}

enum ActivityType: String, CaseIterable, Codable {
    case walking = "walking"
    case running = "running"
    case cycling = "cycling"
    case hiking = "hiking"
    case swimming = "swimming"
    case yoga = "yoga"
    case workout = "workout"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .walking: return "步行"
        case .running: return "跑步"
        case .cycling: return "骑行"
        case .hiking: return "徒步"
        case .swimming: return "游泳"
        case .yoga: return "瑜伽"
        case .workout: return "健身"
        case .other: return "其他"
        }
    }
    
    var systemImage: String {
        switch self {
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .hiking: return "figure.hiking"
        case .swimming: return "figure.pool.swim"
        case .yoga: return "figure.yoga"
        case .workout: return "dumbbell.fill"
        case .other: return "sportscourt.fill"
        }
    }
    
    var color: String {
        switch self {
        case .walking: return "blue"
        case .running: return "orange"
        case .cycling: return "GreenColor"
        case .hiking: return "brown"
        case .swimming: return "CyanColor"
        case .yoga: return "purple"
        case .workout: return "red"
        case .other: return "gray"
        }
    }
    
    var defaultCaloriesPerMinute: Double {
        switch self {
        case .walking: return 4.0
        case .running: return 10.0
        case .cycling: return 8.0
        case .hiking: return 6.0
        case .swimming: return 11.0
        case .yoga: return 3.0
        case .workout: return 8.0
        case .other: return 5.0
        }
    }
}

// MARK: - Sendable Activity Data
struct ActivityData: Sendable {
    let id: UUID
    let name: String
    let type: ActivityType
    let startDate: Date
    let endDate: Date?
    let duration: TimeInterval
    let distance: Double?
    let calories: Double?
    
    init(from activity: Activity) {
        self.id = activity.id
        self.name = activity.name
        self.type = activity.type
        self.startDate = activity.startDate
        self.endDate = activity.endDate
        self.duration = activity.duration
        self.distance = activity.distance
        self.calories = activity.calories
    }
}