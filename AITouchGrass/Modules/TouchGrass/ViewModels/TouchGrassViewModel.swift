import Foundation
import Combine
import UIKit
import CoreLocation
import FamilyControls

@MainActor
final class TouchGrassViewModel: ViewModelProtocol {
    // MARK: - Properties
    @Published var isBlocking = false
    @Published var isVerifying = false
    @Published var lastVerificationResult: NatureDetectionResult?
    @Published var remainingUnlockTime: TimeInterval?
    @Published var showingAppPicker = false
    @Published var showingCamera = false
    @Published var errorMessage: String?
    @Published var selectedNatureType: NatureType = .grass
    @Published var enabledNatureTypes: Set<NatureType> = [.grass, .sky] // 默认启用草地和天空
    @Published var isAuthorized = false
    @Published var selectedApps: Set<AppInfo> = []
    
    // Check if using mock service
    var isUsingMockService: Bool {
        return appBlockingService is MockAppBlockingService
    }
    
    // Check if using real service
    var isUsingRealService: Bool {
        return appBlockingService is RealAppBlockingService
    }
    
    private let serviceContainer: ServiceContainer
    private let grassDetectionService: SimpleGrassDetectionService
    private let appBlockingService: any AppBlockingServiceProtocol
    private let locationService: LocationService
    
    private var cancellables = Set<AnyCancellable>()
    private var unlockTimer: Timer?
    
    weak var coordinator: TouchGrassCoordinator?
    
    // MARK: - Input/Output
    struct Input {
        let toggleBlocking: AnyPublisher<Void, Never>
        let selectApps: AnyPublisher<Void, Never>
        let verifyGrass: AnyPublisher<UIImage, Never>
    }
    
    struct Output {
        let blockingStateChanged: AnyPublisher<Bool, Never>
        let verificationResult: AnyPublisher<NatureDetectionResult, Never>
        let unlockTimeUpdated: AnyPublisher<TimeInterval?, Never>
        let errorOccurred: AnyPublisher<String, Never>
    }
    
    // MARK: - Initialization
    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
        self.grassDetectionService = serviceContainer.resolve(SimpleGrassDetectionService.self)!
        self.appBlockingService = serviceContainer.appBlockingService
        self.locationService = serviceContainer.resolve(LocationService.self)!
        
