import Foundation
import SwiftData

@Model
final class User {
    var id: UUID = UUID()
    var name: String
    var email: String?
    var avatarURL: String?
    var birthDate: Date?
    var height: Double? // cm
    var weight: Double? // kg
    var gender: Gender?
    var dailyGoal: Int = 10000 // steps
    var weeklyGoal: Int = 150 // minutes
    var preferredActivityTypes: [String] = []
    var joinDate: Date = Date()
    var totalActivities: Int = 0
    var totalDistance: Double = 0
    var totalCalories: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var achievements: [String] = []
    var avatarData: Data?
    var dateJoined: Date = Date()
    
    init(name: String, email: String? = nil) {
        self.name = name
        self.email = email
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male: return "男"
        case .female: return "女"
        case .other: return "其他"
        }
    }
}