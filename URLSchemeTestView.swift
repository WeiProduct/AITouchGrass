import SwiftUI

struct URLSchemeTestView: View {
    @State private var testResults: [(String, String, Bool)] = []
    @State private var isTesting = false
    
    let testSchemes = [
        ("微信", "weixin://"),
        ("微信2", "wechat://"),
        ("QQ", "mqq://"),
        ("QQ API", "mqqapi://"),
        ("支付宝", "alipay://"),
        ("淘宝", "taobao://"),
        ("抖音", "snssdk1128://"),
        ("微博", "sinaweibo://"),
        ("小红书", "xhsdiscover://"),
        ("B站", "bilibili://"),
        ("快手", "kwai://"),
        ("网易云", "orpheus://"),
        ("高德地图", "iosamap://"),
        ("美团", "imeituan://"),
        ("饿了么", "eleme://"),
        ("滴滴", "diditaxi://"),
        ("京东", "openapp.jdmobile://"),
        ("Instagram", "instagram://"),
        ("WhatsApp", "whatsapp://"),
        ("YouTube", "youtube://"),
        ("Chrome", "googlechrome://"),
        ("设置", "prefs://"),
        ("邮件", "mailto://"),
        ("电话", "tel://"),
        ("短信", "sms://"),
        ("Safari", "http://"),
        ("地图", "maps://"),
        ("App Store", "itms-apps://")
    ]
    
    var body: some View {
        VStack {
            Text("URL Scheme 检测测试")
                .font(.title)
                .padding()
            
            if isTesting {
                ProgressView("正在测试...")
                    .padding()
            } else {
                Button("开始测试") {
                    testURLSchemes()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(testResults, id: \.0) { result in
                        HStack {
                            Text(result.0)
                                .frame(width: 100, alignment: .leading)
                            Text(result.1)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.gray)
                            Spacer()
                            Image(systemName: result.2 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(result.2 ? .green : .red)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            if !testResults.isEmpty {
                Text("检测到 \(testResults.filter { $0.2 }.count) / \(testResults.count) 个应用")
                    .padding()
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("URL Scheme 测试")
    }
    
    func testURLSchemes() {
        isTesting = true
        testResults.removeAll()
        
        DispatchQueue.global().async {
            for (name, scheme) in testSchemes {
                let canOpen = testScheme(scheme)
                DispatchQueue.main.async {
                    testResults.append((name, scheme, canOpen))
                }
            }
            
            DispatchQueue.main.async {
                isTesting = false
            }
        }
    }
    
    func testScheme(_ scheme: String) -> Bool {
        guard let url = URL(string: scheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}