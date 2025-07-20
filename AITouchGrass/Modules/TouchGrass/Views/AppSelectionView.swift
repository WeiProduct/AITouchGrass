import SwiftUI

struct AppSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedApps: Set<AppInfo> = []
    @State private var searchText = ""
    @State private var detectedApps: [AppInfo] = []
    @State private var isScanning = false
    @StateObject private var appDetector = RealAppDetectionService()
    
    let onAppsSelected: (Set<AppInfo>) -> Void
    
    private let commonApps: [AppInfo] = [
        AppInfo(name: "微信", bundleId: "com.tencent.xin", category: "Social", systemImage: "message.fill"),
        AppInfo(name: "微博", bundleId: "com.sina.weibo", category: "Social", systemImage: "at.circle.fill"),
        AppInfo(name: "抖音", bundleId: "com.ss.iphone.ugc.Aweme", category: "Entertainment", systemImage: "video.fill"),
        AppInfo(name: "快手", bundleId: "com.kuaishou.gif", category: "Entertainment", systemImage: "play.circle.fill"),
        AppInfo(name: "小红书", bundleId: "com.xingin.xhs", category: "Social", systemImage: "book.closed.fill"),
        AppInfo(name: "B站", bundleId: "tv.danmaku.bilibilihd", category: "Entertainment", systemImage: "play.rectangle.fill"),
        AppInfo(name: "知乎", bundleId: "com.zhihu.ios", category: "News", systemImage: "questionmark.circle.fill"),
        AppInfo(name: "淘宝", bundleId: "com.taobao.taobao4iphone", category: "Shopping", systemImage: "bag.fill"),
        AppInfo(name: "京东", bundleId: "com.jingdong.app.mall", category: "Shopping", systemImage: "cart.fill"),
        AppInfo(name: "支付宝", bundleId: "com.alipay.iphoneclient", category: "Finance", systemImage: "creditcard.fill"),
        AppInfo(name: "QQ", bundleId: "com.tencent.qq", category: "Social", systemImage: "message.circle.fill"),
        AppInfo(name: "网易云音乐", bundleId: "com.netease.cloudmusic", category: "Music", systemImage: "music.note"),
        AppInfo(name: "爱奇艺", bundleId: "com.qiyi.iphone", category: "Entertainment", systemImage: "tv.fill"),
        AppInfo(name: "腾讯视频", bundleId: "com.tencent.live4iphone", category: "Entertainment", systemImage: "tv.circle.fill"),
        AppInfo(name: "美团", bundleId: "com.meituan.imeituan", category: "Food", systemImage: "takeoutbag.and.cup.and.straw.fill"),
        AppInfo(name: "饿了么", bundleId: "me.ele.ios.eleme", category: "Food", systemImage: "fork.knife.circle.fill"),
        AppInfo(name: "滴滴出行", bundleId: "com.diditaxi.customer", category: "Travel", systemImage: "car.fill"),
        AppInfo(name: "高德地图", bundleId: "com.autonavi.amap", category: "Navigation", systemImage: "map.fill"),
        AppInfo(name: "百度地图", bundleId: "com.baidu.map", category: "Navigation", systemImage: "location.fill"),
        AppInfo(name: "今日头条", bundleId: "com.ss.iphone.article.News", category: "News", systemImage: "newspaper.fill")
    ]
    
    private var allApps: [AppInfo] {
        // 只显示检测到的已安装应用
        return appDetector.detectedApps
    }
    
    private var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return allApps
        }
        return allApps.filter { app in
            app.name.localizedCaseInsensitiveContains(searchText) ||
            app.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var groupedApps: [String: [AppInfo]] {
        Dictionary(grouping: filteredApps) { $0.category }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Detection Status
                if appDetector.isScanning {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("正在扫描已安装的应用...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                } else if !appDetector.detectedApps.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("检测到 \(appDetector.detectedApps.count) 个已安装应用")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("重新扫描") {
                            Task {
                                // 移除自动扫描
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("未检测到支持的应用")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("可能需要在Info.plist中添加LSApplicationQueriesSchemes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("选择应用") {
                            // 改为手动选择
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()
                }
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("搜索应用", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Selected Apps Counter
                if !selectedApps.isEmpty {
                    HStack {
                        Text("已选择 \(selectedApps.count) 个应用")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("清空") {
                            selectedApps.removeAll()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                // App List
                List {
                    ForEach(groupedApps.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category)) {
                            ForEach(groupedApps[category] ?? [], id: \.id) { app in
                                AppRowView(
                                    app: app,
                                    isSelected: selectedApps.contains(app),
                                    isInstalled: appDetector.detectedApps.contains { $0.bundleId == app.bundleId }
                                ) {
                                    if selectedApps.contains(app) {
                                        selectedApps.remove(app)
                                    } else {
                                        selectedApps.insert(app)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
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
                        onAppsSelected(selectedApps)
                        dismiss()
                    }
                    .disabled(selectedApps.isEmpty)
                }
            }
            .onAppear {
                // 移除自动扫描，改为用户手动选择
            }
        }
    }
}

struct AppRowView: View {
    let app: AppInfo
    let isSelected: Bool
    let isInstalled: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: app.systemImage)
                .font(.title2)
                .foregroundColor(Color(app.category.lowercased()))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(app.name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if isInstalled {
                        Text("已安装")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
                
                Text(app.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
                    .font(.title2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct AppInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let bundleId: String
    let category: String
    let systemImage: String
}

extension Color {
    init(_ categoryName: String) {
        switch categoryName.lowercased() {
        case "social":
            self = .blue
        case "entertainment":
            self = .purple
        case "news":
            self = .orange
        case "shopping":
            self = .green
        case "finance":
            self = .yellow
        case "music":
            self = .pink
        case "food":
            self = .red
        case "travel":
            self = .cyan
        case "navigation":
            self = .indigo
        default:
            self = .gray
        }
    }
}

#Preview {
    AppSelectionView { selectedApps in
        print("Selected apps: \(selectedApps)")
    }
}