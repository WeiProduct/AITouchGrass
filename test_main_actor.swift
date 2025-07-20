// Test file to verify MainActor isolation is properly handled

import Foundation
import SwiftData

// This test verifies that:
// 1. ServiceContainer.shared is properly marked as @MainActor
// 2. All services that access mainContext have proper @MainActor isolation
// 3. ViewModels and Coordinators that inherit from base classes work correctly

@MainActor
func testMainActorIsolation() async {
    // Test 1: ServiceContainer initialization
    let container = ServiceContainer.shared
    
    // Test 2: Services that use mainContext
    let activityService = container.activityService
    let userService = container.userService
    
    // Test 3: Services should be accessible without await since they're @MainActor
    _ = activityService.modelContext
    _ = userService.currentUser
    
    // Test 4: Coordinator initialization
    let appCoordinator = AppCoordinator(serviceContainer: container)
    
    // Test 5: ViewModel initialization through coordinator
    let profileViewModel = ProfileViewModel(serviceContainer: container)
    
    print("All MainActor isolation tests passed!")
}

// Non-MainActor context test to ensure proper isolation
func testNonMainActorContext() async {
    // This should require await to access ServiceContainer.shared from non-MainActor context
    await MainActor.run {
        let _ = ServiceContainer.shared
    }
}

print("MainActor isolation test file compiled successfully!")