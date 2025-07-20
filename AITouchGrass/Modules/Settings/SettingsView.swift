import SwiftUI

struct SettingsView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Language Section
                Section(header: Text(L("语言"))) {
                    HStack {
                        Text(L("语言"))
                        Spacer()
                        Picker("", selection: $localizationManager.currentLanguage) {
                            Text(L("中文")).tag("zh-Hans")
                            Text(L("English")).tag("en")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 150)
                        .onChange(of: localizationManager.currentLanguage) { newValue in
                            localizationManager.toggleLanguage()
                        }
                    }
                }
                
                // About Section
                Section(header: Text(L("关于"))) {
                    Link(destination: URL(string: "https://aitouchgrass.com/privacy.html")!) {
                        HStack {
                            Text(L("隐私政策"))
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "https://aitouchgrass.com/terms.html")!) {
                        HStack {
                            Text(L("使用条款"))
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Text(L("版本"))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(L("设置"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("完成")) {
                        dismiss()
                    }
                }
            }
        }
    }
}