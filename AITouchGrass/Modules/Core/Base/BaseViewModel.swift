//
//  BaseViewModel.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import Combine

/// Base class for all ViewModels
@MainActor
class BaseViewModel: ObservableObject {
    /// Set for storing cancellables
    var cancellables = Set<AnyCancellable>()
    
    /// Loading state
    @Published var isLoading = false
    
    /// Error state
    @Published var error: Error?
    
    /// Alert configuration
    @Published var alertConfig: AlertConfiguration?
    
    init() {
        setupBindings()
    }
    
    /// Override this method to setup bindings
    func setupBindings() {
        // Override in subclasses
    }
    
    /// Show loading indicator
    func showLoading() {
        isLoading = true
    }
    
    /// Hide loading indicator
    func hideLoading() {
        isLoading = false
    }
    
    /// Handle error
    func handleError(_ error: Error) {
        self.error = error
        self.isLoading = false
        showErrorAlert(error)
    }
    
    /// Show error alert
    private func showErrorAlert(_ error: Error) {
        alertConfig = AlertConfiguration(
            title: "Error",
            message: error.localizedDescription,
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
    
    /// Clear error
    func clearError() {
        error = nil
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}