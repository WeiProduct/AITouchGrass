import UIKit
import CoreImage

// 测试草地检测函数
func testGrassDetection() {
    // 创建一个简单的绿色测试图像
    let size = CGSize(width: 100, height: 100)
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1.0
    
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    let greenTestImage = renderer.image { context in
        // 填充绿色
        UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0).setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
    
    print("测试图像创建完成，尺寸: \(greenTestImage.size)")
    
    // 测试颜色检测函数
    func isGreenColor(r: CGFloat, g: CGFloat, b: CGFloat) -> Bool {
        return (g > r * 1.1 && g > b * 1.1 && g > 0.2) || 
               (g > 0.4 && g > r && g > b) ||
               (r > 0.2 && g > 0.3 && b > 0.1 && g > r * 0.8)
    }
    
    // 测试一些颜色值
    let testColors: [(String, CGFloat, CGFloat, CGFloat)] = [
        ("深绿色", 0.2, 0.8, 0.3),
        ("浅绿色", 0.4, 0.6, 0.2),
        ("草绿色", 0.3, 0.5, 0.2),
        ("黄绿色", 0.4, 0.7, 0.3),
        ("红色", 0.8, 0.2, 0.2),
        ("蓝色", 0.2, 0.2, 0.8)
    ]
    
    for (name, r, g, b) in testColors {
        let isGreen = isGreenColor(r: r, g: g, b: b)
        print("\(name) (R:\(r), G:\(g), B:\(b)) -> \(isGreen ? "✅ 检测为绿色" : "❌ 未检测为绿色")")
    }
}

// 运行测试
testGrassDetection()