        setupBindings()
        startUnlockTimer()
    }
    
    // MARK: - Public Methods
    func requestAuthorization() {
        appBlockingService.configure()
    }
    
    func requestScreenTimeAuthorization() async {
        print("DEBUG: Requesting Screen Time authorization...")
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await appBlockingService.checkAuthorization()
            
            if appBlockingService.isAuthorized {
                print("DEBUG: Screen Time authorization granted")
                errorMessage = nil
                isAuthorized = true
            } else {
                print("DEBUG: Screen Time authorization denied")
                errorMessage = "请在设置 > 屏幕使用时间 > 内容和隐私访问限制中允许此应用的权限"
                isAuthorized = false
            }
        } catch {
            print("DEBUG: Screen Time authorization error: \(error)")
            let nsError = error as NSError
            if nsError.code == 4099 {
                errorMessage = "权限请求失败：请确保:\n1. 在真机上运行\n2. 开发者账号配置正确\n3. 应用已正确签名\n\n请尝试重新构建并安装应用"
            } else {
                errorMessage = "授权失败：\(error.localizedDescription)"
            }
            isAuthorized = false
        }
    }
    
    func transform(input: Input) -> Output {
        // Handle toggle blocking
        input.toggleBlocking
            .sink { [weak self] in
                self?.toggleBlocking()
            }
            .store(in: &cancellables)
        
        // Handle select apps
        input.selectApps
            .sink { [weak self] in
                self?.showingAppPicker = true
            }
            .store(in: &cancellables)
        
        // Handle grass verification
        input.verifyGrass
            .sink { [weak self] image in
                Task {
                    await self?.verifyGrassImage(image)
                }
            }
            .store(in: &cancellables)
        
        
        // Create output
        let blockingStateChanged = $isBlocking
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        let verificationResult = $lastVerificationResult
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        let unlockTimeUpdated = $remainingUnlockTime
            .eraseToAnyPublisher()
        
        let errorOccurred = $errorMessage
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        return Output(
            blockingStateChanged: blockingStateChanged,
            verificationResult: verificationResult,
            unlockTimeUpdated: unlockTimeUpdated,
            errorOccurred: errorOccurred
        )
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Sync blocking state
        appBlockingService.isBlockingPublisher
            .assign(to: &$isBlocking)
        
        // Sync authorization state
        appBlockingService.isAuthorizedPublisher
            .assign(to: &$isAuthorized)
    }
    
    private func startUnlockTimer() {
        unlockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateRemainingUnlockTime()
            }
        }
    }
    
    private func updateRemainingUnlockTime() {
        // This is now handled by the timer in startTemporaryUnlockTimer
        // No need to check with the service
    }
    
    private func toggleBlocking() {
        print("DEBUG: toggleBlocking called, current isBlocking: \(isBlocking)")
        
        // 检查授权状态
        if !appBlockingService.isAuthorized {
            print("DEBUG: Not authorized, requesting authorization")
            // 直接请求授权，不显示错误
            Task {
                await requestAuthorizationAndToggle()
            }
            return
        }
        
        if isBlocking {
            print("DEBUG: Stopping blocking")
            appBlockingService.stopBlocking()
        } else {
            // Check if apps are selected
            var hasAppsSelected = false
            
            if isUsingRealService {
                hasAppsSelected = !selectedApps.isEmpty
            } else {
                hasAppsSelected = !appBlockingService.selection.applicationTokens.isEmpty
            }
            
            if !hasAppsSelected {
                print("DEBUG: No apps selected")
                errorMessage = "请先选择要锁定的应用"
                return
            }
            
            let appCount = isUsingRealService ? selectedApps.count : appBlockingService.selection.applicationTokens.count
            print("DEBUG: Starting blocking with \(appCount) apps")
            appBlockingService.startBlocking()
        }
    }
    
    private func verifyGrassImage(_ image: UIImage) async {
        print("DEBUG: verifyGrassImage called")
        isVerifying = true
        defer { 
            print("DEBUG: verifyGrassImage finished")
            isVerifying = false 
        }
        
        do {
            print("DEBUG: Starting nature detection for \(selectedNatureType.rawValue)")
            
            // Check if selected nature type requires daylight
            if selectedNatureType == .grass || selectedNatureType == .sand {
                if let location = locationService.currentLocation {
                    let isDaytime = checkIfDaytime(at: location)
                    if !isDaytime && selectedNatureType == .grass {
                        print("DEBUG: Nighttime detection failed")
                        throw NatureDetectionError.lowConfidence
                    }
                }
            }
            
            // Detect nature in the image
            print("DEBUG: Calling grassDetectionService.detectNature")
            let result = try await grassDetectionService.detectNature(type: selectedNatureType, in: image)
            print("DEBUG: Detection result - isValid: \(result.isValid), confidence: \(result.confidence)")
            
            lastVerificationResult = result
            
            if result.isValid {
                print("DEBUG: Valid detection - unlocking apps")
                // Unlock apps for 1 hour
                if let realService = appBlockingService as? RealAppBlockingService {
                    realService.temporaryUnlock(for: 3600)
                } else {
                    appBlockingService.stopBlocking()
                }
                remainingUnlockTime = 3600
                startTemporaryUnlockTimer()
                print("DEBUG: Calling coordinator.showUnlockSuccess")
                coordinator?.showUnlockSuccess(confidence: result.confidence)
            } else {
                print("DEBUG: Low confidence detection")
                // 延迟显示错误，避免UI冲突
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.errorMessage = "未检测到真实的\(self.selectedNatureType.rawValue)，请重试"
                }
            }
        } catch {
            print("DEBUG: Error in verifyGrassImage: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    private func checkIfDaytime(at location: CLLocation) -> Bool {
        // Simple daytime check based on hour (6 AM to 8 PM)
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 6 && hour <= 20
    }
    
    private func startTemporaryUnlockTimer() {
        unlockTimer?.invalidate()
        unlockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if let remaining = self.remainingUnlockTime, remaining > 0 {
                    self.remainingUnlockTime = remaining - 1
                    if remaining <= 1 {
                        // Re-enable blocking
                        self.appBlockingService.startBlocking()
                        self.remainingUnlockTime = nil
                    }
                }
            }
        }
    }
    
    func updateBlockedAppsFromFamilySelection(_ selection: FamilyActivitySelection) {
        // Update the service's selection
        appBlockingService.updateSelection(selection)
        if isBlocking {
            appBlockingService.startBlocking()
        }
    }
    
    func updateBlockedApps(_ apps: Set<AppInfo>) {
        // Store the selected apps
        selectedApps = apps
        
        // For the RealAppBlockingService, we can pass the apps directly
        if let realService = appBlockingService as? RealAppBlockingService {
            realService.updateSelectedApps(apps)
            print("Selected \(apps.count) apps for blocking")
        } else {
            // Fallback for other services
            let selection = FamilyActivitySelection()
            appBlockingService.updateSelection(selection)
            if isBlocking {
                appBlockingService.startBlocking()
            }
        }
    }
    
    private func requestAuthorizationAndToggle() async {
        print("DEBUG: Requesting authorization...")
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await appBlockingService.checkAuthorization()
            
            // 授权成功后，再次尝试切换
            if appBlockingService.isAuthorized {
                print("DEBUG: Authorization successful, toggling blocking")
                toggleBlocking()
            } else {
                print("DEBUG: Authorization denied")
                errorMessage = "需要在设置中允许屏幕使用时间权限"
            }
        } catch {
            print("DEBUG: Authorization error: \(error)")
            errorMessage = "授权失败：\(error.localizedDescription)"
        }
    }
}