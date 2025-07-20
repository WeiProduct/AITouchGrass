//
//  CoordinatorProtocol.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI

/// Base protocol for navigation coordinators
protocol CoordinatorProtocol: ObservableObject {
    associatedtype Route
    
    /// Current navigation path
    var navigationPath: NavigationPath { get set }
    
    /// Navigate to a specific route
    func navigate(to route: Route)
    
    /// Pop current view
    func popView()
    
    /// Pop to root view
    func popToRoot()
}

/// Protocol for coordinators that can present sheets
protocol SheetPresentable: CoordinatorProtocol {
    associatedtype SheetRoute
    
    /// Currently presented sheet
    var presentedSheet: SheetRoute? { get set }
    
    /// Present a sheet
    func presentSheet(_ sheet: SheetRoute)
    
    /// Dismiss current sheet
    func dismissSheet()
}

/// Protocol for coordinators that can present alerts
protocol AlertPresentable: CoordinatorProtocol {
    /// Alert configuration
    var alertConfig: AlertConfiguration? { get set }
    
    /// Show an alert
    func showAlert(_ config: AlertConfiguration)
    
    /// Dismiss current alert
    func dismissAlert()
}

/// Alert configuration model
struct AlertConfiguration: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    let primaryAction: AlertAction?
    let secondaryAction: AlertAction?
}

struct AlertAction {
    let title: String
    let role: ButtonRole?
    let action: () -> Void
}