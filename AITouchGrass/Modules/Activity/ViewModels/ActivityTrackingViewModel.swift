//
//  ActivityTrackingViewModel.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import Combine
import CoreLocation

/// Activity tracking view model
final class ActivityTrackingViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var currentActivity: Activity?
    @Published var currentSession: ActivitySession?
    @Published var elapsedTime: TimeInterval = 0
    @Published var distance: Double = 0
    @Published var currentSpeed: Double = 0
    @Published var averageSpeed: Double = 0
    @Published var calories: Double = 0
    @Published var isPaused = false
    @Published var locations: [LocationCoordinate] = []
    
    // MARK: - Services
    private let activityService: ActivityService
    private let locationService: LocationService
    private let healthKitService: HealthKitService
    
    // MARK: - Coordinator
    weak var coordinator: ActivityCoordinator?
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    
    // MARK: - Input/Output
    struct Input {
        let startActivity: AnyPublisher<ActivityType, Never>
        let pauseResume: AnyPublisher<Void, Never>
        let stopActivity: AnyPublisher<Void, Never>
        let saveActivity: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let elapsedTime: AnyPublisher<String, Never>
        let distance: AnyPublisher<String, Never>
        let speed: AnyPublisher<String, Never>
        let calories: AnyPublisher<String, Never>
    }
    
    // MARK: - Initialization
    init(
        activity: Activity,
        serviceContainer: ServiceContainer
    ) {
        self.currentActivity = activity
        self.activityService = serviceContainer.activityService
        self.locationService = serviceContainer.locationService
        self.healthKitService = serviceContainer.healthKitService
        super.init()
    }
    
    init(
        activityService: ActivityService,
        locationService: LocationService,
        healthKitService: HealthKitService
    ) {
        self.activityService = activityService
        self.locationService = locationService
        self.healthKitService = healthKitService
        super.init()
    }
    
    // MARK: - Setup
    override func setupBindings() {
        // Location updates
        // Subscribe to location updates when LocationService is properly configured
        // locationService.$currentLocation
        //     .compactMap { $0 }
        //     .sink { [weak self] location in
        //         self?.handleLocationUpdate(location)
        //     }
        //     .store(in: &cancellables)
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        // Start activity
        input.startActivity
            .sink { [weak self] type in
                self?.startActivity(type: type)
            }
            .store(in: &cancellables)
        
        // Pause/Resume
        input.pauseResume
            .sink { [weak self] _ in
                self?.togglePauseResume()
            }
            .store(in: &cancellables)
        
        // Stop activity
        input.stopActivity
            .sink { [weak self] _ in
                self?.stopActivity()
            }
            .store(in: &cancellables)
        
        // Save activity
        input.saveActivity
            .sink { [weak self] _ in
                Task {
                    await self?.saveActivity()
                }
            }
            .store(in: &cancellables)
        
        // Format outputs
        let timeOutput = $elapsedTime
            .map { [weak self] time in
                self?.formatTime(time) ?? "00:00"
            }
            .eraseToAnyPublisher()
        
        let distanceOutput = $distance
            .map { distance in
                String(format: "%.2f km", distance / 1000)
            }
            .eraseToAnyPublisher()
        
        let speedOutput = $currentSpeed
            .map { speed in
                String(format: "%.1f km/h", speed * 3.6)
            }
            .eraseToAnyPublisher()
        
        let caloriesOutput = $calories
            .map { calories in
                String(format: "%.0f kcal", calories)
            }
            .eraseToAnyPublisher()
        
        return Output(
            elapsedTime: timeOutput,
            distance: distanceOutput,
            speed: speedOutput,
            calories: caloriesOutput
        )
    }
    
    // MARK: - Activity Control
    private func startActivity(type: ActivityType) {
        // Create new activity
        let activity = Activity(
            name: "\(type.rawValue) Activity",
            type: type
        )
        currentActivity = activity
        
        // Create session
        let session = ActivitySession()
        currentSession = session
        
        // Start tracking
        startTime = Date()
        isPaused = false
        startTimer()
        // locationService.startTracking() // TODO: Implement in LocationService
        
        // Request HealthKit permission if needed
        Task {
            try? await healthKitService.requestAuthorization()
        }
    }
    
    private func togglePauseResume() {
        isPaused.toggle()
        
        if isPaused {
            pauseTimer()
            // locationService.pauseTracking() // TODO: Implement in LocationService
            currentSession?.isActive = false
        } else {
            resumeTimer()
            // locationService.resumeTracking() // TODO: Implement in LocationService
            currentSession?.isActive = true
        }
    }
    
    private func stopActivity() {
        // Stop tracking
        stopTimer()
        // locationService.stopTracking() // TODO: Implement in LocationService
        
        // Update session
        currentSession?.endTime = Date()
        
        // Show save dialog
        coordinator?.showSaveActivity()
    }
    
    private func saveActivity() async {
        guard let activity = currentActivity,
              let session = currentSession else { return }
        
        showLoading()
        
        // Update activity data
        activity.duration = elapsedTime
        activity.distance = distance
        activity.calories = calories
        // activity.route = locations // TODO: Add route property to Activity if needed
        activity.sessions = [session]
        
        // Save to database
        // try await activityService.save(activity) // TODO: Implement save method in ActivityService
        
        // Save to HealthKit
        if healthKitService.isAuthorized {
            try? await healthKitService.saveActivity(activity: activity)
        }
        
        await MainActor.run {
            hideLoading()
            coordinator?.activitySaved(activity)
        }
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateElapsedTime()
            }
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resumeTimer() {
        startTimer()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime) - pausedTime
        updateCalories()
    }
    
    // MARK: - Location Updates
    private func handleLocationUpdate(_ location: CLLocation) {
        // Add to route
        let coordinate = LocationCoordinate(from: location)
        locations.append(coordinate)
        
        // Update speed
        currentSpeed = max(0, location.speed)
        
        // Update distance
        if let lastLocation = locations.dropLast().last {
            let lastCLLocation = CLLocation(
                latitude: lastLocation.latitude,
                longitude: lastLocation.longitude
            )
            let distanceDelta = location.distance(from: lastCLLocation)
            distance += distanceDelta
        }
        
        // Update average speed
        if elapsedTime > 0 {
            averageSpeed = distance / elapsedTime
        }
    }
    
    // MARK: - Calculations
    private func updateCalories() {
        guard let activity = currentActivity else { return }
        let minutes = elapsedTime / 60
        calories = minutes * activity.type.defaultCaloriesPerMinute
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}