# AITouchGrass - Modular MVVM Architecture

## Overview

AITouchGrass is an outdoor activity tracking iOS app built with a comprehensive modular MVVM architecture using SwiftUI and Combine.

## Architecture

### Modules

The app is organized into 5 independent modules:

1. **Core Module** - Base classes, protocols, extensions, and shared services
2. **Home Module** - Main dashboard and quick actions
3. **Activity Module** - Activity tracking and recording features
4. **Profile Module** - User profile, settings, and achievements
5. **Statistics Module** - Data visualization and analytics

### Key Components

#### ViewModels
- Each module has its own ViewModels that handle business logic
- ViewModels follow the `ViewModelProtocol` with Input/Output pattern
- Base `BaseViewModel` provides common functionality

#### Views
- Built with SwiftUI
- Reactive UI using Combine publishers
- Reusable components and extensions

#### Coordinators
- Handle navigation within and between modules
- Follow `CoordinatorProtocol` for consistent navigation patterns
- Support both push navigation and sheet presentation

#### Services
- Dependency injection via `ServiceContainer`
- Protocol-based services for testability
- Key services:
  - `ActivityService` - Activity data management
  - `UserService` - User profile and preferences
  - `StatisticsService` - Analytics calculations
  - `LocationService` - GPS tracking
  - `HealthKitService` - Apple Health integration

### Design Patterns

- **MVVM**: Separation of concerns between Views and business logic
- **Coordinator Pattern**: Centralized navigation management
- **Dependency Injection**: ServiceContainer for loose coupling
- **Repository Pattern**: Services abstract data access
- **Observer Pattern**: Combine for reactive programming

### Features

- Real-time activity tracking with GPS
- Multiple activity types (walking, running, cycling, etc.)
- Statistics and data visualization
- User achievements and goals
- HealthKit integration
- Offline support with SwiftData

## Project Structure

```
AITouchGrass/
├── Modules/
│   ├── Core/
│   │   ├── Base/
│   │   ├── Extensions/
│   │   ├── Navigation/
│   │   ├── Protocols/
│   │   └── Services/
│   ├── Home/
│   │   ├── Coordinators/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   ├── Activity/
│   │   ├── Coordinators/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   ├── Profile/
│   │   ├── Coordinators/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   └── Statistics/
│       ├── Coordinators/
│       ├── Models/
│       ├── ViewModels/
│       └── Views/
├── AITouchGrassApp.swift
└── AppRootView.swift
```

## Getting Started

1. Open the project in Xcode
2. Build and run on iOS 17.0+ device or simulator
3. Grant necessary permissions (Location, HealthKit)

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+