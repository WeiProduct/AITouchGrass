//
//  StatisticsViewModel.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import Combine
import SwiftUI

/// Statistics view model
@MainActor
final class StatisticsViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var statisticsData = StatisticsData.empty
    @Published var selectedTimeRange: TimeRange = .week
    @Published var selectedActivityType: ActivityType?
    @Published var chartType: ChartType = .distance
    
    // MARK: - Services
    private let statisticsService: StatisticsService
    private let activityService: ActivityService
    
    // MARK: - Coordinator
    weak var coordinator: StatisticsCoordinator?
    
    // MARK: - Input/Output
    struct Input {
        let loadStatistics: AnyPublisher<Void, Never>
        let changeTimeRange: AnyPublisher<TimeRange, Never>
        let changeChartType: AnyPublisher<ChartType, Never>
        let filterByActivity: AnyPublisher<ActivityType?, Never>
        let exportData: AnyPublisher<Void, Never>
        let shareStats: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let statisticsData: AnyPublisher<StatisticsData, Never>
        let chartData: AnyPublisher<ChartData, Never>
        let isLoading: AnyPublisher<Bool, Never>
    }
    
    // MARK: - Initialization
    init(serviceContainer: ServiceContainer) {
        self.statisticsService = serviceContainer.statisticsService
        self.activityService = serviceContainer.activityService
        super.init()
    }
    
    // MARK: - Setup
    override func setupBindings() {
        // Load initial statistics
        Task {
            await loadStatistics()
        }
        
        // React to time range changes
        $selectedTimeRange
            .dropFirst()
            .sink { [weak self] _ in
                Task {
                    await self?.loadStatistics()
                }
            }
            .store(in: &cancellables)
        
        // React to activity type filter
        $selectedActivityType
            .dropFirst()
            .sink { [weak self] _ in
                Task {
                    await self?.loadStatistics()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        // Load statistics
        input.loadStatistics
            .sink { [weak self] _ in
                Task {
                    await self?.loadStatistics()
                }
            }
            .store(in: &cancellables)
        
        // Change time range
        input.changeTimeRange
            .sink { [weak self] range in
                self?.selectedTimeRange = range
            }
            .store(in: &cancellables)
        
        // Change chart type
        input.changeChartType
            .sink { [weak self] type in
                self?.chartType = type
            }
            .store(in: &cancellables)
        
        // Filter by activity
        input.filterByActivity
            .sink { [weak self] type in
                self?.selectedActivityType = type
            }
            .store(in: &cancellables)
        
        // Export data
        input.exportData
            .sink { [weak self] _ in
                self?.coordinator?.exportStatistics()
            }
            .store(in: &cancellables)
        
        // Share stats
        input.shareStats
            .sink { [weak self] _ in
                self?.coordinator?.shareStatistics()
            }
            .store(in: &cancellables)
        
        // Create chart data publisher
        let chartDataPublisher = Publishers.CombineLatest3(
            $statisticsData,
            $chartType,
            $selectedActivityType
        )
        .map { data, type, activityFilter in
            ChartData(
                type: type,
                data: data,
                activityFilter: activityFilter
            )
        }
        .eraseToAnyPublisher()
        
        return Output(
            statisticsData: $statisticsData.eraseToAnyPublisher(),
            chartData: chartDataPublisher,
            isLoading: $isLoading.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Private Methods
    private func loadStatistics() async {
        showLoading()
        
        do {
            let endDate = Date()
            let startDate = getStartDate(for: selectedTimeRange)
            
            // Fetch data in parallel
            let activities = try await activityService.fetchActivityData(
                from: startDate,
                to: endDate,
                type: selectedActivityType
            )
            
            async let dailyStats = statisticsService.getDailyStats(
                from: startDate,
                to: endDate
            )
            
            async let weeklyProgress = statisticsService.getWeeklyProgress()
            
            let fetchedDailyStats = try await dailyStats
            let fetchedWeeklyProgress = try await weeklyProgress
            
            // Calculate statistics
            let statistics = calculateStatistics(
                activities: activities,
                dailyStats: fetchedDailyStats,
                weeklyProgress: fetchedWeeklyProgress
            )
            
            await MainActor.run {
                self.statisticsData = statistics
                self.hideLoading()
            }
        } catch {
            await MainActor.run {
                self.handleError(error)
            }
        }
    }
    
    private func getStartDate(for range: TimeRange) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch range {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .all:
            return Date.distantPast
        }
    }
    
    private func calculateStatistics(
        activities: [ActivityData],
        dailyStats: [DailyStat],
        weeklyProgress: WeeklyProgress
    ) -> StatisticsData {
        let totalActivities = activities.count
        let totalDistance = activities.compactMap { $0.distance }.reduce(0, +)
        let totalDuration = activities.map { $0.duration }.reduce(0, +)
        let totalCalories = activities.compactMap { $0.calories }.reduce(0, +)
        
        let averageDistance = totalActivities > 0 ? totalDistance / Double(totalActivities) : 0
        let averageDuration = totalActivities > 0 ? totalDuration / Double(totalActivities) : 0
        
        // Group activities by type
        let activitiesByType = Dictionary(grouping: activities) { $0.type }
            .mapValues { $0.count }
        
        return StatisticsData(
            timeRange: selectedTimeRange,
            totalActivities: totalActivities,
            totalDistance: totalDistance,
            totalDuration: totalDuration,
            totalCalories: totalCalories,
            averageDistance: averageDistance,
            averageDuration: averageDuration,
            activitiesByType: activitiesByType,
            dailyStats: dailyStats,
            weeklyProgress: weeklyProgress
        )
    }
}

// MARK: - Chart Type
enum ChartType: String, CaseIterable {
    case distance = "Distance"
    case duration = "Duration"
    case calories = "Calories"
    case activities = "Activities"
}

// MARK: - Chart Data
struct ChartData {
    let type: ChartType
    let data: StatisticsData
    let activityFilter: ActivityType?
    
    var chartPoints: [ChartPoint] {
        switch type {
        case .distance:
            return data.dailyStats.map {
                ChartPoint(
                    date: $0.date,
                    value: $0.distance / 1000, // Convert to km
                    label: String(format: "%.1f km", $0.distance / 1000)
                )
            }
        case .duration:
            return data.dailyStats.map {
                ChartPoint(
                    date: $0.date,
                    value: $0.duration / 60, // Convert to minutes
                    label: String(format: "%.0f min", $0.duration / 60)
                )
            }
        case .calories:
            return data.dailyStats.map {
                ChartPoint(
                    date: $0.date,
                    value: $0.calories,
                    label: String(format: "%.0f cal", $0.calories)
                )
            }
        case .activities:
            return data.dailyStats.map {
                ChartPoint(
                    date: $0.date,
                    value: Double($0.activities),
                    label: "\($0.activities)"
                )
            }
        }
    }
}

// MARK: - Chart Point
struct ChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
}