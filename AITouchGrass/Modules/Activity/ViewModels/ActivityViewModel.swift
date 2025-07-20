import Foundation
import Combine
import SwiftUI

final class ActivityViewModel: BaseViewModel {
    
    struct Input {
        let viewAppeared = PassthroughSubject<Void, Never>()
        let startActivityTapped = PassthroughSubject<ActivityType, Never>()
        let activitySelected = PassthroughSubject<Activity, Never>()
    }
    
    struct Output {
        let recentActivities: AnyPublisher<[Activity], Never>
        let currentActivity: AnyPublisher<Activity?, Never>
    }
    
    let input = Input()
    @Published var output: Output?
    
    let serviceContainer: ServiceContainer
    private var activityService: ActivityService
    
    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
        self.activityService = serviceContainer.activityService
        super.init()
        
        setupBindings()
    }
    
    override func setupBindings() {
        let recentActivities = activityService.$recentActivities
            .eraseToAnyPublisher()
        
        let currentActivity = activityService.$currentActivity
            .eraseToAnyPublisher()
        
        output = Output(
            recentActivities: recentActivities,
            currentActivity: currentActivity
        )
        
        input.viewAppeared
            .sink { [weak self] _ in
                self?.loadActivities()
            }
            .store(in: &cancellables)
        
        input.startActivityTapped
            .sink { [weak self] type in
                self?.startNewActivity(type: type)
            }
            .store(in: &cancellables)
    }
    
    private func loadActivities() {
        activityService.fetchRecentActivities()
    }
    
    private func startNewActivity(type: ActivityType) {
        let name = "\(type.displayName) - \(Date().formatted(date: .abbreviated, time: .shortened))"
        _ = activityService.startActivity(name: name, type: type)
    }
}