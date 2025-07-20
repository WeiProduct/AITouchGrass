//
//  ProfileViewModel.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import Combine
import SwiftUI
import UIKit

/// Profile view model
@MainActor
final class ProfileViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var user: User?
    @Published var profileStats: ProfileStats = .empty
    @Published var isEditingProfile = false
    @Published var showImagePicker = false
    @Published var selectedImage: UIImage?
    
    // MARK: - Services
    private let userService: UserService
    private let statisticsService: StatisticsService
    private let activityService: ActivityService
    
    // MARK: - Coordinator
    weak var coordinator: ProfileCoordinator?
    
    // MARK: - Input/Output
    struct Input {
        let loadProfile: AnyPublisher<Void, Never>
        let editProfile: AnyPublisher<Void, Never>
        let saveProfile: AnyPublisher<User, Never>
        let changeAvatar: AnyPublisher<Void, Never>
        let navigateToSettings: AnyPublisher<Void, Never>
        let navigateToAchievements: AnyPublisher<Void, Never>
        let navigateToGoals: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let user: AnyPublisher<User?, Never>
        let stats: AnyPublisher<ProfileStats, Never>
        let isLoading: AnyPublisher<Bool, Never>
    }
    
    // MARK: - Initialization
    init(serviceContainer: ServiceContainer) {
        self.userService = serviceContainer.userService
        self.statisticsService = serviceContainer.statisticsService
        self.activityService = serviceContainer.activityService
        super.init()
    }
    
    // MARK: - Setup
    override func setupBindings() {
        // Load user profile on init
        Task {
            await loadUserProfile()
        }
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        // Load profile
        input.loadProfile
            .sink { [weak self] _ in
                Task {
                    await self?.loadUserProfile()
                }
            }
            .store(in: &cancellables)
        
        // Edit profile
        input.editProfile
            .sink { [weak self] _ in
                self?.isEditingProfile = true
            }
            .store(in: &cancellables)
        
        // Save profile
        input.saveProfile
            .sink { [weak self] user in
                Task {
                    await self?.saveProfile(user)
                }
            }
            .store(in: &cancellables)
        
        // Change avatar
        input.changeAvatar
            .sink { [weak self] _ in
                self?.showImagePicker = true
            }
            .store(in: &cancellables)
        
        // Navigation
        input.navigateToSettings
            .sink { [weak self] _ in
                self?.coordinator?.showSettings()
            }
            .store(in: &cancellables)
        
        input.navigateToAchievements
            .sink { [weak self] _ in
                self?.coordinator?.showAchievements()
            }
            .store(in: &cancellables)
        
        input.navigateToGoals
            .sink { [weak self] _ in
                self?.coordinator?.showGoals()
            }
            .store(in: &cancellables)
        
        return Output(
            user: $user.eraseToAnyPublisher(),
            stats: $profileStats.eraseToAnyPublisher(),
            isLoading: $isLoading.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Private Methods
    private func loadUserProfile() async {
        showLoading()
        
        do {
            // Load user
            let currentUser = try await userService.getCurrentUser()
            
            // Load stats
            async let totalActivities = activityService.getTotalActivitiesCount()
            async let totalDistance = statisticsService.getTotalDistance()
            async let totalTime = statisticsService.getTotalOutdoorTime()
            async let currentStreak = statisticsService.getCurrentStreak()
            
            let stats = try await ProfileStats(
                totalActivities: totalActivities,
                totalDistance: totalDistance,
                totalTime: totalTime,
                currentStreak: currentStreak,
                memberSince: currentUser.dateJoined
            )
            
            await MainActor.run {
                self.user = currentUser
                self.profileStats = stats
                self.hideLoading()
            }
        } catch {
            await MainActor.run {
                self.handleError(error)
            }
        }
    }
    
    private func saveProfile(_ updatedUser: User) async {
        showLoading()
        
        do {
            // Save avatar if changed
            if let image = selectedImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                updatedUser.avatarData = imageData
            }
            
            // Save user
            try await userService.updateUser(updatedUser)
            
            await MainActor.run {
                self.user = updatedUser
                self.isEditingProfile = false
                self.hideLoading()
                
                // Show success message
                self.alertConfig = AlertConfiguration(
                    title: "Success",
                    message: "Profile updated successfully",
                    primaryAction: AlertAction(
                        title: "OK",
                        role: nil,
                        action: { [weak self] in
                            self?.alertConfig = nil
                        }
                    ),
                    secondaryAction: nil
                )
            }
        } catch {
            await MainActor.run {
                self.handleError(error)
            }
        }
    }
}

// MARK: - Profile Stats
struct ProfileStats {
    let totalActivities: Int
    let totalDistance: Double // in meters
    let totalTime: TimeInterval
    let currentStreak: Int
    let memberSince: Date
    
    static var empty: ProfileStats {
        ProfileStats(
            totalActivities: 0,
            totalDistance: 0,
            totalTime: 0,
            currentStreak: 0,
            memberSince: Date()
        )
    }
    
    var formattedDistance: String {
        if totalDistance >= 1000 {
            return String(format: "%.1f km", totalDistance / 1000)
        } else {
            return String(format: "%.0f m", totalDistance)
        }
    }
    
    var formattedTime: String {
        let hours = Int(totalTime) / 3600
        if hours > 0 {
            return "\(hours) hours"
        } else {
            let minutes = Int(totalTime) / 60
            return "\(minutes) minutes"
        }
    }
}