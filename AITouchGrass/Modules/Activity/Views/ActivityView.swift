import SwiftUI
import Combine

struct ActivityView: View {
    @StateObject var viewModel: ActivityViewModel
    @EnvironmentObject var coordinator: ActivityCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Activity Section
                    if let currentActivity = viewModel.output?.currentActivity {
                        CurrentActivityCard()
                            .onReceive(currentActivity) { activity in
                                if let activity = activity {
                                    coordinator.showActivityTracking(activity)
                                }
                            }
                    }
                    
                    // Quick Start Section
                    QuickStartSection(viewModel: viewModel)
                    
                    // Recent Activities
                    RecentActivitiesSection(viewModel: viewModel, coordinator: coordinator)
                }
                .padding()
            }
            .navigationTitle("活动")
            .navigationDestination(for: Activity.self) { activity in
                ActivityDetailView(activity: activity)
            }
            .sheet(isPresented: .constant(coordinator.presentedSheet != nil)) {
                if let sheet = coordinator.presentedSheet {
                    switch sheet {
                    case let activity as Activity:
                        ActivityTrackingView(
                            viewModel: ActivityTrackingViewModel(
                                activity: activity,
                                serviceContainer: viewModel.serviceContainer
                            )
                        )
                    default:
                        EmptyView()
                    }
                } else {
                    EmptyView()
                }
            }
        }
        .onAppear {
            viewModel.input.viewAppeared.send()
        }
    }
}

struct QuickStartSection: View {
    let viewModel: ActivityViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快速开始")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(ActivityType.allCases, id: \.self) { type in
                    ActivityTypeCard(type: type) {
                        viewModel.input.startActivityTapped.send(type)
                    }
                }
            }
        }
    }
}

struct ActivityTypeCard: View {
    let type: ActivityType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.systemImage)
                    .font(.title2)
                Text(type.displayName)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(type.color).opacity(0.1))
            .foregroundColor(Color(type.color))
            .cornerRadius(12)
        }
    }
}

struct CurrentActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("当前活动")
                        .font(.headline)
                    Text("正在进行中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .padding()
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct RecentActivitiesSection: View {
    let viewModel: ActivityViewModel
    let coordinator: ActivityCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近活动")
                .font(.headline)
            
            if let output = viewModel.output {
                RecentActivitiesList(
                    activitiesPublisher: output.recentActivities,
                    onSelect: { activity in
                        viewModel.input.activitySelected.send(activity)
                    }
                )
            }
        }
    }
}

struct RecentActivitiesList: View {
    let activitiesPublisher: AnyPublisher<[Activity], Never>
    let onSelect: (Activity) -> Void
    @State private var activities: [Activity] = []
    
    var body: some View {
        VStack(spacing: 8) {
            if activities.isEmpty {
                Text("暂无活动记录")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ForEach(activities) { activity in
                    ActivityRow(activity: activity)
                        .onTapGesture {
                            onSelect(activity)
                        }
                }
            }
        }
        .onReceive(activitiesPublisher) { activities in
            self.activities = activities
        }
    }
}

struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: activity.type.systemImage)
                .font(.title3)
                .foregroundColor(Color(activity.type.color))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    Label("\(formatDuration(activity.duration))", systemImage: "clock")
                    Label("\(formatDistance(activity.distance ?? 0))", systemImage: "location")
                    Label("\(activity.calories ?? 0) 卡", systemImage: "flame")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(activity.startDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0分"
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f米", distance)
        } else {
            return String(format: "%.1f公里", distance / 1000)
        }
    }
}

struct ActivityDetailView: View {
    let activity: Activity
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Activity Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: activity.type.systemImage)
                            .font(.title)
                            .foregroundColor(Color(activity.type.color))
                        Text(activity.type.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text(activity.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(activity.startDate.formatted(date: .complete, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ActivityStatCard(title: "时长", value: formatDuration(activity.duration), icon: "clock.fill")
                    ActivityStatCard(title: "距离", value: formatDistance(activity.distance ?? 0), icon: "location.fill")
                    ActivityStatCard(title: "卡路里", value: "\(activity.calories ?? 0)", icon: "flame.fill")
                    if let avgHeart = activity.averageHeartRate {
                        ActivityStatCard(title: "平均心率", value: "\(avgHeart)", icon: "heart.fill")
                    }
                }
                
                // Notes Section
                if let notes = activity.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("备注")
                            .font(.headline)
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        return formatter.string(from: duration) ?? "0秒"
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f 米", distance)
        } else {
            return String(format: "%.2f 公里", distance / 1000)
        }
    }
}

struct ActivityStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}