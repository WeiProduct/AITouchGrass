//
//  BaseCoordinator.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI
import Combine

/// Base coordinator class
@MainActor
class BaseCoordinator: ObservableObject {
    /// Navigation path
    @Published var navigationPath = NavigationPath()
    
    /// Presented sheet
    @Published var presentedSheet: AnyHashable?
    
    /// Alert configuration
    @Published var alertConfig: AlertConfiguration?
    
    /// Cancellables
    var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    /// Setup bindings - override in subclasses
    func setupBindings() {
        // Override in subclasses
    }
    
    /// Pop current view
    func popView() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    /// Pop to root view
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    /// Dismiss current sheet
    func dismissSheet() {
        presentedSheet = nil
    }
    
    /// Show alert
    func showAlert(_ config: AlertConfiguration) {
        alertConfig = config
    }
    
    /// Dismiss alert
    func dismissAlert() {
        alertConfig = nil
    }
}