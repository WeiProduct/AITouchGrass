import Foundation

struct DailyStat {
    let date: Date
    let activities: Int
    let distance: Double
    let duration: TimeInterval
    let calories: Double
}

struct DayProgress: Identifiable {
    let id = UUID()
    let date: Date
    let dayName: String
    let hasActivity: Bool
    let activities: Int
    let goalProgress: Double
}

struct WeeklyProgress {
    let days: [DayProgress]
    
    var totalActivities: Int {
        days.reduce(0) { $0 + $1.activities }
    }
    
    var averageGoalProgress: Double {
        guard !days.isEmpty else { return 0 }
        let total = days.reduce(0.0) { $0 + $1.goalProgress }
        return total / Double(days.count)
    }
    
    var activeDays: Int {
        days.filter { $0.hasActivity }.count
    }
    
    var completionPercentage: Double {
        averageGoalProgress * 100
    }
}

enum TimePeriod {
    case today
    case week
    case month
    case year
}