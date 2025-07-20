import Foundation
import SwiftData
import Combine

@MainActor
final class ActivityService: ServiceProtocol {
    nonisolated static let identifier = "ActivityService"
    private let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    @Published var currentActivity: Activity?
    @Published var recentActivities: [Activity] = []
    
    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        initializeMockDataIfNeeded()
        fetchRecentActivities()
    }
    
    func startActivity(name: String, type: ActivityType) -> Activity {
        let activity = Activity(name: name, type: type)
        modelContext.insert(activity)
        currentActivity = activity
        save()
        return activity
    }
    
    func endActivity(_ activity: Activity) {
        activity.endDate = Date()
        activity.duration = activity.endDate!.timeIntervalSince(activity.startDate)
        currentActivity = nil
        save()
    }
    
    func updateActivity(_ activity: Activity, distance: Double? = nil, calories: Double? = nil) {
        if let distance = distance {
            activity.distance = distance
        }
        if let calories = calories {
            activity.calories = calories
        }
        save()
    }
    
    func fetchRecentActivities() {
        let descriptor = FetchDescriptor<Activity>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        do {
            recentActivities = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch activities: \(error)")
            recentActivities = []
        }
    }
    
    @MainActor
    func fetchTodayActivities() async throws -> [Activity] {
        return fetchActivities(for: Date())
    }
    
    @MainActor
    func fetchTodayActivityData() async throws -> [ActivityData] {
        let activities = fetchActivities(for: Date())
        return activities.map { ActivityData(from: $0) }
    }
    
    func fetchRecentActivities(limit: Int) async throws -> [Activity] {
        let descriptor = FetchDescriptor<Activity>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        var fetchDescriptor = descriptor
        fetchDescriptor.fetchLimit = limit
        
        return try modelContext.fetch(fetchDescriptor)
    }
    
    func fetchActivities(for date: Date) -> [Activity] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Activity> { activity in
            activity.startDate >= startOfDay && activity.startDate < endOfDay
        }
        
        let descriptor = FetchDescriptor<Activity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startDate)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch activities for date: \(error)")
            return []
        }
    }
    
    func deleteActivity(_ activity: Activity) {
        modelContext.delete(activity)
        save()
        fetchRecentActivities()
    }
    
    @MainActor
    func fetchActivities(from startDate: Date, to endDate: Date, type: ActivityType? = nil) async throws -> [Activity] {
        let predicate: Predicate<Activity>
        
        if let type = type {
            predicate = #Predicate<Activity> { activity in
                activity.startDate >= startDate && activity.startDate < endDate && activity.type == type
            }
        } else {
            predicate = #Predicate<Activity> { activity in
                activity.startDate >= startDate && activity.startDate < endDate
            }
        }
        
        let descriptor = FetchDescriptor<Activity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startDate)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    @MainActor
    func fetchActivityData(from startDate: Date, to endDate: Date, type: ActivityType? = nil) async throws -> [ActivityData] {
        let activities = try await fetchActivities(from: startDate, to: endDate, type: type)
        return activities.map { ActivityData(from: $0) }
    }
    
    func getTotalActivitiesCount() async throws -> Int {
        let descriptor = FetchDescriptor<Activity>()
        return try modelContext.fetchCount(descriptor)
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func initializeMockDataIfNeeded() {
        // Check if we already have activities
        let descriptor = FetchDescriptor<Activity>()
        if let count = try? modelContext.fetchCount(descriptor), count > 0 {
            return
        }
        
        // Create mock activities for the past week
        
        let mockActivities = [
            // Today
            createMockActivity(name: "晨跑", type: .running, daysAgo: 0, duration: 1800, distance: 5200, calories: 380),
            createMockActivity(name: "午后散步", type: .walking, daysAgo: 0, duration: 900, distance: 1200, calories: 85),
            
            // Yesterday
            createMockActivity(name: "晚间骑行", type: .cycling, daysAgo: 1, duration: 2700, distance: 12500, calories: 420),
            createMockActivity(name: "徒步公园", type: .hiking, daysAgo: 1, duration: 3600, distance: 7800, calories: 520),
            
            // 2 days ago
            createMockActivity(name: "晨跑", type: .running, daysAgo: 2, duration: 2100, distance: 6300, calories: 450),
            
            // 3 days ago
            createMockActivity(name: "游泳训练", type: .swimming, daysAgo: 3, duration: 2400, distance: 1500, calories: 380),
            createMockActivity(name: "午后慢跑", type: .running, daysAgo: 3, duration: 1500, distance: 4200, calories: 310),
            
            // 4 days ago
            createMockActivity(name: "山地骑行", type: .cycling, daysAgo: 4, duration: 5400, distance: 25000, calories: 850),
            
            // 5 days ago
            createMockActivity(name: "健步走", type: .walking, daysAgo: 5, duration: 2700, distance: 4500, calories: 280),
            createMockActivity(name: "瑜伽跑步", type: .running, daysAgo: 5, duration: 1200, distance: 3500, calories: 250),
            
            // 6 days ago
            createMockActivity(name: "长跑训练", type: .running, daysAgo: 6, duration: 4200, distance: 12000, calories: 820)
        ]
        
        mockActivities.forEach { activity in
            modelContext.insert(activity)
        }
        
        save()
    }
    
    private func createMockActivity(name: String, type: ActivityType, daysAgo: Int, duration: TimeInterval, distance: Double, calories: Double) -> Activity {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        let randomHour = Int.random(in: 6...20)
        let activityStartDate = calendar.date(bySettingHour: randomHour, minute: Int.random(in: 0...59), second: 0, of: startDate)!
        
        let activity = Activity(name: name, type: type)
        activity.startDate = activityStartDate
        activity.endDate = activityStartDate.addingTimeInterval(duration)
        activity.duration = duration
        activity.distance = distance
        activity.calories = calories
        activity.averageHeartRate = Int.random(in: 110...160)
        activity.notes = generateMockNotes(for: type)
        
        return activity
    }
    
    private func generateMockNotes(for type: ActivityType) -> String {
        let notes = [
            ActivityType.running: ["感觉状态很好，节奏稳定", "今天天气不错，适合跑步", "达到了目标配速", "需要注意膝盖保护"],
            ActivityType.cycling: ["新路线风景很美", "顺风骑行速度很快", "山地路段有挑战", "车况良好"],
            ActivityType.walking: ["放松心情的好方式", "和朋友一起散步聊天", "呼吸新鲜空气", "步行冥想"],
            ActivityType.hiking: ["山景壮观", "全程无休息完成", "带足了水和补给", "下次要带登山杖"],
            ActivityType.swimming: ["水温适中", "换气节奏有进步", "耐力提升明显", "泳姿需要改进"]
        ]
        
        return notes[type]?.randomElement() ?? "今天运动感觉不错！"
    }
}