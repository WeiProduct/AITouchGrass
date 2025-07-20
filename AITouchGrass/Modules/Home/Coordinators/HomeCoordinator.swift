//
//  HomeCoordinator.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI
import Combine

/// Home module coordinator
final class HomeCoordinator: BaseCoordinator {
    // Routes
    enum Route: Hashable {
        case activityDetails(Activity)
        case startActivity(ActivityType)
    }
    
    // Sheet routes
    enum Sheet: Hashable {
        case customActivity
        case weatherDetails
    }
    
    // Dependencies
    private let serviceContainer: ServiceContainer
    
    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
        super.init()
    }
    
    // MARK: - Navigation
    func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    func presentSheet(_ sheet: Sheet) {
        presentedSheet = sheet
    }
    
    // MARK: - Navigation Methods
    func showActivityDetails(_ activity: Activity) {
        navigate(to: .activityDetails(activity))
    }
    
    func startActivity(_ type: ActivityType) {
        navigate(to: .startActivity(type))
    }
    
    // MARK: - View Creation
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .activityDetails(let activity):
            ActivityDetailsView(activity: activity)
        
        case .startActivity(let type):
            StartActivityView(activityType: type)
        }
    }
    
    @ViewBuilder
    func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .customActivity:
            CustomActivitySheet()
        
        case .weatherDetails:
            WeatherDetailsSheet()
        }
    }
    
    // MARK: - Root View
    func rootView() -> some View {
        HomeView(viewModel: HomeViewModel(serviceContainer: self.serviceContainer))
            .environmentObject(self)
    }
}

// MARK: - Placeholder Views
struct ActivityDetailsView: View {
    let activity: Activity
    
    var body: some View {
        Text("Activity Details: \(activity.name)")
            .navigationTitle("Activity Details")
    }
}

struct StartActivityView: View {
    let activityType: ActivityType
    
    var body: some View {
        Text("Start \(activityType.rawValue)")
            .navigationTitle("New Activity")
    }
}

struct WeatherDetailsSheet: View {
    var body: some View {
        Text("Weather Details")
    }
}