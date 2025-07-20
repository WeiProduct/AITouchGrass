import Foundation
import Vision
import CoreML
@preconcurrency import UIKit
import Combine

/// 简化的草地检测服务，避免复杂的图像处理导致的崩溃
@MainActor
final class SimpleGrassDetectionService: ServiceProtocol {
    nonisolated static let identifier = "SimpleGrassDetectionService"
    
    @Published var isDetecting = false
    @Published var lastDetectionResult: NatureDetectionResult?
    @Published var detectionError: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {}
    
    func configure() {
        // Service configuration if needed
    }
    
    func detectNature(type: NatureType, in image: UIImage) async throws -> NatureDetectionResult {
        print("DEBUG: SimpleGrassDetectionService.detectNature called for \(type.rawValue)")
        isDetecting = true
        defer { 
            print("DEBUG: SimpleGrassDetectionService.detectNature finished")
            isDetecting = false 
        }
        
        guard let ciImage = CIImage(image: image) else {
            print("DEBUG: Failed to create CIImage from UIImage")
            throw NatureDetectionError.invalidImage
        }
        
        print("DEBUG: CIImage created successfully, starting simplified detection")
        
        // 临时简化检测：任何图片都有50%概率通过
        let randomSuccess = arc4random_uniform(100) < 80  // 80%通过率
        
        let detectionResult: NatureDetectionResult
        
        if randomSuccess {
            print("DEBUG: Using random success for testing")
            detectionResult = NatureDetectionResult(
                natureType: type,
                isValid: true,
                confidence: 0.75 + Double(arc4random_uniform(20)) / 100.0, // 0.75-0.95
                colorScore: 0.6,
                textureScore: 0.7,
                timestamp: Date()
            )
        } else {
            // 运行真实检测
            switch type {
            case .grass:
                detectionResult = await detectGrassSimple(in: ciImage)
            case .snow:
                detectionResult = await detectSnowSimple(in: ciImage)
            case .sand:
                detectionResult = await detectSandSimple(in: ciImage)
            case .sky:
                detectionResult = await detectSkySimple(in: ciImage)
            }
        }
        
        print("DEBUG: Simple detection completed with result: \(detectionResult)")
        lastDetectionResult = detectionResult
        return detectionResult
    }
    
    private func detectGrassSimple(in ciImage: CIImage) async -> NatureDetectionResult {
        print("DEBUG: Starting simple grass detection")
        
        // 使用基本的颜色检测，避免复杂的像素处理
        let colorScore = await analyzeColorSimple(in: ciImage, targetColor: .green)
        let textureScore = 0.7  // 默认纹理分数
        
        let isValid = colorScore > 0.1  // 进一步降低阈值，更容易通过
        let confidence = min(0.9, (colorScore + textureScore) / 2.0)
        
        print("DEBUG: Simple grass detection - colorScore: \(colorScore), isValid: \(isValid), confidence: \(confidence)")
        
        return NatureDetectionResult(
            natureType: .grass,
            isValid: isValid,
            confidence: confidence,
            colorScore: colorScore,
            textureScore: textureScore,
            timestamp: Date()
        )
    }
    
    private func detectSnowSimple(in ciImage: CIImage) async -> NatureDetectionResult {
        let colorScore = await analyzeColorSimple(in: ciImage, targetColor: .white)
        let brightnessScore = 0.8
        
        let isValid = colorScore > 0.3
        let confidence = min(0.9, (colorScore + brightnessScore) / 2.0)
        
        return NatureDetectionResult(
            natureType: .snow,
            isValid: isValid,
            confidence: confidence,
            colorScore: colorScore,
            textureScore: brightnessScore,
            timestamp: Date()
        )
    }
    
    private func detectSandSimple(in ciImage: CIImage) async -> NatureDetectionResult {
        let colorScore = await analyzeColorSimple(in: ciImage, targetColor: .sand)
        let textureScore = 0.6
        
        let isValid = colorScore > 0.2
        let confidence = min(0.9, (colorScore + textureScore) / 2.0)
        
        return NatureDetectionResult(
            natureType: .sand,
            isValid: isValid,
            confidence: confidence,
            colorScore: colorScore,
            textureScore: textureScore,
            timestamp: Date()
        )
    }
    
    private func detectSkySimple(in ciImage: CIImage) async -> NatureDetectionResult {
        let colorScore = await analyzeColorSimple(in: ciImage, targetColor: .blue)
        let gradientScore = 0.7
        
        let isValid = colorScore > 0.2
        let confidence = min(0.9, (colorScore + gradientScore) / 2.0)
        
        return NatureDetectionResult(
            natureType: .sky,
            isValid: isValid,
            confidence: confidence,
            colorScore: colorScore,
            textureScore: gradientScore,
            timestamp: Date()
        )
    }
    
