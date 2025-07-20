import Foundation
import HealthKit
import Combine

final class HealthKitService: ServiceProtocol {
    nonisolated static let identifier = "HealthKitService"
    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isAuthorized = false
    @Published var todaySteps: Int = 0
    @Published var todayCalories: Int = 0
    @Published var todayDistance: Double = 0
    
    init() {
        checkAuthorization()
    }
    
    private func checkAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available")
            return
        }
    }
    
    func requestAuthorization() async throws {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKWorkoutType.workoutType()
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKWorkoutType.workoutType()
        ]
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
        isAuthorized = true
    }
    
    func saveActivity(activity: Activity) async throws {
        var energyBurned: HKQuantity?
        var distance: HKQuantity?
        
        if let calories = activity.calories {
            energyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
        }
        
        if let dist = activity.distance {
            distance = HKQuantity(unit: .meter(), doubleValue: dist)
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activity.type.hkWorkoutActivityType
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: nil)
        
        try await builder.beginCollection(at: activity.startDate)
        
        if let energyBurned = energyBurned {
            try await builder.addSamples([HKQuantitySample(
                type: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                quantity: energyBurned,
                start: activity.startDate,
                end: activity.endDate ?? Date()
            )])
        }
        
        if let distance = distance {
            try await builder.addSamples([HKQuantitySample(
                type: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                quantity: distance,
                start: activity.startDate,
                end: activity.endDate ?? Date()
            )])
        }
        
        try await builder.endCollection(at: activity.endDate ?? Date())
        let workout = try await builder.finishWorkout()
        print("Workout saved: \(String(describing: workout))")
    }
    
    func fetchTodayStats() async {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchSteps(from: startOfDay, to: now) }
            group.addTask { await self.fetchCalories(from: startOfDay, to: now) }
            group.addTask { await self.fetchDistance(from: startOfDay, to: now) }
        }
    }
    
    private func fetchSteps(from start: Date, to end: Date) async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        do {
            let samples: [HKSample] = try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: stepType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: samples ?? [])
                    }
                }
                healthStore.execute(query)
            }
            
            let steps = samples.compactMap { ($0 as? HKQuantitySample)?.quantity.doubleValue(for: .count()) }
            todaySteps = Int(steps.reduce(0, +))
        } catch {
            print("Failed to fetch steps: \(error)")
        }
    }
    
    private func fetchCalories(from start: Date, to end: Date) async {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        do {
            let samples: [HKSample] = try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: calorieType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: samples ?? [])
                    }
                }
                healthStore.execute(query)
            }
            
            let calories = samples.compactMap { ($0 as? HKQuantitySample)?.quantity.doubleValue(for: .kilocalorie()) }
            todayCalories = Int(calories.reduce(0, +))
        } catch {
            print("Failed to fetch calories: \(error)")
        }
    }
    
    private func fetchDistance(from start: Date, to end: Date) async {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        do {
            let samples: [HKSample] = try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: distanceType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: samples ?? [])
                    }
                }
                healthStore.execute(query)
            }
            
            let distances = samples.compactMap { ($0 as? HKQuantitySample)?.quantity.doubleValue(for: .meter()) }
            todayDistance = distances.reduce(0, +)
        } catch {
            print("Failed to fetch distance: \(error)")
        }
    }
}

extension ActivityType {
    var hkWorkoutActivityType: HKWorkoutActivityType {
        switch self {
        case .walking: return .walking
        case .running: return .running
        case .cycling: return .cycling
        case .hiking: return .hiking
        case .swimming: return .swimming
        case .yoga: return .yoga
        case .workout: return .functionalStrengthTraining
        case .other: return .other
        }
    }
}