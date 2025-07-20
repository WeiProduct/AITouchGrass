//
//  StatisticsData.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All"
}

/// Statistics data model
struct StatisticsData {
    let timeRange: TimeRange
    let totalActivities: Int
    let totalDistance: Double // in meters
    let totalDuration: TimeInterval
    let totalCalories: Double
    let averageDistance: Double
    let averageDuration: TimeInterval
    let activitiesByType: [ActivityType: Int]
    let dailyStats: [DailyStat]
    let weeklyProgress: WeeklyProgress
    
    static var empty: StatisticsData {
        StatisticsData(
            timeRange: .week,
            totalActivities: 0,
            totalDistance: 0,
            totalDuration: 0,
            totalCalories: 0,
            averageDistance: 0,
            averageDuration: 0,
            activitiesByType: [:],
            dailyStats: [],
            weeklyProgress: WeeklyProgress(days: [])
        )
    }
}

