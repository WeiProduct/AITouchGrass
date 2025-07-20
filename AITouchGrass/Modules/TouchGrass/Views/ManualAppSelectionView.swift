import SwiftUI

struct ManualAppSelectionView: View {
    @Binding var selectedApps: Set<AppInfo>
    @State private var searchText = ""
    @State private var selectedCategory = "全部"
    @Environment(\.dismiss) var dismiss
    
    let categories = ["全部", "社交", "购物", "生活", "出行", "娱乐", "音乐", "金融", "办公", "工具", "游戏"]
    
    // 使用EnhancedAppDetectionService中的所有应用列表
    let allApps: [AppInfo] = {
        EnhancedAppDetectionService.appVariants.map { variant in
            AppInfo(
                name: variant.name,
                bundleId: "app.\(variant.name)",
                category: variant.category,
                systemImage: variant.systemImage
            )
        }
    }()
    
    var filteredApps: [AppInfo] {
        var apps = allApps
        
        // 按类别筛选
        if selectedCategory != "全部" {
            apps = apps.filter { $0.category == selectedCategory }
        }
        
        // 按搜索文本筛选
        if !searchText.isEmpty {
            apps = apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // 按名称排序
        return apps.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("搜索应用", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // 类别选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            ManualAppCategoryChip(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                // 应用列表
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredApps) { app in
                            AppSelectionRow(
                                app: app,
                                isSelected: selectedApps.contains(app),
                                onToggle: {
                                    if selectedApps.contains(app) {
                                        selectedApps.remove(app)
                                    } else {
                                        selectedApps.insert(app)
                                    }
                                }
                            )
                            
                            if app.id != filteredApps.last?.id {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 底部统计栏
                HStack {
                    Text("已选择 \(selectedApps.count) 个应用")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("选择应用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedApps.isEmpty)
                }
            }
        }
    }
}

struct AppSelectionRow: View {
    let app: AppInfo
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // 应用图标
                Image(systemName: app.systemImage)
                    .font(.title2)
                    .foregroundColor(Color(app.category.lowercased()))
                    .frame(width: 40, height: 40)
                    .background(Color(app.category.lowercased()).opacity(0.1))
                    .cornerRadius(8)
                
                // 应用信息
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.body)
                        .foregroundColor(.primary)
                    Text(app.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 选中标记
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .accentColor : Color(.tertiaryLabel))
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ManualAppCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}


struct ManualAppSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ManualAppSelectionView(selectedApps: .constant(Set<AppInfo>()))
    }
}