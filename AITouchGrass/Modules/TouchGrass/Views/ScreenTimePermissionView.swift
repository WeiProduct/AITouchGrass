import SwiftUI

struct ScreenTimePermissionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingAppleLink = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Icon
                    Image(systemName: "lock.shield")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 40)
                    
                    // Title
                    Text("关于应用锁定功能")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    // Explanation
                    VStack(spacing: 20) {
                        FeatureCard(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: "Touch Grass 的实现方式",
                            description: "Touch Grass 应用使用了 Apple 的 Screen Time API 来真正阻止应用运行。这需要从 Apple 获得特殊的 Family Controls 权限。"
                        )
                        
                        FeatureCard(
                            icon: "checkmark.shield.fill",
                            iconColor: .green,
                            title: "我们当前的功能",
                            description: "在获得 Apple 批准前，我们使用智能提醒系统。当您尝试使用被限制的应用时，会收到通知提醒您去户外活动。"
                        )
                        
                        FeatureCard(
                            icon: "bell.badge.fill",
                            iconColor: .orange,
                            title: "提醒功能同样有效",
                            description: "研究表明，及时的提醒可以有效帮助建立健康习惯。我们的通知系统会在关键时刻提醒您放下手机。"
                        )
                        
                        FeatureCard(
                            icon: "chart.line.uptrend.xyaxis",
                            iconColor: .purple,
                            title: "完整的统计功能",
                            description: "应用会记录您的使用模式和户外活动时间，帮助您了解并改善数字生活习惯。"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Future Plans
                    VStack(alignment: .leading, spacing: 16) {
                        Text("未来计划")
                            .font(.headline)
                        
                        Text("我们正在申请 Family Controls 权限，获批后将提供：")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            FutureFeatureRow(text: "真正的应用阻止功能")
                            FutureFeatureRow(text: "自定义阻止时间段")
                            FutureFeatureRow(text: "应用使用时间限制")
                            FutureFeatureRow(text: "家长控制功能")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { dismiss() }) {
                            Text("开始使用")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        
                        Button(action: { showingAppleLink = true }) {
                            Text("了解更多关于 Screen Time API")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("跳过") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAppleLink) {
            SafariView(url: URL(string: "https://developer.apple.com/documentation/familycontrols")!)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct FutureFeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.yellow)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

// Safari View for showing web links
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    ScreenTimePermissionView()
}