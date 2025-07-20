//
//  ServiceProtocol.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import Combine

/// Base protocol for all services
protocol ServiceProtocol {
    /// Service identifier
    nonisolated static var identifier: String { get }
}

/// Protocol for services that manage data
protocol DataServiceProtocol: ServiceProtocol {
    associatedtype DataType
    
    /// Fetch data
    func fetch() async throws -> DataType
    
    /// Save data
    func save(_ data: DataType) async throws
    
    /// Delete data
    func delete(_ id: String) async throws
}

/// Protocol for services that provide real-time updates
protocol ObservableServiceProtocol: ServiceProtocol {
    associatedtype UpdateType
    
    /// Publisher for service updates
    var updates: AnyPublisher<UpdateType, Never> { get }
}

/// Protocol for services that require authentication
protocol AuthenticatedServiceProtocol: ServiceProtocol {
    /// Check if service is authenticated
    var isAuthenticated: Bool { get }
    
    /// Authenticate the service
    func authenticate() async throws
    
    /// Sign out from the service
    func signOut() async throws
}