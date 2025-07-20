import SwiftUI

struct AppRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            coordinator.homeCoordinator.rootView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(AppTab.home)
            
            coordinator.activityCoordinator.rootView()
                .tabItem {
                    Label("活动", systemImage: "figure.walk")
                }
                .tag(AppTab.activity)
            
            coordinator.touchGrassCoordinator.rootView()
                .tabItem {
                    Label("专注", systemImage: "leaf.fill")
                }
                .tag(AppTab.touchGrass)
            
            coordinator.statisticsCoordinator.rootView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar.fill")
                }
                .tag(AppTab.statistics)
            
            coordinator.profileCoordinator.rootView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(AppTab.profile)
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

