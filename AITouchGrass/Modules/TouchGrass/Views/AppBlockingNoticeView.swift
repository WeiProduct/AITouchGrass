import SwiftUI

struct AppBlockingNoticeView: View {
    @Environment(\.dismiss) var dismiss
    let onUnderstand: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("关于应用锁定功能")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("请了解iOS应用锁定的限制")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Explanation Cards
                    VStack(spacing: 16) {
                        InfoCard(
                            icon: "exclamationmark.triangle.fill",
                            iconColor: .orange,
                            title: "当前限制",
                            description: "由于iOS系统限制，普通应用无法直接阻止其他应用运行。真正的应用锁定需要特殊的系统权限（Screen Time API）。"
                        )
                        
                        InfoCard(
                            icon: "checkmark.shield.fill",
                            iconColor: .green,
                            title: "演示功能",
                            description: "本应用提供了应用选择和管理界面的演示。您可以选择应用、设置锁定时间，体验完整的用户界面流程。"
                        )
                        
                        InfoCard(
                            icon: "bell.badge.fill",
                            iconColor: .blue,
                            title: "提醒功能",
                            description: "当您尝试使用被\"锁定\"的应用时，我们会发送通知提醒您应该去户外活动。这是一种柔性的自我管理方式。"
                        )
                        
                        InfoCard(
                            icon: "chart.line.uptrend.xyaxis",
                            iconColor: .purple,
                            title: "使用统计",
                            description: "应用会记录您的使用习惯和户外活动情况，帮助您了解自己的数字生活平衡状态。"
                        )
                    }
                    
                    // Alternative Solutions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("真正锁定应用的方法")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        AlternativeCard(
                            number: "1",
                            title: "使用iOS屏幕使用时间",
                            description: "设置 > 屏幕使用时间 > 应用限额"
                        )
                        
                        AlternativeCard(
                            number: "2",
                            title: "家长控制",
                            description: "让家人帮助设置应用限制"
                        )
                        
                        AlternativeCard(
                            number: "3",
                            title: "删除应用",
                            description: "最直接的方法是暂时删除容易沉迷的应用"
                        )
                    }
                    .padding(.vertical)
                    
                    // Action Button
                    Button(action: {
                        onUnderstand()
                        dismiss()
                    }) {
                        Text("我已了解，继续使用")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct AlternativeCard: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    AppBlockingNoticeView {
        print("User understood limitations")
    }
}