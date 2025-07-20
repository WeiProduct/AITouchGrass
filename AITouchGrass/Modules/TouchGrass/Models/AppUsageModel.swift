import Foundation
import SwiftData

@Model
final class AppUsage {
    var appName: String
    var bundleIdentifier: String
    var isBlocked: Bool
    var unlockTime: Date?
    var usageCount: Int
    var totalUsageTime: TimeInterval
    var lastUsedDate: Date?
    var createdDate: Date
    var category: String
    
    init(appName: String, bundleIdentifier: String, category: String = "Other") {
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.isBlocked = false
        self.unlockTime = nil
        self.usageCount = 0
        self.totalUsageTime = 0
        self.lastUsedDate = nil
        self.createdDate = Date()
        self.category = category
    }
    
    var isCurrentlyBlocked: Bool {
        guard isBlocked else { return false }
        if let unlockTime = unlockTime {
            return Date() < unlockTime
        }
        return true
    }
    
    func unlock(for duration: TimeInterval) {
        unlockTime = Date().addingTimeInterval(duration)
        usageCount += 1
        lastUsedDate = Date()
    }
    
    func block() {
        isBlocked = true
        unlockTime = nil
    }
    
    func unblock() {
        isBlocked = false
        unlockTime = nil
    }
}

@Model
final class AppBlockingSession {
    var startTime: Date
    var endTime: Date?
    var blockedApps: [String]
    var natureType: String
    var verificationCount: Int
    var totalUnlockTime: TimeInterval
    
    init(blockedApps: [String], natureType: String) {
        self.startTime = Date()
        self.endTime = nil
        self.blockedApps = blockedApps
        self.natureType = natureType
        self.verificationCount = 0
        self.totalUnlockTime = 0
    }
    
    func endSession() {
        endTime = Date()
    }
    
    func recordVerification(unlockDuration: TimeInterval) {
        verificationCount += 1
        totalUnlockTime += unlockDuration
    }
    
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
}