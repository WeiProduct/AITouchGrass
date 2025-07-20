//
//  StatisticsService.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import Combine

/// Service for calculating statistics
@MainActor
final class StatisticsService: ServiceProtocol {
    nonisolated static let identifier = "StatisticsService"
    
    // MARK: - Properties
    private let activityService: ActivityService
    
    // MARK: - Initialization
    init(activityService: ActivityService) {
        self.activityService = activityService
    }
    
    // MARK: - Public Methods
    func getWeeklyGoalProgress() async throws -> Double {
        let activities = try await activityService.fetchTodayActivityData()
        let totalMinutes = activities.map { $0.duration / 60 }.reduce(0, +)
        
        // Assuming 30 minutes daily goal
        return min(totalMinutes / 30, 1.0)
    }
    
    func getTotalOutdoorTime() async throws -> TimeInterval {
        let activities = try await activityService.fetchActivityData(
            from: Date.distantPast,
            to: Date()
        )
        return activities.reduce(0) { $0 + $1.duration }
    }
    
    func getTotalOutdoorTime(for date: Date = Date()) async throws -> TimeInterval {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let activities = try await activityService.fetchActivityData(
            from: startOfDay,
            to: endOfDay
        )
        
        return activities.map { $0.duration }.reduce(0, +)
    }
    
    func getTotalDistance() async throws -> Double {
        let activities = try await activityService.fetchActivityData(
            from: Date.distantPast,
            to: Date()
        )
        
        return activities.compactMap { $0.distance }.reduce(0, +)
    }
    
    func getCurrentStreak() async throws -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            let startOfDay = calendar.startOfDay(for: currentDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let activities = try await activityService.fetchActivities(
                from: startOfDay,
                to: endOfDay
            )
            
            if activities.isEmpty {
                // Skip today if checking current date
                if calendar.isDateInToday(currentDate) && streak == 0 {
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                    continue
                }
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
    
    func getDailyStats(from startDate: Date, to endDate: Date) async throws -> [DailyStat] {
        let activities = try await activityService.fetchActivityData(
            from: startDate,
            to: endDate
        )
        
        // Group activities by day
        let calendar = Calendar.current
        let groupedActivities = Dictionary(grouping: activities) { activity in
            calendar.startOfDay(for: activity.startDate)
        }
        
        // Create daily stats
        var dailyStats: [DailyStat] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayActivities = groupedActivities[dayStart] ?? []
            
            let stat = DailyStat(
                date: dayStart,
                activities: dayActivities.count,
                distance: dayActivities.compactMap { $0.distance }.reduce(0, +),
                duration: dayActivities.map { $0.duration }.reduce(0, +),
                calories: dayActivities.compactMap { $0.calories }.reduce(0, +)
            )
            
            dailyStats.append(stat)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dailyStats.sorted { $0.date < $1.date }
    }
    
    func getWeeklyProgress() async throws -> WeeklyProgress {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        
        var days: [DayProgress] = []
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: monday)!
            let dayName = calendar.weekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let activities = try await activityService.fetchActivityData(
                from: startOfDay,
                to: endOfDay
            )
            
            let totalMinutes = activities.map { $0.duration / 60 }.reduce(0, +)
            let goalProgress = min(totalMinutes / 30, 1.0) // 30 minutes daily goal
            
            let dayProgress = DayProgress(
                date: date,
                dayName: dayName,
                hasActivity: !activities.isEmpty,
                activities: activities.count,
                goalProgress: goalProgress
            )
            
            days.append(dayProgress)
        }
        
        return WeeklyProgress(days: days)
    }
}