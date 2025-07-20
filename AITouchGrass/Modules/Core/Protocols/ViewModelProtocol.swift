//
//  ViewModelProtocol.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import Combine

/// Base protocol for all ViewModels in the app
@MainActor
protocol ViewModelProtocol: ObservableObject {
    associatedtype Input
    associatedtype Output
    
    /// Transform input events to output
    func transform(input: Input) -> Output
}

/// Protocol for ViewModels that handle loading states
protocol LoadableViewModel: ViewModelProtocol {
    var isLoading: Bool { get set }
    var error: Error? { get set }
}

/// Protocol for ViewModels that need cleanup
protocol DisposableViewModel: ViewModelProtocol {
    func dispose()
}