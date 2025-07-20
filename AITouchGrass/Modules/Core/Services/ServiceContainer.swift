//
//  ServiceContainer.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import SwiftData
import FamilyControls
import ManagedSettings

/// Dependency injection container for services
@MainActor
final class ServiceContainer {
    // Shared instance
    static let shared = ServiceContainer()
    
    // Model container
    let modelContainer: ModelContainer
    
    // Services
    lazy var activityService: ActivityService = {
        ActivityService(modelContainer: modelContainer)
    }()
    
    lazy var userService: UserService = {
        UserService(modelContainer: modelContainer)
    }()
    
    lazy var statisticsService: StatisticsService = {
        StatisticsService(activityService: activityService)
    }()
    
    lazy var locationService: LocationService = {
        LocationService()
    }()
    
    lazy var healthKitService: HealthKitService = {
        HealthKitService()
    }()
    
    lazy var grassDetectionService: SimpleGrassDetectionService = {
        SimpleGrassDetectionService()
    }()
    
    lazy var appBlockingService: any ServiceProtocol & AppBlockingServiceProtocol = {
        // Check if we should use the proper Screen Time API service
        if shouldUseScreenTimeAPI() {
            print("📱 Using ScreenTimeAppBlockingService with proper Screen Time API")
            return ScreenTimeAppBlockingService(modelContainer: modelContainer)
        } else {
            // Fall back to the simulated blocking service
            print("🔒 Using RealAppBlockingService for simulated app management")
            return RealAppBlockingService(modelContainer: modelContainer)
        }
    }()
    
    private func shouldUseScreenTimeAPI() -> Bool {
        // Check if Family Controls is available
        #if targetEnvironment(simulator)
        print("🤖 Running on simulator - Screen Time API not available")
        return false
        #else
        // On real device, check if we have proper entitlements
        return checkScreenTimeAPIAvailability()
        #endif
    }
    
    private func checkScreenTimeAPIAvailability() -> Bool {
        guard #available(iOS 16.0, *) else {
            print("⚠️ Screen Time API requires iOS 16.0 or later")
            return false
        }
        
        // Check authorization status
        let authStatus = AuthorizationCenter.shared.authorizationStatus
        print("📱 Screen Time API authorization status: \(authStatus)")
        
        // If already approved, use Screen Time API
        if authStatus == .approved {
            print("✅ Screen Time API is authorized")
            return true
        }
        
        // IMPORTANT: Screen Time API requires special entitlements from Apple
        // The "com.apple.FamilyControlsAgent" sandbox restriction error means
        // our app doesn't have the required Family Controls entitlement yet
        
        // Touch Grass app works because they have obtained this special permission
        // For now, we'll use the alternative implementation
        
        print("⚠️ Screen Time API requires Family Controls entitlement from Apple")
        print("⚠️ Touch Grass app has this special permission, which is why it works")
        print("📱 Using alternative implementation with notifications instead")
        
        // Return false to use RealAppBlockingService instead
        return false
    }
    
    private func isFamilyControlsAvailable() -> Bool {
        // Based on testing, Family Controls API requires special Apple entitlements
        // Even on real devices, it will fail with sandbox restrictions
        // For now, always use mock service to ensure app functionality
        
        #if targetEnvironment(simulator)
        print("🤖 Running on simulator - using mock service")
        return false
        #else
        // For now, always use mock service on device too
        // Until we get proper Family Controls entitlements from Apple
        print("📱 Running on device - using mock service (Family Controls requires special Apple approval)")
        return false
        
        // TODO: Uncomment this when/if we get Family Controls entitlements
        // return checkFamilyControlsAccess()
        #endif
    }
    
    private func checkFamilyControlsAccess() -> Bool {
        // Try to access Family Controls to see if it's available
        guard #available(iOS 16.0, *) else {
            print("⚠️ Family Controls requires iOS 16.0 or later")
            return false
        }
        
        // Based on the error logs, we know that even on device, 
        // Family Controls APIs will fail with sandbox restrictions
        // unless the app has special entitlements from Apple
        
        // Try to access AuthorizationCenter
        let authStatus = AuthorizationCenter.shared.authorizationStatus
        print("🔍 Family Controls authorization status: \(authStatus)")
        
        // Try to create ManagedSettingsStore  
        let _ = ManagedSettingsStore()
        print("✅ ManagedSettingsStore created successfully")
        
        // The real test: try to make a synchronous authorization request
        // If this fails with sandbox restriction, Family Controls is not available
        let dispatchGroup = DispatchGroup()
        var authorizationSucceeded = false
        
        dispatchGroup.enter()
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                authorizationSucceeded = true
                print("✅ Authorization request succeeded")
            } catch {
                print("⚠️ Authorization request failed: \(error)")
                authorizationSucceeded = false
            }
            dispatchGroup.leave()
        }
        
        // Wait for the async operation to complete (with timeout)
        let result = dispatchGroup.wait(timeout: .now() + 2.0)
        
        if result == .timedOut {
            print("⚠️ Authorization request timed out")
            return false
        }
        
        return authorizationSucceeded
    }
    
    private init() {
        // Initialize model container
        let schema = Schema([
            Activity.self,
            User.self,
            ActivitySession.self,
            AppUsage.self,
            AppBlockingSession.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    /// Get service by type
    func service<T>(_ type: T.Type) -> T? {
        switch type {
        case is ActivityService.Type:
            return activityService as? T
        case is UserService.Type:
            return userService as? T
        case is StatisticsService.Type:
            return statisticsService as? T
        case is LocationService.Type:
            return locationService as? T
        case is HealthKitService.Type:
            return healthKitService as? T
        case is SimpleGrassDetectionService.Type:
            return grassDetectionService as? T
        case is any AppBlockingServiceProtocol.Type:
            return appBlockingService as? T
        default:
            return nil
        }
    }
    
    /// Resolve service by type (convenience method)
    func resolve<T>(_ type: T.Type) -> T? {
        return service(type)
    }
}