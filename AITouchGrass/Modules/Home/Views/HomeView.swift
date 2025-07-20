//
//  HomeView.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var refreshSubject = PassthroughSubject<Void, Never>()
    @State private var quickActionSubject = PassthroughSubject<QuickAction, Never>()
    @State private var activityDetailSubject = PassthroughSubject<Activity, Never>()
    @State private var showingSettings = false
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weather Card
                WeatherCard(weather: viewModel.dashboardData.weatherCondition)
                    .padding(.horizontal)
                
                // Stats Overview
                StatsOverviewView(data: viewModel.dashboardData)
                    .padding(.horizontal)
                
                // Quick Actions
                QuickActionsView(onActionTapped: { action in
                    quickActionSubject.send(action)
                })
                .padding(.horizontal)
                
                // Recent Activities
                RecentActivitiesView(
                    activities: viewModel.dashboardData.recentActivities,
                    onActivityTapped: { activity in
                        activityDetailSubject.send(activity)
                    }
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
            .padding(.bottom, 50) // Add padding for tab bar
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(L("AITouchGrass"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                    
                    Button(action: {
                        refreshSubject.send()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isRefreshing)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .refreshable {
            refreshSubject.send()
        }
        .loadingOverlay(isLoading: viewModel.isLoading)
        .customAlert(config: $viewModel.alertConfig)
        .sheet(item: $viewModel.quickActionSheet) { action in
            // Handle custom activity sheet
            CustomActivitySheet()
        }
        .onAppear {
            setupBindings()
        }
    }
    
    private func setupBindings() {
        let input = HomeViewModel.Input(
            refresh: refreshSubject.eraseToAnyPublisher(),
            quickActionTapped: quickActionSubject.eraseToAnyPublisher(),
            viewActivityDetails: activityDetailSubject.eraseToAnyPublisher()
        )
        
        _ = viewModel.transform(input: input)
    }
}

// MARK: - Weather Card
struct WeatherCard: View {
    let weather: WeatherCondition
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(L("今日天气"))
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(weather.recommendation)
                    .font(.title3)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Image(systemName: weather.systemImage)
                .font(.system(size: 50))
                .foregroundColor(.accentColor)
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Stats Overview
struct StatsOverviewView: View {
    let data: DashboardData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                HomeStatCard(
                    title: L("今日"),
                    value: "\(data.todayActivities)",
                    subtitle: L("活动"),
                    systemImage: "figure.walk"
                )
                
                HomeStatCard(
                    title: L("连续"),
                    value: "\(data.currentStreak)",
                    subtitle: L("天"),
                    systemImage: "flame.fill"
                )
            }
            
            HStack(spacing: 16) {
                HomeStatCard(
                    title: L("户外时间"),
                    value: formatTime(data.totalOutdoorTime),
                    subtitle: L("今日"),
                    systemImage: "clock.fill"
                )
                
                HomeStatCard(
                    title: L("周目标"),
                    value: "\(Int(data.weeklyGoalProgress * 100))%",
                    subtitle: L("完成"),
                    systemImage: "target"
                )
            }
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Stat Card
struct HomeStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primary, .primary.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemGray6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
        )
    }
}

// MARK: - Quick Actions
struct QuickActionsView: View {
    let onActionTapped: (QuickAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("快速开始"))
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(QuickAction.allCases, id: \.self) { action in
                    QuickActionButton(
                        action: action,
                        onTap: { onActionTapped(action) }
                    )
                }
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let action: QuickAction
    let onTap: () -> Void
    
    var actionColor: Color {
        switch action {
        case .startWalk:
            return .green
        case .startRun:
            return .orange
        case .startCycle:
            return .blue
        case .startCustom:
            return .purple
        }
    }
    
    var actionName: String {
        switch action {
        case .startWalk:
            return L("步行")
        case .startRun:
            return L("跑步")
        case .startCycle:
            return L("骑行")
        case .startCustom:
            return L("自定义")
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [actionColor, actionColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: action.systemImage)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Text(actionName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(actionColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(actionColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: 1.0)
    }
}

// MARK: - Recent Activities
struct RecentActivitiesView: View {
    let activities: [Activity]
    let onActivityTapped: (Activity) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("最近活动"))
                .font(.headline)
            
            if activities.isEmpty {
                Text(L("还没有活动记录。开始你的第一次户外活动吧！"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .cardStyle()
            } else {
                ForEach(activities) { activity in
                    HomeActivityRow(activity: activity)
                        .onTapGesture {
                            onActivityTapped(activity)
                        }
                }
            }
        }
    }
}

// MARK: - Activity Row
struct HomeActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: activity.type.systemImage)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.headline)
                
                HStack {
                    Text(activity.startDate, style: .date)
                    Text("•")
                    Text(formatDuration(activity.duration))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .cardStyle()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}

// MARK: - Custom Activity Sheet
struct HomeCustomActivitySheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Text("Custom Activity Setup")
                .navigationTitle("New Activity")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}