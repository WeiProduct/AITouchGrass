import UIKit
import SwiftUI

/// URL Scheme Testing View
/// Use this to diagnose LSApplicationQueriesSchemes issues
struct URLSchemeTestView: View {
    @State private var testResults: [(scheme: String, canOpen: Bool, error: String?)] = []
    @State private var isTesting = false
    
    // Test schemes - both system and third-party
    let testSchemes = [
        // System apps (should always work)
        ("Settings", "prefs"),
        ("Mail", "mailto"),
        ("Phone", "tel"),
        ("SMS", "sms"),
        ("Safari", "http"),
        ("Maps", "maps"),
        ("App Store", "itms-apps"),
        
        // Popular Chinese apps
        ("WeChat", "weixin"),
        ("QQ", "mqq"),
        ("Alipay", "alipay"),
        ("Taobao", "taobao"),
        ("TikTok CN", "snssdk1128"),
        ("Weibo", "sinaweibo"),
        ("XiaoHongShu", "xhsdiscover"),
        ("Bilibili", "bilibili"),
        
        // International apps
        ("Instagram", "instagram"),
        ("WhatsApp", "whatsapp"),
        ("YouTube", "youtube"),
        ("Facebook", "fb"),
        ("Twitter", "twitter"),
        ("Telegram", "tg")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if isTesting {
                    ProgressView("Testing URL schemes...")
                        .padding()
                } else {
                    Button("Test All URL Schemes") {
                        testAllSchemes()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                
                List(testResults, id: \.scheme) { result in
                    HStack {
                        Text(result.scheme)
                            .font(.system(.body, design: .monospaced))
                        
                        Spacer()
                        
                        if result.canOpen {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        
                        if let error = result.error {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("URL Scheme Test")
        }
    }
    
    func testAllSchemes() {
        isTesting = true
        testResults.removeAll()
        
        DispatchQueue.global().async {
            for (name, scheme) in testSchemes {
                let result = testURLScheme(name: name, scheme: scheme)
                DispatchQueue.main.async {
                    testResults.append(result)
                }
            }
            
            DispatchQueue.main.async {
                isTesting = false
                printSummary()
            }
        }
    }
    
    func testURLScheme(name: String, scheme: String) -> (scheme: String, canOpen: Bool, error: String?) {
        let urlString = scheme.contains("://") ? scheme : "\(scheme)://"
        
        guard let url = URL(string: urlString) else {
            return ("\(name) (\(scheme))", false, "Invalid URL")
        }
        
        var canOpen = false
        var error: String? = nil
        
        // Use a semaphore to make the async call synchronous for testing
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.main.async {
            // Capture console output by redirecting stderr
            let pipe = Pipe()
            let originalStderr = dup(STDERR_FILENO)
            dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
            
            canOpen = UIApplication.shared.canOpenURL(url)
            
            // Restore stderr
            dup2(originalStderr, STDERR_FILENO)
            close(originalStderr)
            
            // Read any error output
            pipe.fileHandleForWriting.closeFile()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                if output.contains("not allowed to query") {
                    error = "Not in LSApplicationQueriesSchemes"
                }
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return ("\(name) (\(scheme))", canOpen, error)
    }
    
    func printSummary() {
        print("\n=== URL Scheme Test Summary ===")
        print("Total schemes tested: \(testResults.count)")
        
        let workingSchemes = testResults.filter { $0.canOpen }
        print("Working schemes: \(workingSchemes.count)")
        
        let failedSchemes = testResults.filter { !$0.canOpen }
        print("Failed schemes: \(failedSchemes.count)")
        
        let notConfigured = testResults.filter { $0.error != nil }
        print("Not in LSApplicationQueriesSchemes: \(notConfigured.count)")
        
        print("\nWorking schemes:")
        for result in workingSchemes {
            print("  ✅ \(result.scheme)")
        }
        
        print("\nFailed schemes:")
        for result in failedSchemes {
            if let error = result.error {
                print("  ❌ \(result.scheme) - \(error)")
            } else {
                print("  ❌ \(result.scheme) - App not installed")
            }
        }
        
        print("\n=== Diagnostic Info ===")
        print("Device: \(UIDevice.current.model)")
        print("iOS Version: \(UIDevice.current.systemVersion)")
        print("Running on Simulator: \(TARGET_OS_SIMULATOR == 1 ? "Yes" : "No")")
        print("========================\n")
    }
}

// MARK: - Standalone test function
func runURLSchemeTest() {
    print("Starting URL Scheme Test...")
    
    let schemes = [
        "prefs", "mailto", "tel", "sms", "http", "maps",
        "weixin", "mqq", "alipay", "taobao", "instagram", "whatsapp"
    ]
    
    for scheme in schemes {
        let urlString = "\(scheme)://"
        if let url = URL(string: urlString) {
            let canOpen = UIApplication.shared.canOpenURL(url)
            print("\(scheme): \(canOpen ? "✅" : "❌")")
        }
    }
}

// MARK: - Info.plist Verification
func verifyInfoPlistConfiguration() {
    print("\n=== Info.plist Configuration Check ===")
    
    if let infoPlist = Bundle.main.infoDictionary {
        if let schemes = infoPlist["LSApplicationQueriesSchemes"] as? [String] {
            print("✅ LSApplicationQueriesSchemes found with \(schemes.count) entries:")
            for (index, scheme) in schemes.prefix(10).enumerated() {
                print("  \(index + 1). \(scheme)")
            }
            if schemes.count > 10 {
                print("  ... and \(schemes.count - 10) more")
            }
        } else {
            print("❌ LSApplicationQueriesSchemes NOT FOUND in Info.plist")
            print("This is why URL scheme detection is not working!")
        }
        
        // Also check for auto-generated Info.plist
        if let _ = infoPlist["CFBundleExecutable"] {
            print("\nInfo.plist appears to be loaded correctly")
        }
    } else {
        print("❌ Could not load Info.plist")
    }
    
    print("=====================================\n")
}