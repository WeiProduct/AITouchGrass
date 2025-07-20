import SwiftUI

struct URLSchemeDiagnosticView: View {
    @State private var testResults: [(app: String, scheme: String, canOpen: Bool)] = []
    @State private var isTesting = false
    @State private var selectedCategory = "全部"
    @State private var showOnlyInstalled = false
    
    let categories = ["全部", "社交", "购物", "生活", "出行", "娱乐", "音乐", "金融", "办公", "工具", "游戏", "系统"]
    
    var filteredResults: [(app: String, scheme: String, canOpen: Bool)] {
        var results = testResults
        
        if selectedCategory != "全部" {
            results = results.filter { result in
                EnhancedAppDetectionService.appVariants.first { $0.name == result.app }?.category == selectedCategory
            }
        }
        
        if showOnlyInstalled {
            results = results.filter { $0.canOpen }
        }
        
        return results
    }
    
    var installedCount: Int {
        Set(testResults.filter { $0.canOpen }.map { $0.app }).count
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CategoryChip(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Filter Toggle
                Toggle("只显示已安装", isOn: $showOnlyInstalled)
                    .padding(.horizontal)
                
                // Test Button
                if !isTesting {
                    Button(action: runDiagnostic) {
                        Label("运行检测", systemImage: "magnifyingglass")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                } else {
                    ProgressView("正在检测...")
                        .padding()
                }
                
                // Results Summary
                if !testResults.isEmpty {
                    HStack {
                        Text("检测到 \(installedCount) 个已安装应用")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // Results List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredResults, id: \.scheme) { result in
                            DiagnosticResultRow(
                                appName: result.app,
                                scheme: result.scheme,
                                canOpen: result.canOpen
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("URL Scheme 诊断")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("导出") {
                        exportResults()
                    }
                    .disabled(testResults.isEmpty)
                }
            }
        }
    }
    
    func runDiagnostic() {
        isTesting = true
        testResults.removeAll()
        
        Task {
            var results: [(app: String, scheme: String, canOpen: Bool)] = []
            
            // Test apps declared in Info.plist
            let declaredSchemes = [
                "weixin", "wechat", "mqq", "alipay", "taobao", "tmall", "zhihu",
                "pinduoduo", "snssdk1128", "bilibili", "kwai", "orpheus", "qqmusic",
                "iosamap", "baidumap", "imeituan", "eleme", "diditaxi", "openapp.jdmobile",
                "baiduboxapp", "dingtalk", "wxwork", "instagram", "whatsapp", "youtube",
                "fb", "twitter", "tg", "googlechrome", "spotify", "snapchat", "linkedin",
                "discord", "uber", "prefs", "mailto", "tel", "sms", "http", "maps", "itms-apps"
            ]
            
            // Map schemes to app names
            let schemeToApp: [String: String] = [
                "weixin": "微信", "wechat": "微信",
                "mqq": "QQ", "alipay": "支付宝",
                "taobao": "淘宝", "tmall": "天猫",
                "zhihu": "知乎", "pinduoduo": "拼多多",
                "snssdk1128": "抖音", "bilibili": "B站",
                "kwai": "快手", "orpheus": "网易云音乐",
                "qqmusic": "QQ音乐", "iosamap": "高德地图",
                "baidumap": "百度地图", "imeituan": "美团",
                "eleme": "饿了么", "diditaxi": "滴滴出行",
                "openapp.jdmobile": "京东", "baiduboxapp": "百度",
                "dingtalk": "钉钉", "wxwork": "企业微信",
                "instagram": "Instagram", "whatsapp": "WhatsApp",
                "youtube": "YouTube", "fb": "Facebook",
                "twitter": "Twitter", "tg": "Telegram",
                "googlechrome": "Chrome", "spotify": "Spotify",
                "snapchat": "Snapchat", "linkedin": "LinkedIn",
                "discord": "Discord", "uber": "Uber",
                "prefs": "设置", "mailto": "邮件",
                "tel": "电话", "sms": "短信",
                "http": "Safari", "maps": "地图",
                "itms-apps": "App Store"
            ]
            
            for scheme in declaredSchemes {
                let canOpen = await EnhancedAppDetectionService.canOpenURLScheme(scheme)
                let appName = schemeToApp[scheme] ?? scheme
                results.append((app: appName, scheme: scheme, canOpen: canOpen))
            }
            
            await MainActor.run {
                self.testResults = results
                self.isTesting = false
            }
        }
    }
    
    func exportResults() {
        var text = "URL Scheme 检测结果\n"
        text += "生成时间: \(Date().formatted())\n\n"
        text += "已安装应用 (\(installedCount)):\n"
        
        for result in testResults.filter({ $0.canOpen }) {
            text += "✅ \(result.app) - \(result.scheme)\n"
        }
        
        text += "\n未安装应用:\n"
        for result in testResults.filter({ !$0.canOpen }) {
            text += "❌ \(result.app) - \(result.scheme)\n"
        }
        
        // Share the text
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct DiagnosticResultRow: View {
    let appName: String
    let scheme: String
    let canOpen: Bool
    
    var body: some View {
        HStack {
            Image(systemName: canOpen ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(canOpen ? .green : .red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(appName)
                    .font(.headline)
                Text(scheme)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if canOpen {
                Button("打开") {
                    if let url = URL(string: "\(scheme)://") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct CategoryChip: View {
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
                .background(isSelected ? Color.blue : Color(.tertiarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

