//
//  AppCoordinator.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI
import Combine

/// Main app coordinator
@MainActor
final class AppCoordinator: BaseCoordinator {
    // Module coordinators
    @Published var homeCoordinator: HomeCoordinator
    @Published var activityCoordinator: ActivityCoordinator
    @Published var profileCoordinator: ProfileCoordinator
    @Published var statisticsCoordinator: StatisticsCoordinator
    @Published var touchGrassCoordinator: TouchGrassCoordinator
    
    // Tab selection
    @Published var selectedTab: AppTab = .home
    
    // Dependencies
    let serviceContainer: ServiceContainer
    
    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
        
        // Initialize module coordinators
        self.homeCoordinator = HomeCoordinator(serviceContainer: serviceContainer)
        self.activityCoordinator = ActivityCoordinator(serviceContainer: serviceContainer)
        self.profileCoordinator = ProfileCoordinator(serviceContainer: serviceContainer)
        self.statisticsCoordinator = StatisticsCoordinator(serviceContainer: serviceContainer)
        self.touchGrassCoordinator = TouchGrassCoordinator(serviceContainer: serviceContainer)
        
        super.init()
    }
    
    override func setupBindings() {
        // Setup inter-module navigation if needed
    }
    
    func rootView() -> some View {
        AppRootView(coordinator: self)
    }
}

/// App tabs
enum AppTab: String, CaseIterable {
    case home = "Home"
    case activity = "Activity"
    case touchGrass = "TouchGrass"
    case statistics = "Statistics"
    case profile = "Profile"
    
    var systemImage: String {
        switch self {
        case .home:
            return "house.fill"
        case .activity:
            return "figure.walk"
        case .touchGrass:
            return "leaf.fill"
        case .statistics:
            return "chart.bar.fill"
        case .profile:
            return "person.fill"
        }
    }
}