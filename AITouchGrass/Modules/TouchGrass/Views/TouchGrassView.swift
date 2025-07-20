import SwiftUI
import Combine
import FamilyControls
import ManagedSettings
import AVFoundation

struct TouchGrassView: View {
    @StateObject var viewModel: TouchGrassViewModel
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var toggleBlockingSubject = PassthroughSubject<Void, Never>()
    @State private var selectAppsSubject = PassthroughSubject<Void, Never>()
    @State private var verifyGrassSubject = PassthroughSubject<UIImage, Never>()
    
    @State private var output: TouchGrassViewModel.Output?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showingImagePicker = false
    @State private var showingAppPicker = false
    @State private var showingAppSelection = false
    @State private var selectedImage: UIImage?
    @State private var familySelection = FamilyActivitySelection()
    @State private var showErrorAlert = false
    @State private var showingDiagnostic = false
    @State private var showingNotice = false
    @AppStorage("hasSeenBlockingNotice") private var hasSeenBlockingNotice = false
    
    @EnvironmentObject var coordinator: TouchGrassCoordinator
    
    private var shouldShowDemoModeCard: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        // On device, show demo card if using mock service
        return viewModel.isUsingMockService
        #endif
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(viewModel.selectedNatureType.color).opacity(0.1), Color.blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard
                    
                    // Nature Type Selector
                    natureTypeSelector
                    
                    // Demo Mode Alert for simulator or when Family Controls is unavailable
                    if shouldShowDemoModeCard {
                        demoModeCard
                    }
                    
                    // Authorization Alert if needed (only for real Family Controls service)
                    if !viewModel.isAuthorized && !viewModel.isUsingMockService {
                        authorizationCard
                    }
                    
                    // Status Card
                    statusCard
                    
                    // Blocked Apps Section
                    if !familySelection.applicationTokens.isEmpty || !familySelection.categoryTokens.isEmpty || !viewModel.selectedApps.isEmpty {
                        blockedContentSection
                    }
                    
                    // Action Buttons
                    actionButtons
                    
                    // Statistics Button (only for real service)
                    if viewModel.isUsingRealService {
                        statisticsButton
                    }
                    
                    // Diagnostic Button
                    diagnosticButton
                    
