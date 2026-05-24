# HealthTracker

Personal daily health tracking app with AI-powered clinical analysis.

## Overview

HealthTracker is a native iOS app that lets you log your daily workouts, meals, hydration, and biometric data, then receive a personalized clinical-sports analysis powered by the Anthropic API.

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Local Persistence | SwiftData |
| Sync | CloudKit (iCloud) |
| AI | Anthropic API — `claude-sonnet-4-20250514` |
| Architecture | Clean Architecture (Domain / Data / Presentation) |
| Concurrency | Swift Concurrency (`async/await`) |

## Features

- **Daily Report** — Log exercises, meals, hydration, energy, sleep, glucose, and blood pressure
- **AI Analysis** — Clinical-sports evaluation with metabolic breakdown, functional assessment, and longevity insights
- **Traffic Light** — Daily health indicator (green / yellow / red)
- **History** — Browse past reports and their saved AI analyses
- **Catalogs** — Manage your exercise and food libraries with custom entries
- **iCloud Sync** — Data synced automatically across your devices

## Architecture

```
App/
├── Features/
│   ├── HealthTracker/
│   │   ├── Domain/        # Entities, Use Cases, Repository protocols
│   │   ├── Data/          # SwiftData models, API clients, mappers
│   │   └── Presentation/  # SwiftUI views, ViewModels
│   ├── Settings/
│   ├── Subscription/
│   └── Profile/
├── Core/
│   ├── DI/                # Dependency injection container
│   ├── Networking/        # Base HTTP client
│   ├── Persistence/       # ModelContainer factory
│   ├── Configuration/     # Environment, feature flags
│   └── DesignSystem/      # Colors, typography, components
└── App/
    ├── HealthTrackerApp.swift
    └── AppCoordinator.swift
```

## Getting Started

### Requirements

- Xcode 15+
- iOS 17+
- An [Anthropic API key](https://console.anthropic.com/)

### Setup

1. Clone the repo
2. Open `HealthTracker.xcodeproj` in Xcode
3. Build and run on your device or simulator
4. On first launch, enter your Anthropic API key — it will be stored securely in the Keychain

> **Note:** The API key is never stored in code, UserDefaults, or SwiftData. Keychain only.

## Design

- Dark mode exclusive
- Accent: `#82B1FF`
- Traffic light: `#4CAF82` green · `#F6C453` yellow · `#F07070` red

## License

Private — All rights reserved.
