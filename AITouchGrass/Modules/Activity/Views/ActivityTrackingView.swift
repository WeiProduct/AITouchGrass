//
//  ActivityTrackingView.swift
//  AITouchGrass
//
//  Created by weifu on 7/13/25.
//

import SwiftUI
import MapKit
import Combine

struct ActivityTrackingView: View {
    @StateObject private var viewModel: ActivityTrackingViewModel
    @State private var startActivitySubject = PassthroughSubject<ActivityType, Never>()
    @State private var pauseResumeSubject = PassthroughSubject<Void, Never>()
    @State private var stopSubject = PassthroughSubject<Void, Never>()
    @State private var saveSubject = PassthroughSubject<Void, Never>()
    @State private var showStopConfirmation = false
    
    init(viewModel: ActivityTrackingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Map View
            ActivityMapView(locations: viewModel.locations)
                .ignoresSafeArea()
            
            // Overlay Controls
            VStack {
                // Top Stats Bar
                if viewModel.currentActivity != nil {
                    TopStatsBar(viewModel: viewModel)
                        .padding()
                }
                
                Spacer()
                
                // Bottom Controls
                if viewModel.currentActivity != nil {
                    BottomControlsView(
                        isPaused: viewModel.isPaused,
                        onPauseResume: {
                            pauseResumeSubject.send()
                        },
                        onStop: {
                            showStopConfirmation = true
                        }
                    )
                    .padding()
                } else {
                    ActivityTypeSelector { type in
                        startActivitySubject.send(type)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(viewModel.currentActivity?.type.displayName ?? "开始活动")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "停止活动？",
            isPresented: $showStopConfirmation,
            titleVisibility: .visible
        ) {
            Button("停止并保存", role: .destructive) {
                stopSubject.send()
            }
            Button("继续", role: .cancel) {}
        } message: {
            Text("确定要停止记录这次活动吗？")
        }
        .onAppear {
            setupBindings()
        }
    }
    
    private func setupBindings() {
        let input = ActivityTrackingViewModel.Input(
            startActivity: startActivitySubject.eraseToAnyPublisher(),
            pauseResume: pauseResumeSubject.eraseToAnyPublisher(),
            stopActivity: stopSubject.eraseToAnyPublisher(),
            saveActivity: saveSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        // Use output if needed for UI updates
        _ = output
    }
}

// MARK: - Map View
struct ActivityMapView: View {
    let locations: [LocationCoordinate]
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
    )
    
    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            
            // Show the activity path
            if !locations.isEmpty {
                MapPolyline(coordinates: locations.map { 
                    CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) 
                })
                .stroke(.blue, lineWidth: 3)
            }
        }
        .onAppear {
            updateRegion()
        }
        .onChange(of: locations) {
            updateRegion()
        }
    }
    
    private func updateRegion() {
        guard let lastLocation = locations.last else { return }
        
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lastLocation.latitude, longitude: lastLocation.longitude),
                    latitudinalMeters: 500,
                    longitudinalMeters: 500
                )
            )
        }
    }
}

// MARK: - Top Stats Bar
struct TopStatsBar: View {
    @ObservedObject var viewModel: ActivityTrackingViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            StatView(
                title: "时间",
                value: formatTime(viewModel.elapsedTime),
                systemImage: "timer"
            )
            
            StatView(
                title: "距离",
                value: String(format: "%.2f km", viewModel.distance / 1000),
                systemImage: "location"
            )
            
            StatView(
                title: "速度",
                value: String(format: "%.1f km/h", viewModel.currentSpeed * 3.6),
                systemImage: "speedometer"
            )
            
            StatView(
                title: "卡路里",
                value: String(format: "%.0f", viewModel.calories),
                systemImage: "flame"
            )
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Stat View
struct StatView: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Bottom Controls
struct BottomControlsView: View {
    let isPaused: Bool
    let onPauseResume: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // Pause/Resume Button
            Button(action: onPauseResume) {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            
            // Stop Button
            Button(action: onStop) {
                Image(systemName: "stop.fill")
                    .font(.title)
                    .frame(width: 80, height: 80)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(30)
    }
}

// MARK: - Activity Type Selector
struct ActivityTypeSelector: View {
    let onSelect: (ActivityType) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("选择活动类型")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(ActivityType.allCases, id: \.self) { type in
                    ActivityTypeButton(type: type) {
                        onSelect(type)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(20)
    }
}

// MARK: - Activity Type Button
struct ActivityTypeButton: View {
    let type: ActivityType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.systemImage)
                    .font(.largeTitle)
                Text(type.displayName)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}