                    // Instructions
                    instructionsCard
                }
                .padding()
                .padding(.bottom, 50) // Add extra padding for tab bar
            }
        }
        .navigationTitle(L("专注"))
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingImagePicker) {
            CameraView(image: $selectedImage, isPresented: $showingImagePicker)
        }
        .alert(L("提示"), isPresented: $showErrorAlert) {
            Button(L("确定")) {
                viewModel.errorMessage = nil
                showErrorAlert = false
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showingAppPicker) {
            FamilyActivityPickerView(selection: $familySelection)
                .onDisappear {
                    // Convert FamilyActivitySelection to ApplicationTokens
                    updateBlockedAppsFromSelection()
                }
        }
        .sheet(isPresented: $showingAppSelection) {
            ManualAppSelectionView(selectedApps: Binding(
                get: { Set(viewModel.selectedApps) },
                set: { newApps in
                    viewModel.updateBlockedApps(newApps)
                }
            ))
        }
        .sheet(isPresented: $showingDiagnostic) {
            URLSchemeDiagnosticView()
        }
        .sheet(isPresented: $showingNotice) {
            AppBlockingNoticeView {
                hasSeenBlockingNotice = true
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                verifyGrassSubject.send(image)
            }
        }
        .onAppear {
            setupBindings()
            // 初始化时不自动请求授权，让用户主动触发
            
            // 如果是真实服务且用户还没看过说明，显示说明
            if viewModel.isUsingRealService && !hasSeenBlockingNotice {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingNotice = true
                }
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.selectedNatureType.systemImage)
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(viewModel.selectedNatureType.color), Color(viewModel.selectedNatureType.color).opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("专注模式")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("拍摄\(viewModel.selectedNatureType.rawValue)来解锁被限制的应用")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    // MARK: - Nature Type Selector
    private var natureTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择解锁方式")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(NatureType.allCases, id: \.self) { type in
                        NatureTypeButton(
                            type: type,
                            isSelected: viewModel.selectedNatureType == type,
                            isEnabled: viewModel.enabledNatureTypes.contains(type)
                        ) {
                            viewModel.selectedNatureType = type
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Demo Mode Card
    private var demoModeCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "theatermasks.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("演示模式"))
                        .font(.headline)
                    
                    #if targetEnvironment(simulator)
                    Text(L("当前在模拟器中运行，使用演示模式"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    #else
                    Text(L("Family Controls API 不可用，使用演示模式"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    #endif
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("• " + L("应用阻塞功能为模拟效果（仅发送通知提醒）"))
                #if targetEnvironment(simulator)
                Text("• " + L("在真机上可获得完整功能"))
                Text("• " + L("需要iOS设备和开发者账号"))
                #else
                Text("• " + L("Family Controls需要特殊Apple权限"))
                Text("• " + L("需要申请Screen Time entitlement"))
                Text("• " + L("当前使用演示模式进行体验"))
                #endif
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Authorization Card
    private var authorizationCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("需要授权"))
                        .font(.headline)
                    
                    Text(L("使用此功能需要屏幕使用时间权限"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button(action: {
                Task {
                    await viewModel.requestScreenTimeAuthorization()
                }
            }) {
                HStack {
                    Image(systemName: "shield.checkered")
                    Text(L("授权屏幕使用时间"))
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Status Card
    private var statusCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("锁定状态"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(viewModel.isBlocking ? Color.red : Color.green)
                            .frame(width: 12, height: 12)
                        
                        Text(viewModel.isBlocking ? L("已启用") : L("未启用"))
                            .font(.headline)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { viewModel.isBlocking },
                    set: { _ in toggleBlockingSubject.send() }
                ))
                .labelsHidden()
                .tint(.green)
            }
            
            if let remainingTime = viewModel.remainingUnlockTime, remainingTime > 0 {
                VStack(spacing: 8) {
                    Text(L("临时解锁剩余时间"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(remainingTime))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .padding(.top, 8)
            }
            
            // 如果未授权，显示授权按钮（仅限真实服务）
            if !viewModel.isAuthorized && !viewModel.isUsingMockService {
                VStack(spacing: 8) {
                    Text(L("需要屏幕使用时间权限"))
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Button(action: {
                        Task {
                            await viewModel.requestScreenTimeAuthorization()
                        }
                    }) {
                        Text(L("立即授权"))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .cornerRadius(15)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Blocked Content Section
    private var blockedContentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L("锁定的内容"))
                    .font(.headline)
                
                Spacer()
                
                let totalCount = familySelection.applicationTokens.count + familySelection.categoryTokens.count + viewModel.selectedApps.count
                Text("\(totalCount) " + L("项"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 显示选择的应用 (RealAppBlockingService)
            if !viewModel.selectedApps.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L("选择的应用"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(viewModel.selectedApps), id: \.id) { app in
                                SelectedAppView(app: app) {
                                    var updatedApps = viewModel.selectedApps
                                    updatedApps.remove(app)
                                    viewModel.updateBlockedApps(updatedApps)
                                }
                            }
                        }
                    }
                }
            }
            
            // 显示类别 (FamilyControls)
            if !familySelection.categoryTokens.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("应用类别")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(familySelection.categoryTokens), id: \.self) { token in
                                CategoryTokenView(token: token) {
                                    familySelection.categoryTokens.remove(token)
                                    updateBlockedAppsFromSelection()
                                }
                            }
                        }
                    }
                }
            }
            
            // 显示具体应用 (FamilyControls)
            if !familySelection.applicationTokens.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("具体应用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(familySelection.applicationTokens), id: \.self) { token in
                                AppTokenView(token: token) {
                                    familySelection.applicationTokens.remove(token)
                                    updateBlockedAppsFromSelection()
                                }
                            }
                        }
                    }
                }
            }
            
            // 提示文字
            if viewModel.isUsingMockService {
                Text("提示：点击类别旁的 'All' 可以选择具体应用")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                Text("提示：选择的应用将被锁定，拍摄自然景观可临时解锁")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Select Apps Button
            Button(action: {
                if viewModel.isUsingMockService {
                    showingAppPicker = true
                } else {
                    // 使用手动选择界面
                    showingAppSelection = true
                }
            }) {
                HStack {
                    Image(systemName: "apps.iphone")
                    Text("选择要锁定的应用")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            // Verify Nature Button
            Button(action: {
                print("DEBUG: Verify Nature button tapped")
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text(viewModel.isBlocking ? "拍摄\(viewModel.selectedNatureType.rawValue)解锁" : "测试\(viewModel.selectedNatureType.rawValue)识别")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(viewModel.selectedNatureType.color), Color(viewModel.selectedNatureType.color).opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(viewModel.isVerifying)
        }
    }
    
    // MARK: - Statistics Button
    private var statisticsButton: some View {
        Button(action: {
            coordinator.showAppUsageHistory()
        }) {
            HStack {
                Image(systemName: "chart.bar.fill")
                Text("使用统计")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.purple, .purple.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
    }
    
    // MARK: - Diagnostic Button
    private var diagnosticButton: some View {
        Button(action: {
            showingDiagnostic = true
        }) {
            HStack {
                Image(systemName: "stethoscope")
                Text("应用检测诊断")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.indigo, .indigo.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
    }
    
    // MARK: - Instructions Card
    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("使用说明")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionRow(
                    number: "1",
                    text: "选择你想要限制使用的应用",
                    icon: "apps.iphone"
                )
                
                InstructionRow(
                    number: "2",
                    text: "启用锁定功能",
                    icon: "lock.fill"
                )
                
                InstructionRow(
                    number: "3",
                    text: "当你需要使用被锁定的应用时，拍摄真实的自然景观",
                    icon: "camera.fill"
                )
                
                InstructionRow(
                    number: "4",
                    text: "成功识别后，应用将解锁1小时",
                    icon: "clock.fill"
                )
                
                if shouldShowDemoModeCard {
                    InstructionRow(
                        number: "ℹ️",
                        text: "当前为演示模式，实际应用阻塞需要特殊权限",
                        icon: "info.circle.fill"
                    )
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Helper Methods
    private func setupBindings() {
        viewModel.coordinator = coordinator
        
        let input = TouchGrassViewModel.Input(
            toggleBlocking: toggleBlockingSubject.eraseToAnyPublisher(),
            selectApps: selectAppsSubject.eraseToAnyPublisher(),
            verifyGrass: verifyGrassSubject.eraseToAnyPublisher()
        )
        
        output = viewModel.transform(input: input)
        
        // Handle verification results
        output?.verificationResult
            .sink { result in
                if result.isValid && result.isHighConfidence {
                    // Show success
                } else {
                    // Show failure
                }
            }
            .store(in: &cancellables)
        
        // Handle errors
        output?.errorOccurred
            .sink { error in
                showErrorAlert = true
            }
            .store(in: &cancellables)
        
        // Monitor error message changes
        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { _ in
                showErrorAlert = true
            }
            .store(in: &cancellables)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func updateBlockedAppsFromSelection() {
        // Update the view model with selected apps
        viewModel.updateBlockedAppsFromFamilySelection(familySelection)
    }
}

// MARK: - Supporting Views
struct SelectedAppView: View {
    let app: AppInfo
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: app.systemImage)
                .font(.title3)
                .foregroundColor(Color(app.category.lowercased()))
            
            Text(app.name)
                .font(.caption)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct AppTokenView: View {
    let token: ApplicationToken
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "app.fill")
                .font(.title3)
                .foregroundColor(.blue)
            
            Text("App")
                .font(.caption)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct CategoryTokenView: View {
    let token: ActivityCategoryToken
    let onRemove: () -> Void
    
    // 根据类别显示不同的图标和名称
    private var categoryInfo: (icon: String, name: String, color: Color) {
        // 这里我们无法直接获取类别名称，所以使用通用显示
        return ("folder.fill", "类别", .orange)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: categoryInfo.icon)
                .font(.title3)
                .foregroundColor(categoryInfo.color)
            
            Text(categoryInfo.name)
                .font(.caption)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                Text(number)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}


// MARK: - Nature Type Button
struct NatureTypeButton: View {
    let type: NatureType
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.systemImage)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : (isEnabled ? Color(type.color) : .gray))
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : (isEnabled ? .primary : .gray))
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(type.color) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(type.color) : Color.clear, lineWidth: 2)
            )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

