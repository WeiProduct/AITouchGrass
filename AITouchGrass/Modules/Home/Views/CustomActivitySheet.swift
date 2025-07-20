import SwiftUI

struct CustomActivitySheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var activityName = ""
    @State private var selectedType: ActivityType = .other
    
    var onSave: ((String, ActivityType) -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("活动信息")) {
                    TextField("活动名称", text: $activityName)
                    
                    Picker("活动类型", selection: $selectedType) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.systemImage)
                                .tag(type)
                        }
                    }
                }
            }
            .navigationTitle("自定义活动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("开始") {
                        onSave?(activityName.isEmpty ? selectedType.displayName : activityName, selectedType)
                        dismiss()
                    }
                    .disabled(activityName.isEmpty && selectedType == .other)
                }
            }
        }
    }
}