//
//  ProfileView.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI
import Combine
import PhotosUI

struct ProfileView: View {
    // MARK: - Properties
    @StateObject var viewModel: ProfileViewModel
    @State private var loadProfileSubject = PassthroughSubject<Void, Never>()
    @State private var editProfileSubject = PassthroughSubject<Void, Never>()
    @State private var saveProfileSubject = PassthroughSubject<User, Never>()
    @State private var changeAvatarSubject = PassthroughSubject<Void, Never>()
    @State private var navigateToSettingsSubject = PassthroughSubject<Void, Never>()
    @State private var navigateToAchievementsSubject = PassthroughSubject<Void, Never>()
    @State private var navigateToGoalsSubject = PassthroughSubject<Void, Never>()
    
    @State private var output: ProfileViewModel.Output?
    @State private var cancellables = Set<AnyCancellable>()
    
    // Edit mode properties
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""
    @State private var editedHeight: String = ""
    @State private var editedWeight: String = ""
    @State private var editedGender: Gender?
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    @EnvironmentObject var coordinator: ProfileCoordinator
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        profileHeaderSection
                        
                        // Stats Section
                        statsSection
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Recent Activities Preview
                        recentActivitiesSection
                    }
                    .padding(.vertical)
                }
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .navigationTitle("个人资料")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editProfileSubject.send()
                    }) {
                        Text("编辑")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isEditingProfile) {
            editProfileSheet
        }
        .photosPicker(
            isPresented: $viewModel.showImagePicker,
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .alert(item: $viewModel.alertConfig) { config in
            Alert(
                title: Text(config.title),
                message: config.message.map { Text($0) },
                primaryButton: config.primaryAction.map { action in
                    .default(
                        Text(action.title),
                        action: action.action
                    )
                } ?? .default(Text("确定")),
                secondaryButton: config.secondaryAction.map { action in
                    .cancel(Text(action.title), action: action.action)
                } ?? .cancel()
            )
        }
        .onAppear {
            setupBindings()
            loadProfileSubject.send()
        }
        .onChange(of: selectedPhotoItem) {
            Task {
                if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.selectedImage = image
                }
            }
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                if let avatarData = viewModel.user?.avatarData,
                   let image = UIImage(data: avatarData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.accentColor)
                        )
                }
            }
            .overlay(
                Circle()
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            
            // User Info
            VStack(spacing: 8) {
                Text(viewModel.user?.name ?? "用户")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let email = viewModel.user?.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Member Since
                if let joinDate = viewModel.user?.dateJoined {
                    Text("加入于 \(joinDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("运动统计")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ProfileStatCard(
                    title: "总活动",
                    value: "\(viewModel.profileStats.totalActivities)",
                    icon: "figure.run",
                    color: Color.blue
                )
                
                ProfileStatCard(
                    title: "总距离",
                    value: viewModel.profileStats.formattedDistance,
                    icon: "location.fill",
                    color: .green
                )
                
                ProfileStatCard(
                    title: "总时长",
                    value: viewModel.profileStats.formattedTime,
                    icon: "clock.fill",
                    color: .orange
                )
                
                ProfileStatCard(
                    title: "连续天数",
                    value: "\(viewModel.profileStats.currentStreak) 天",
                    icon: "flame.fill",
                    color: .red
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("快捷操作")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ActionRow(
                    title: "目标设置",
                    icon: "target",
                    color: .purple
                ) {
                    navigateToGoalsSubject.send()
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ActionRow(
                    title: "成就",
                    icon: "trophy.fill",
                    color: .yellow
                ) {
                    navigateToAchievementsSubject.send()
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ActionRow(
                    title: "设置",
                    icon: "gearshape.fill",
                    color: .gray
                ) {
                    navigateToSettingsSubject.send()
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Recent Activities Section
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("最近活动")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // Navigate to activities
                }) {
                    Text("查看全部")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal)
            
            // Placeholder for recent activities
            VStack(spacing: 12) {
                ForEach(0..<3) { _ in
                    HStack {
                        Image(systemName: "figure.walk")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                            .frame(width: 40, height: 40)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("晨间步行")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("今天 上午 8:00")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("2.5 公里")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("30 分钟")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Edit Profile Sheet
    private var editProfileSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    HStack {
                        Text("头像")
                        Spacer()
                        Button(action: {
                            changeAvatarSubject.send()
                        }) {
                            if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else if let avatarData = viewModel.user?.avatarData,
                                      let image = UIImage(data: avatarData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    
                    TextField("姓名", text: $editedName)
                    TextField("邮箱", text: $editedEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("身体信息")) {
                    Picker("性别", selection: $editedGender) {
                        Text("未设置").tag(nil as Gender?)
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.displayName).tag(gender as Gender?)
                        }
                    }
                    
                    HStack {
                        Text("身高")
                        TextField("厘米", text: $editedHeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("体重")
                        TextField("公斤", text: $editedWeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        viewModel.isEditingProfile = false
                        viewModel.selectedImage = nil
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            setupEditMode()
        }
    }
    
    // MARK: - Helper Methods
    private func setupBindings() {
        viewModel.coordinator = coordinator
        
        let input = ProfileViewModel.Input(
            loadProfile: loadProfileSubject.eraseToAnyPublisher(),
            editProfile: editProfileSubject.eraseToAnyPublisher(),
            saveProfile: saveProfileSubject.eraseToAnyPublisher(),
            changeAvatar: changeAvatarSubject.eraseToAnyPublisher(),
            navigateToSettings: navigateToSettingsSubject.eraseToAnyPublisher(),
            navigateToAchievements: navigateToAchievementsSubject.eraseToAnyPublisher(),
            navigateToGoals: navigateToGoalsSubject.eraseToAnyPublisher()
        )
        
        output = viewModel.transform(input: input)
    }
    
    private func setupEditMode() {
        guard let user = viewModel.user else { return }
        editedName = user.name
        editedEmail = user.email ?? ""
        editedHeight = user.height.map { String(format: "%.0f", $0) } ?? ""
        editedWeight = user.weight.map { String(format: "%.1f", $0) } ?? ""
        editedGender = user.gender
    }
    
    private func saveProfile() {
        guard let user = viewModel.user else { return }
        
        user.name = editedName
        user.email = editedEmail.isEmpty ? nil : editedEmail
        user.height = Double(editedHeight)
        user.weight = Double(editedWeight)
        user.gender = editedGender
        
        saveProfileSubject.send(user)
    }
}

// MARK: - Supporting Views
struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ActionRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}


// MARK: - Preview
#Preview {
    ProfileView(
        viewModel: ProfileViewModel(serviceContainer: ServiceContainer.shared)
    )
    .environmentObject(ProfileCoordinator(serviceContainer: ServiceContainer.shared))
}