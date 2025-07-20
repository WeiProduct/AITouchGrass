//
//  StatisticsCoordinator.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI

/// Statistics module coordinator
final class StatisticsCoordinator: BaseCoordinator {
    // Routes
    enum Route: Hashable {
        case detailedStats(TimeRange)
        case activityComparison
        case personalRecords
        case exportOptions
    }
    
    // Sheet routes
    enum Sheet: Hashable {
        case shareStatistics
        case exportData
        case filterOptions
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
    func showDetailedStats(for timeRange: TimeRange) {
        navigate(to: .detailedStats(timeRange))
    }
    
    func showActivityComparison() {
        navigate(to: .activityComparison)
    }
    
    func showPersonalRecords() {
        navigate(to: .personalRecords)
    }
    
    func exportStatistics() {
        presentSheet(.exportData)
    }
    
    func shareStatistics() {
        presentSheet(.shareStatistics)
    }
    
    // MARK: - View Creation
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .detailedStats(let timeRange):
            DetailedStatsView(timeRange: timeRange)
        
        case .activityComparison:
            ActivityComparisonView()
        
        case .personalRecords:
            PersonalRecordsView()
        
        case .exportOptions:
            ExportOptionsView()
        }
    }
    
    @ViewBuilder
    func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .shareStatistics:
            ShareStatisticsView()
        
        case .exportData:
            ExportDataOptionsView()
        
        case .filterOptions:
            FilterOptionsView()
        }
    }
    
    // MARK: - Root View
    func rootView() -> some View {
        StatisticsView(viewModel: StatisticsViewModel(serviceContainer: self.serviceContainer))
            .environmentObject(self)
    }
}

// MARK: - Placeholder Views
struct DetailedStatsView: View {
    let timeRange: TimeRange
    
    var body: some View {
        Text("Detailed Statistics for \(timeRange.rawValue)")
            .navigationTitle("Detailed Stats")
    }
}

struct ActivityComparisonView: View {
    var body: some View {
        Text("Activity Comparison")
            .navigationTitle("Compare Activities")
    }
}

struct PersonalRecordsView: View {
    var body: some View {
        Text("Personal Records")
            .navigationTitle("Personal Records")
    }
}

struct ExportOptionsView: View {
    var body: some View {
        Text("Export Options")
            .navigationTitle("Export Data")
    }
}

struct ShareStatisticsView: View {
    var body: some View {
        Text("Share Statistics")
    }
}

struct ExportDataOptionsView: View {
    var body: some View {
        Text("Export Data Options")
    }
}

struct FilterOptionsView: View {
    var body: some View {
        Text("Filter Options")
    }
}