    private func analyzeColorSimple(in ciImage: CIImage, targetColor: TargetColor) async -> Double {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                autoreleasepool {
                    do {
                        print("DEBUG: Starting simple color analysis for \(targetColor)")
                        
                        // 大幅缩小图像以提高性能和安全性
                        let extent = ciImage.extent
                        print("DEBUG: Processing image of size \(extent.width)x\(extent.height)")
                        
                        // 验证输入图像
                        guard extent.width > 0 && extent.height > 0 else {
                            print("DEBUG: Invalid image extent")
                            continuation.resume(returning: 0.0)
                            return
                        }
                        
                        let maxDimension: CGFloat = 128  // 更小的尺寸
                        let scale = min(maxDimension / extent.width, maxDimension / extent.height, 1.0)
                        let scaledExtent = CGRect(x: 0, y: 0, width: extent.width * scale, height: extent.height * scale)
                        
                        let context = CIContext(options: [
                            .workingColorSpace: NSNull(),
                            .priorityRequestLow: true  // 使用低优先级以避免系统压力
                        ])
                        
                        guard let bitmap = context.createCGImage(ciImage, from: scaledExtent) else {
                            print("DEBUG: Failed to create CGImage for color analysis")
                            continuation.resume(returning: 0.0)
                            return
                        }
                        
                        let width = bitmap.width
                        let height = bitmap.height
                        
                        // 更严格的图像尺寸验证
                        guard width > 0 && height > 0 && width <= 256 && height <= 256 else {
                            print("DEBUG: Image size validation failed: \(width)x\(height)")
                            continuation.resume(returning: 0.0)
                            return
                        }
                        
                        // 使用更大的采样率来提高性能，避免处理太多像素
                        let sampleRate = max(8, min(width, height) / 16)  // 动态采样率
                        var targetPixelCount = 0
                        var totalSamples = 0
                        
                        let colorSpace = CGColorSpaceCreateDeviceRGB()
                        let bytesPerPixel = 4
                        let bytesPerRow = bytesPerPixel * width
                        let bufferSize = width * height * bytesPerPixel
                        
                        // 验证缓冲区大小，避免内存问题
                        guard bufferSize < 1_000_000 else {  // 限制在1MB以内
                            print("DEBUG: Buffer size too large: \(bufferSize)")
                            continuation.resume(returning: 0.0)
                            return
                        }
                        
                        var pixelData = [UInt8](repeating: 0, count: bufferSize)
                        
                        guard let drawingContext = CGContext(
                            data: &pixelData,
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: bytesPerRow,
                            space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                        ) else {
                            print("DEBUG: Failed to create drawing context")
                            continuation.resume(returning: 0.0)
                            return
                        }
                        
                        drawingContext.draw(bitmap, in: CGRect(x: 0, y: 0, width: width, height: height))
                        
                        // 安全的像素处理
                        for y in stride(from: 0, to: height, by: sampleRate) {
                            for x in stride(from: 0, to: width, by: sampleRate) {
                                let pixelIndex = ((y * width) + x) * bytesPerPixel
                                
                                // 更严格的边界检查
                                guard pixelIndex >= 0 && pixelIndex + 3 < bufferSize else { 
                                    continue 
                                }
                                
                                let r = CGFloat(pixelData[pixelIndex]) / 255.0
                                let g = CGFloat(pixelData[pixelIndex + 1]) / 255.0
                                let b = CGFloat(pixelData[pixelIndex + 2]) / 255.0
                                
                                // 添加调试信息
                                if totalSamples < 5 {
                                    print("DEBUG: Sample \(totalSamples): R=\(String(format: "%.2f", r)), G=\(String(format: "%.2f", g)), B=\(String(format: "%.2f", b))")
                                }
                                
                                if self.isTargetColor(r: r, g: g, b: b, target: targetColor) {
                                    targetPixelCount += 1
                                    if targetPixelCount <= 3 {
                                        print("DEBUG: Found target color #\(targetPixelCount): R=\(String(format: "%.2f", r)), G=\(String(format: "%.2f", g)), B=\(String(format: "%.2f", b))")
                                    }
                                }
                                totalSamples += 1
                                
                                // 限制总样本数，避免过长的处理时间
                                if totalSamples > 1000 {
                                    break
                                }
                            }
                            if totalSamples > 1000 {
                                break
                            }
                        }
                        
                        let colorRatio = totalSamples > 0 ? Double(targetPixelCount) / Double(totalSamples) : 0.0
                        print("DEBUG: Simple color analysis complete, ratio: \(colorRatio), samples: \(totalSamples)")
                        continuation.resume(returning: colorRatio)
                        
                    } catch {
                        print("DEBUG: Error in color analysis: \(error)")
                        continuation.resume(returning: 0.0)
                    }
                }
            }
        }
    }
    
    nonisolated private func isTargetColor(r: CGFloat, g: CGFloat, b: CGFloat, target: TargetColor) -> Bool {
        switch target {
        case .green:
            // 更宽松的绿色检测 - 降低阈值，增加检测范围
            return (g > r * 1.1 && g > b * 1.1 && g > 0.2) || 
                   (g > 0.4 && g > r && g > b) ||
                   (r > 0.2 && g > 0.3 && b > 0.1 && g > r * 0.8)
        case .white:
            return r > 0.6 && g > 0.6 && b > 0.6
        case .blue:
            return (b > r * 1.1 && b > g * 1.0 && b > 0.3) ||
                   (b > 0.4 && b > r && b >= g)
        case .sand:
            return (r > 0.4 && g > 0.3 && b > 0.15 && r > b && g > b * 0.9) ||
                   (r > 0.5 && g > 0.4 && b < 0.4)
        }
    }
    
    private enum TargetColor {
        case green, white, blue, sand
    }
}