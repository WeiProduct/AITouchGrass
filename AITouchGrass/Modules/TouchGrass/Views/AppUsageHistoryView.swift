import SwiftUI
import SwiftData

struct AppUsageHistoryView: View {
    @StateObject private var viewModel: AppUsageHistoryViewModel
    
    init(appBlockingService: RealAppBlockingService) {
        _viewModel = StateObject(wrappedValue: AppUsageHistoryViewModel(appBlockingService: appBlockingService))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Usage Statistics
                    usageStatisticsSection
                    
                    // Blocking History
                    blockingHistorySection
                    
                    // App Usage Details
                    appUsageDetailsSection
                }
                .padding()
            }
            .navigationTitle("使用统计")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private var usageStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日统计")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                StatisticCard(
                    title: "解锁次数",
                    value: "\(viewModel.todayUnlockCount)",
                    icon: "camera.fill",
                    color: .green
                )
                
                StatisticCard(
                    title: "专注时长",
                    value: formatDuration(viewModel.todayFocusTime),
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatisticCard(
                    title: "被阻止的应用",
                    value: "\(viewModel.blockedAppsCount)",
                    icon: "shield.fill",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var blockingHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("最近会话")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.recentSessions, id: \.startTime) { session in
                    BlockingSessionCard(session: session)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var appUsageDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("应用使用详情")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.appUsageList, id: \.appName) { appUsage in
                    AppUsageCard(appUsage: appUsage)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
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

struct BlockingSessionCard: View {
    let session: AppBlockingSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.natureType.capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(formatDate(session.startTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatDuration(session.duration))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(session.verificationCount) 次解锁")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("阻止应用: \(session.blockedApps.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("解锁时长: \(formatDuration(session.totalUnlockTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct AppUsageCard: View {
    let appUsage: AppUsage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appUsage.appName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(appUsage.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(appUsage.usageCount) 次")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatDuration(appUsage.totalUsageTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Status indicator
            Circle()
                .fill(appUsage.isCurrentlyBlocked ? Color.red : Color.green)
                .frame(width: 8, height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

@MainActor
final class AppUsageHistoryViewModel: ObservableObject {
    @Published var recentSessions: [AppBlockingSession] = []
    @Published var appUsageList: [AppUsage] = []
    @Published var todayUnlockCount: Int = 0
    @Published var todayFocusTime: TimeInterval = 0
    @Published var blockedAppsCount: Int = 0
    
    private let appBlockingService: RealAppBlockingService
    
    init(appBlockingService: RealAppBlockingService) {
        self.appBlockingService = appBlockingService
    }
    
    func loadData() {
        recentSessions = appBlockingService.getBlockingHistory()
        appUsageList = appBlockingService.getUsageStatistics()
        blockedAppsCount = appUsageList.filter { $0.isCurrentlyBlocked }.count
        
        // Calculate today's statistics
        let today = Calendar.current.startOfDay(for: Date())
        let todaySessions = recentSessions.filter { session in
            Calendar.current.isDate(session.startTime, inSameDayAs: today)
        }
        
        todayUnlockCount = todaySessions.reduce(0) { $0 + $1.verificationCount }
        todayFocusTime = todaySessions.reduce(0) { $0 + $1.duration }
    }
}

#Preview {
    // Create a mock service for preview
    let mockService = RealAppBlockingService(modelContainer: try! ModelContainer(for: AppUsage.self, AppBlockingSession.self))
    AppUsageHistoryView(appBlockingService: mockService)
}