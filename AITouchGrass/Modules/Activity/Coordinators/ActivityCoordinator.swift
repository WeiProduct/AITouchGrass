//
//  ActivityCoordinator.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI

/// Activity module coordinator
final class ActivityCoordinator: BaseCoordinator {
    // Routes
    enum Route: Hashable {
        case tracking
        case history
        case details(Activity)
        case saveActivity
    }
    
    // Sheet routes
    enum Sheet: Hashable {
        case addPhoto
        case editActivity(Activity)
        case shareActivity(Activity)
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
    func startTracking() {
        navigate(to: .tracking)
    }
    
    func showHistory() {
        navigate(to: .history)
    }
    
    func showDetails(_ activity: Activity) {
        navigate(to: .details(activity))
    }
    
    func showSaveActivity() {
        navigate(to: .saveActivity)
    }
    
    func activitySaved(_ activity: Activity) {
        popToRoot()
        showDetails(activity)
    }
    
    func showActivityTracking(_ activity: Activity) {
        // presentedSheet = Sheet.editActivity(activity) // Uncomment if needed
    }
    
    // MARK: - View Creation
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .tracking:
            ActivityTrackingView(viewModel: ActivityTrackingViewModel(
                activityService: serviceContainer.activityService,
                locationService: serviceContainer.locationService,
                healthKitService: serviceContainer.healthKitService
            ))
        
        case .history:
            ActivityHistoryView()
        
        case .details(let activity):
            ActivityDetailsFullView(activity: activity)
        
        case .saveActivity:
            SaveActivityView()
        }
    }
    
    @ViewBuilder
    func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .addPhoto:
            PhotoPickerView()
        
        case .editActivity(let activity):
            EditActivityView(activity: activity)
        
        case .shareActivity(let activity):
            ShareActivityView(activity: activity)
        }
    }
    
    // MARK: - Root View
    func rootView() -> some View {
        ActivityView(viewModel: ActivityViewModel(serviceContainer: self.serviceContainer))
            .environmentObject(self)
    }
}

// MARK: - Activity Root View
struct ActivityRootView: View {
    let coordinator: ActivityCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Activity Tracking")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("Start New Activity") {
                coordinator.startTracking()
            }
            .buttonStyle(.borderedProminent)
            
            Button("View History") {
                coordinator.showHistory()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Placeholder Views
struct ActivityHistoryView: View {
    var body: some View {
        Text("Activity History")
            .navigationTitle("History")
    }
}

struct ActivityDetailsFullView: View {
    let activity: Activity
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(activity.name)
                    .font(.title)
                
                Text("Type: \(activity.type.rawValue)")
                Text("Duration: \(formatDuration(activity.duration))")
                if let distance = activity.distance {
                    Text("Distance: \(String(format: "%.2f km", distance / 1000))")
                }
                if let calories = activity.calories {
                    Text("Calories: \(String(format: "%.0f kcal", calories))")
                }
            }
            .padding()
        }
        .navigationTitle("Activity Details")
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        return formatter.string(from: duration) ?? ""
    }
}

struct SaveActivityView: View {
    var body: some View {
        Text("Save Activity")
            .navigationTitle("Save")
    }
}

struct PhotoPickerView: View {
    var body: some View {
        Text("Photo Picker")
    }
}

struct EditActivityView: View {
    let activity: Activity
    
    var body: some View {
        Text("Edit Activity: \(activity.name)")
    }
}

struct ShareActivityView: View {
    let activity: Activity
    
    var body: some View {
        Text("Share Activity: \(activity.name)")
    }
}