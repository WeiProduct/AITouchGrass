//
//  DashboardData.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation

/// Dashboard data model
struct DashboardData {
    let todayActivities: Int
    let weeklyGoalProgress: Double
    let totalOutdoorTime: TimeInterval
    let currentStreak: Int
    let recentActivities: [Activity]
    let weatherCondition: WeatherCondition
    
    static var empty: DashboardData {
        DashboardData(
            todayActivities: 0,
            weeklyGoalProgress: 0.0,
            totalOutdoorTime: 0,
            currentStreak: 0,
            recentActivities: [],
            weatherCondition: .unknown
        )
    }
}

/// Weather condition
enum WeatherCondition {
    case sunny
    case cloudy
    case rainy
    case snowy
    case unknown
    
    var systemImage: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .snowy:
            return "cloud.snow.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    var recommendation: String {
        switch self {
        case .sunny:
            return "Perfect day for outdoor activities!"
        case .cloudy:
            return "Good conditions for a walk."
        case .rainy:
            return "Don't forget your umbrella!"
        case .snowy:
            return "Bundle up and enjoy the snow!"
        case .unknown:
            return "Check the weather before heading out."
        }
    }
}