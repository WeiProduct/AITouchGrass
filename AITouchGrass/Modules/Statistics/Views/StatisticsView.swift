//
//  StatisticsView.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI
import Combine
import Charts

struct StatisticsView: View {
    // MARK: - Properties
    @StateObject var viewModel: StatisticsViewModel
    @State private var loadStatisticsSubject = PassthroughSubject<Void, Never>()
    @State private var changeTimeRangeSubject = PassthroughSubject<TimeRange, Never>()
    @State private var changeChartTypeSubject = PassthroughSubject<ChartType, Never>()
    @State private var filterByActivitySubject = PassthroughSubject<ActivityType?, Never>()
    @State private var exportDataSubject = PassthroughSubject<Void, Never>()
    @State private var shareStatsSubject = PassthroughSubject<Void, Never>()
    
    @State private var output: StatisticsViewModel.Output?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var chartData: ChartData?
    @State private var showActivityFilter = false
    
    @EnvironmentObject var coordinator: StatisticsCoordinator
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Time Range Selector
                        timeRangeSelectorSection
                        
                        // Summary Cards
                        summaryCardsSection
                        
                        // Chart Section
                        chartSection
                        
                        // Activity Distribution
                        activityDistributionSection
                        
                        // Weekly Progress
                        weeklyProgressSection
                    }
                    .padding(.vertical)
                }
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .navigationTitle("统计数据")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            exportDataSubject.send()
                        }) {
                            Label("导出数据", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: {
                            shareStatsSubject.send()
                        }) {
                            Label("分享统计", systemImage: "square.and.arrow.up.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showActivityFilter) {
            activityFilterSheet
        }
        .onAppear {
            setupBindings()
            loadStatisticsSubject.send()
        }
        .onChange(of: viewModel.selectedTimeRange) {
            loadStatisticsSubject.send()
        }
        .onChange(of: viewModel.selectedActivityType) {
            loadStatisticsSubject.send()
        }
    }
    
    // MARK: - Time Range Selector Section
    private var timeRangeSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    TimeRangeButton(
                        title: timeRangeTitle(for: range),
                        isSelected: viewModel.selectedTimeRange == range
                    ) {
                        changeTimeRangeSubject.send(range)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Summary Cards Section
    private var summaryCardsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            SummaryCard(
                title: "总活动",
                value: "\(viewModel.statisticsData.totalActivities)",
                subtitle: "次",
                icon: "figure.run",
                color: .blue
            )
            
            SummaryCard(
                title: "总距离",
                value: formatDistance(viewModel.statisticsData.totalDistance),
                subtitle: viewModel.statisticsData.totalDistance >= 1000 ? "公里" : "米",
                icon: "location.fill",
                color: .green
            )
            
            SummaryCard(
                title: "总时长",
                value: formatDuration(viewModel.statisticsData.totalDuration),
                subtitle: viewModel.statisticsData.totalDuration >= 3600 ? "小时" : "分钟",
                icon: "clock.fill",
                color: .orange
            )
            
            SummaryCard(
                title: "总消耗",
                value: String(format: "%.0f", viewModel.statisticsData.totalCalories),
                subtitle: "卡路里",
                icon: "flame.fill",
                color: .red
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart Header
            HStack {
                Text("趋势图表")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Button(action: {
                            changeChartTypeSubject.send(type)
                        }) {
                            Label(chartTypeTitle(for: type), systemImage: chartTypeIcon(for: type))
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(chartTypeTitle(for: viewModel.chartType))
                            .font(.subheadline)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal)
            
            // Chart View
            if let chartData = chartData, !chartData.chartPoints.isEmpty {
                Chart(chartData.chartPoints) { point in
                    if viewModel.chartType == .activities {
                        BarMark(
                            x: .value("日期", point.date),
                            y: .value(chartTypeTitle(for: viewModel.chartType), point.value)
                        )
                        .foregroundStyle(Color.accentColor.gradient)
                    } else {
                        LineMark(
                            x: .value("日期", point.date),
                            y: .value(chartTypeTitle(for: viewModel.chartType), point.value)
                        )
                        .foregroundStyle(Color.accentColor)
                        
                        AreaMark(
                            x: .value("日期", point.date),
                            y: .value(chartTypeTitle(for: viewModel.chartType), point.value)
                        )
                        .foregroundStyle(Color.accentColor.opacity(0.1).gradient)
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("暂无数据")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Activity Distribution Section
    private var activityDistributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("活动分布")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showActivityFilter = true
                }) {
                    if let selectedType = viewModel.selectedActivityType {
                        HStack(spacing: 4) {
                            Image(systemName: selectedType.systemImage)
                                .font(.caption)
                            Text(selectedType.displayName)
                                .font(.subheadline)
                        }
                        .foregroundColor(.accentColor)
                    } else {
                        Text("筛选")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(.horizontal)
            
            // Activity Type Bars
            VStack(spacing: 12) {
                ForEach(Array(viewModel.statisticsData.activitiesByType.sorted(by: { $0.value > $1.value })), id: \.key) { type, count in
                    ActivityTypeBar(
                        type: type,
                        count: count,
                        totalCount: viewModel.statisticsData.totalActivities
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Weekly Progress Section
    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("本周进度")
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(viewModel.statisticsData.weeklyProgress.completionPercentage.isFinite ? viewModel.statisticsData.weeklyProgress.completionPercentage : 0))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
            }
            .padding(.horizontal)
            
            // Weekly Calendar
            HStack(spacing: 8) {
                ForEach(viewModel.statisticsData.weeklyProgress.days) { day in
                    VStack(spacing: 8) {
                        Text(day.dayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            Circle()
                                .fill(day.hasActivity ? Color.accentColor : Color(.systemGray5))
                                .frame(width: 40, height: 40)
                            
                            if day.hasActivity {
                                Text("\(day.activities)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Progress indicator
                        GeometryReader { geometry in
                            ZStack(alignment: .bottom) {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                
                                Rectangle()
                                    .fill(Color.accentColor)
                                    .frame(height: geometry.size.height * CGFloat(day.goalProgress))
                            }
                        }
                        .frame(height: 4)
                        .cornerRadius(2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Activity Filter Sheet
    private var activityFilterSheet: some View {
        NavigationView {
            List {
                // All activities option
                Button(action: {
                    filterByActivitySubject.send(nil)
                    showActivityFilter = false
                }) {
                    HStack {
                        Image(systemName: "square.grid.2x2")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                            .frame(width: 32)
                        
                        Text("全部活动")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if viewModel.selectedActivityType == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                
                // Activity types
                ForEach(ActivityType.allCases, id: \.self) { type in
                    Button(action: {
                        filterByActivitySubject.send(type)
                        showActivityFilter = false
                    }) {
                        HStack {
                            Image(systemName: type.systemImage)
                                .font(.title3)
                                .foregroundColor(Color(type.color))
                                .frame(width: 32)
                            
                            Text(type.displayName)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if viewModel.selectedActivityType == type {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("筛选活动类型")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        showActivityFilter = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func setupBindings() {
        viewModel.coordinator = coordinator
        
        let input = StatisticsViewModel.Input(
            loadStatistics: loadStatisticsSubject.eraseToAnyPublisher(),
            changeTimeRange: changeTimeRangeSubject.eraseToAnyPublisher(),
            changeChartType: changeChartTypeSubject.eraseToAnyPublisher(),
            filterByActivity: filterByActivitySubject.eraseToAnyPublisher(),
            exportData: exportDataSubject.eraseToAnyPublisher(),
            shareStats: shareStatsSubject.eraseToAnyPublisher()
        )
        
        output = viewModel.transform(input: input)
        
        // Subscribe to chart data
        output?.chartData
            .sink { data in
                chartData = data
            }
            .store(in: &cancellables)
    }
    
    private func timeRangeTitle(for range: TimeRange) -> String {
        switch range {
        case .week: return "本周"
        case .month: return "本月"
        case .year: return "今年"
        case .all: return "全部"
        }
    }
    
    private func chartTypeTitle(for type: ChartType) -> String {
        switch type {
        case .distance: return "距离"
        case .duration: return "时长"
        case .calories: return "卡路里"
        case .activities: return "活动次数"
        }
    }
    
    private func chartTypeIcon(for type: ChartType) -> String {
        switch type {
        case .distance: return "location.fill"
        case .duration: return "clock.fill"
        case .calories: return "flame.fill"
        case .activities: return "chart.bar.fill"
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            return String(format: "%.1f", distance / 1000)
        } else {
            return String(format: "%.0f", distance)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        if duration >= 3600 {
            return String(format: "%.1f", duration / 3600)
        } else {
            return String(format: "%.0f", duration / 60)
        }
    }
}

// MARK: - Supporting Views
struct TimeRangeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.accentColor : Color(.systemGray5)
                )
                .cornerRadius(20)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ActivityTypeBar: View {
    let type: ActivityType
    let count: Int
    let totalCount: Int
    
    private var percentage: Double {
        totalCount > 0 ? Double(count) / Double(totalCount) : 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: type.systemImage)
                        .font(.subheadline)
                        .foregroundColor(Color(type.color))
                    
                    Text(type.displayName)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text("\(count) 次")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color(type.color))
                        .frame(width: geometry.size.width * CGFloat(percentage))
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    StatisticsView(
        viewModel: StatisticsViewModel(serviceContainer: ServiceContainer.shared)
    )
    .environmentObject(StatisticsCoordinator(serviceContainer: ServiceContainer.shared))
}