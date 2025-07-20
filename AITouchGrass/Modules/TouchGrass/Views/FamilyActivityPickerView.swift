import SwiftUI
import FamilyControls

struct FamilyActivityPickerView: View {
    @Binding var selection: FamilyActivitySelection
    @State private var isPresented = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("选择要限制的应用和类别")
                    .font(.headline)
                    .padding()
                
                // FamilyActivityPicker from FamilyControls
                FamilyActivityPicker(selection: $selection)
                    .navigationTitle("选择应用")
                    .navigationBarTitleDisplayMode(.inline)
                    .ignoresSafeArea()
                
                // 调试信息
                VStack {
                    Text("已选择应用: \(selection.applicationTokens.count)")
                        .font(.caption)
                    Text("已选择类别: \(selection.categoryTokens.count)")
                        .font(.caption)
                }
                .padding()
                
                Spacer()
                
                HStack {
                    Button("取消") {
                        dismiss()
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("完成") {
                        dismiss()
                    }
                    .padding()
                    .fontWeight(.semibold)
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

