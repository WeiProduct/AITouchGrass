//
//  ProfileCoordinator.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI

/// Profile module coordinator
final class ProfileCoordinator: BaseCoordinator {
    // Routes
    enum Route: Hashable {
        case settings
        case achievements
        case goals
        case editProfile
        case privacyPolicy
        case termsOfService
        case about
    }
    
    // Sheet routes
    enum Sheet: Hashable {
        case changePassword
        case deleteAccount
        case exportData
    }
    
    // Dependencies
    private let serviceContainer: ServiceContainer
    
    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
        super.init()
    }
    
    // MARK: - Navigation
    func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    func presentSheet(_ sheet: Sheet) {
        presentedSheet = sheet
    }
    
    // MARK: - Navigation Methods
    func showSettings() {
        navigate(to: .settings)
    }
    
    func showAchievements() {
        navigate(to: .achievements)
    }
    
    func showGoals() {
        navigate(to: .goals)
    }
    
    func showEditProfile() {
        navigate(to: .editProfile)
    }
    
    func showPrivacyPolicy() {
        navigate(to: .privacyPolicy)
    }
    
    func showTermsOfService() {
        navigate(to: .termsOfService)
    }
    
    func showAbout() {
        navigate(to: .about)
    }
    
    // MARK: - View Creation
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .settings:
            SettingsView()
        
        case .achievements:
            AchievementsView()
        
        case .goals:
            GoalsView()
        
        case .editProfile:
            EditProfileDetailView()
        
        case .privacyPolicy:
            PrivacyPolicyView()
        
        case .termsOfService:
            TermsOfServiceView()
        
        case .about:
            AboutView()
        }
    }
    
    @ViewBuilder
    func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .changePassword:
            ChangePasswordView()
        
        case .deleteAccount:
            DeleteAccountView()
        
        case .exportData:
            ExportDataView()
        }
    }
    
    // MARK: - Root View
    func rootView() -> some View {
        ProfileView(viewModel: ProfileViewModel(serviceContainer: self.serviceContainer))
            .environmentObject(self)
    }
}

// MARK: - Placeholder Views
struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}

struct AchievementsView: View {
    var body: some View {
        Text("Achievements")
            .navigationTitle("Achievements")
    }
}

struct GoalsView: View {
    var body: some View {
        Text("Goals")
            .navigationTitle("Goals")
    }
}

struct EditProfileDetailView: View {
    var body: some View {
        Text("Edit Profile")
            .navigationTitle("Edit Profile")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy")
            .navigationTitle("Privacy Policy")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        Text("Terms of Service")
            .navigationTitle("Terms of Service")
    }
}

struct AboutView: View {
    var body: some View {
        Text("About AITouchGrass")
            .navigationTitle("About")
    }
}

struct ChangePasswordView: View {
    var body: some View {
        Text("Change Password")
    }
}

struct DeleteAccountView: View {
    var body: some View {
        Text("Delete Account")
    }
}

struct ExportDataView: View {
    var body: some View {
        Text("Export Data")
    }
}