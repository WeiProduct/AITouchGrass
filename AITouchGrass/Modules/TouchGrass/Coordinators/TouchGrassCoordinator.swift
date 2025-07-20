import Foundation
import SwiftUI

@MainActor
final class TouchGrassCoordinator: BaseCoordinator {
    typealias Route = TouchGrassRoute
    
    private let serviceContainer: ServiceContainer
    
    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
        super.init()
    }
    
    func navigate(to route: TouchGrassRoute) {
        switch route {
        case .main:
            navigationPath = NavigationPath()
        case .appSelection:
            // Handled by FamilyActivityPicker
            break
        case .cameraCapture:
            // Handled by ImagePicker
            break
        case .unlockSuccess(let confidence):
            showUnlockSuccess(confidence: confidence)
        case .settings:
            navigationPath.append(route)
        }
    }
    
    func showUnlockSuccess(confidence: Int) {
        // Show success message or navigate to success view
        // This could be implemented as an alert or a dedicated view
    }
    
    func showUnlockSuccess(confidence: Double) {
        print("Unlock success with confidence: \(confidence)")
        // TODO: Implement success screen
    }
    
    func showAppUsageHistory() {
        guard ServiceContainer.shared.appBlockingService is RealAppBlockingService else {
            print("App usage history only available with RealAppBlockingService")
            return
        }
        
        // For now, just print that we would show history
        // In a real implementation, you would handle this through the navigation system
        print("📊 Would show app usage history view")
        
        // TODO: Implement proper sheet presentation or navigation
        // This could be done through the presentedSheet property in BaseCoordinator
    }
    
    func rootView() -> some View {
        NavigationStack(path: .constant(navigationPath)) {
            view(for: .main)
                .navigationDestination(for: TouchGrassRoute.self) { route in
                    self.view(for: route)
                }
        }
    }
    
    @ViewBuilder
    func view(for route: TouchGrassRoute) -> some View {
        switch route {
        case .main:
            TouchGrassView(viewModel: TouchGrassViewModel(serviceContainer: self.serviceContainer))
                .environmentObject(self)
        case .appSelection:
            EmptyView() // Handled by FamilyActivityPicker
        case .cameraCapture:
            EmptyView() // Handled by ImagePicker
        case .unlockSuccess:
            UnlockSuccessView()
                .environmentObject(self)
        case .settings:
            TouchGrassSettingsView()
                .environmentObject(self)
        }
    }
}

enum TouchGrassRoute: Hashable {
    case main
    case appSelection
    case cameraCapture
    case unlockSuccess(confidence: Int)
    case settings
}

// MARK: - Success View
struct UnlockSuccessView: View {
    @EnvironmentObject var coordinator: TouchGrassCoordinator
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("解锁成功！")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("应用已解锁1小时")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Button(action: {
                coordinator.navigate(to: .main)
            }) {
                Text("完成")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - Settings View
struct TouchGrassSettingsView: View {
    @EnvironmentObject var coordinator: TouchGrassCoordinator
    @AppStorage("unlockDuration") private var unlockDuration: Double = 3600
    @AppStorage("requireHighConfidence") private var requireHighConfidence = true
    @AppStorage("enableSunsetCheck") private var enableSunsetCheck = true
    
    var body: some View {
        Form {
            Section("解锁设置") {
                VStack(alignment: .leading) {
                    Text("解锁时长")
                    HStack {
                        Text("\(Int(unlockDuration / 60)) 分钟")
                            .foregroundColor(.secondary)
                        Spacer()
                        Slider(value: $unlockDuration, in: 300...7200, step: 300)
                    }
                }
                
                Toggle("需要高置信度", isOn: $requireHighConfidence)
                Toggle("启用日落检查", isOn: $enableSunsetCheck)
            }
            
            Section("关于") {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("TouchGrass 设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}