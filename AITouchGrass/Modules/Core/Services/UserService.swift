//
//  UserService.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import Foundation
import SwiftData
import Combine

/// Service for managing user data
@MainActor
final class UserService: ServiceProtocol {
    nonisolated static let identifier = "UserService"
    
    // MARK: - Properties
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    @Published var currentUser: User?
    
    // MARK: - Initialization
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    // MARK: - Public Methods
    func getCurrentUser() async throws -> User {
        // Check if user exists
        let descriptor = FetchDescriptor<User>()
        let users = try modelContext.fetch(descriptor)
        
        if let existingUser = users.first {
            currentUser = existingUser
            return existingUser
        }
        
        // Create default user if none exists
        let newUser = User(name: "用户", email: nil)
        modelContext.insert(newUser)
        try modelContext.save()
        currentUser = newUser
        return newUser
    }
    
    func updateUser(_ user: User) async throws {
        currentUser = user
        try modelContext.save()
    }
    
    private func oldGetCurrentUser() async throws -> User {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<User>()
        let users = try context.fetch(descriptor)
        
        if let user = users.first {
            return user
        } else {
            // Create default user if none exists
            let newUser = User(name: "Guest User")
            context.insert(newUser)
            try context.save()
            
            return newUser
        }
    }
    
}