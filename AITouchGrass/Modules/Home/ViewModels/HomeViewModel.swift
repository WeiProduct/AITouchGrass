//
//  HomeViewModel.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import Combine
import SwiftUI

/// Home view model
final class HomeViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var dashboardData = DashboardData.empty
    @Published var isRefreshing = false
    @Published var quickActionSheet: QuickAction?
    
    // MARK: - Services
    private let activityService: ActivityService
    private let statisticsService: StatisticsService
    private let locationService: LocationService
    
    // MARK: - Coordinator
    weak var coordinator: HomeCoordinator?
    
    // MARK: - Input/Output
    struct Input {
        let refresh: AnyPublisher<Void, Never>
        let quickActionTapped: AnyPublisher<QuickAction, Never>
        let viewActivityDetails: AnyPublisher<Activity, Never>
    }
    
    struct Output {
        let dashboardData: AnyPublisher<DashboardData, Never>
        let isRefreshing: AnyPublisher<Bool, Never>
    }
    
    // MARK: - Initialization
    init(serviceContainer: ServiceContainer) {
        self.activityService = serviceContainer.activityService
        self.statisticsService = serviceContainer.statisticsService
        self.locationService = serviceContainer.locationService
        super.init()
    }
    
    // MARK: - Setup
    override func setupBindings() {
        // Load initial data
        Task {
            await loadDashboardData()
        }
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        // Handle refresh
        input.refresh
            .sink { [weak self] _ in
                Task {
                    await self?.refreshData()
                }
            }
            .store(in: &cancellables)
        
        // Handle quick actions
        input.quickActionTapped
            .sink { [weak self] action in
                self?.handleQuickAction(action)
            }
            .store(in: &cancellables)
        
        // Handle activity details
        input.viewActivityDetails
            .sink { [weak self] activity in
                self?.coordinator?.showActivityDetails(activity)
            }
            .store(in: &cancellables)
        
        return Output(
            dashboardData: $dashboardData.eraseToAnyPublisher(),
            isRefreshing: $isRefreshing.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Private Methods
    @MainActor
    private func loadDashboardData() async {
        showLoading()
        
        do {
            // Fetch data in parallel
            let activities = try await activityService.fetchTodayActivities()
            let weeklyProgress = try await statisticsService.getWeeklyGoalProgress()
            let outdoorTime = try await statisticsService.getTotalOutdoorTime()
            let streak = try await statisticsService.getCurrentStreak()
            let recentActivities = try await activityService.fetchRecentActivities(limit: 5)
            
            let data = DashboardData(
                todayActivities: activities.count,
                weeklyGoalProgress: weeklyProgress,
                totalOutdoorTime: outdoorTime,
                currentStreak: streak,
                recentActivities: recentActivities,
                weatherCondition: .sunny // TODO: Implement weather service
            )
            
            await MainActor.run {
                self.dashboardData = data
                self.hideLoading()
            }
        } catch {
            await MainActor.run {
                self.handleError(error)
            }
        }
    }
    
    private func refreshData() async {
        await MainActor.run {
            isRefreshing = true
        }
        
        await loadDashboardData()
        
        await MainActor.run {
            isRefreshing = false
        }
    }
    
    private func handleQuickAction(_ action: QuickAction) {
        switch action {
        case .startWalk:
            coordinator?.startActivity(.walking)
        case .startRun:
            coordinator?.startActivity(.running)
        case .startCycle:
            coordinator?.startActivity(.cycling)
        case .startCustom:
            quickActionSheet = .startCustom
        }
    }
}

// MARK: - Quick Actions
enum QuickAction: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case startWalk = "Walk"
    case startRun = "Run"
    case startCycle = "Cycle"
    case startCustom = "Custom"
    
    var systemImage: String {
        switch self {
        case .startWalk:
            return "figure.walk"
        case .startRun:
            return "figure.run"
        case .startCycle:
            return "bicycle"
        case .startCustom:
            return "plus.circle.fill"
        }
    }
}