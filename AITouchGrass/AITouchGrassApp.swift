//
//  AITouchGrassApp.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI
import SwiftData

@main
struct AITouchGrassApp: App {
    // Service container
    @MainActor
    private let serviceContainer = ServiceContainer.shared
    
    // App coordinator
    @StateObject private var appCoordinator: AppCoordinator
    @State private var showLaunchScreen = true
    
    @MainActor
    init() {
        // Initialize app coordinator
        let coordinator = AppCoordinator(serviceContainer: ServiceContainer.shared)
        _appCoordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else {
                AppRootView(coordinator: appCoordinator)
                    .transition(.opacity)
            }
        }
        .modelContainer(serviceContainer.modelContainer)
    }
}
