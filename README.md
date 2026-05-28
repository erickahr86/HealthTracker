# HealthTracker

Personal daily health tracking app with AI-powered clinical-sports analysis.

## Overview

HealthTracker is a native iOS app that lets you log your daily workouts, meals, hydration, and biometric data, then receive a personalized clinical analysis from an AI model. The analysis evaluates metabolic balance, functional training, longevity indicators, and gives you one concrete action for the next day — all rated with a traffic-light score (🟢🟡🔴).

The app is tailored for a user with metabolic syndrome (diabetes, hypertension, high triglycerides, fatty liver) who trains 3 days a week and wants evidence-based, medically-aware feedback.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Local Persistence | SwiftData |
| AI | Anthropic API (`claude-sonnet-4-20250514`) · Google Gemini |
| Architecture | Clean Architecture (Domain / Data / Presentation) |
| Concurrency | Swift Concurrency (`async/await`, `@MainActor`) |
| Secret Storage | Keychain Services |

> **Note:** iCloud/CloudKit sync is not enabled. All data is stored locally on-device. This is intentional — the app targets personal Apple developer accounts which do not support iCloud capabilities.

---

## Features

- **Daily Report** — Log exercises (with weight), meals per slot (breakfast / lunch / dinner / snack), hydration, energy, sleep, glucose, and blood pressure
- **AI Analysis** — Clinical-sports evaluation with metabolic breakdown, functional assessment, longevity insights, and a daily micro-mission
- **Traffic Light** — Daily health indicator (🟢 green / 🟡 yellow / 🔴 red) persisted with each report
- **History** — Browse all past reports with their saved AI analyses; read-only detail view
- **Catalogs** — Manage your exercise library (grouped by muscle group) and food library (grouped by category), with custom entries
- **Onboarding** — First-launch setup: collects user profile and seeds the default exercise/food catalogs
- **Settings** — Update your user profile, enter or rotate AI provider API keys (stored in Keychain only), choose preferred AI model
- **Multi-provider AI** — Anthropic and Gemini implemented; OpenAI stub ready for future integration

---

## Architecture

Clean Architecture, feature-sliced. Features never depend on each other — only on Core.

```
HealthTracker/
├── App/
│   └── AppCoordinatorView.swift          # Root: Onboarding → TabView
│
├── Core/
│   ├── DI/                               # AppContainer, FeatureFactory, ProviderFactory
│   ├── DesignSystem/                     # HT* tokens (colors, spacing, typography, dimensions)
│   │   └── Components/                  # SectionHeader, HTButton, TrafficLightBadge, …
│   ├── Persistence/                      # ModelContainerFactory (SwiftData, local only)
│   └── Utilities/                        # Strings.swift, KeychainService, Logger
│
└── Features/
    ├── HealthTracker/                    # Main feature — full Clean Architecture
    │   ├── Domain/
    │   │   ├── Entities/                 # DailyReport, Exercise, Food, MealLog, …
    │   │   ├── Repositories/             # Protocol definitions
    │   │   ├── UseCases/                 # Business logic
    │   │   └── Providers/                # LLMProvider protocol
    │   ├── Data/
    │   │   ├── Models/                   # SwiftData @Model classes
    │   │   ├── Mappers/                  # Domain ↔ SwiftData model translation
    │   │   ├── Repositories/             # Protocol implementations
    │   │   └── Remote/Providers/         # Anthropic, Gemini, OpenAI (stub)
    │   └── Presentation/
    │       └── DailyReport/              # DailyReportView + DailyReportViewModel
    │
    ├── History/                          # ReportHistoryView, ReportDetailView
    ├── Catalog/                          # CatalogsView, ExerciseCatalogView, FoodCatalogView
    ├── Onboarding/                       # OnboardingView + seed use cases
    ├── Settings/                         # SettingsView, UserProfileView
    ├── Profile/                          # (placeholder)
    └── Subscription/                     # (placeholder)
```

### Dependency Injection

```
AppContainer  →  FeatureFactory (use cases on demand)  →  ViewModels
                └──  ProviderFactory  →  AI clients
```

Every view receives `AppContainer` and creates its own ViewModel. `AppContainer.preview` provides an in-memory SwiftData store for Xcode Previews.

---

## Getting Started

### Requirements

- Xcode 16+
- iOS 17+ device or simulator
- An [Anthropic API key](https://console.anthropic.com/) and/or a [Google AI Studio key](https://aistudio.google.com/)

### Setup

1. Clone the repo
2. Open `HealthTracker.xcodeproj` in Xcode
3. Select your personal team in **Signing & Capabilities**
4. Build and run on your device or simulator
5. On first launch, complete the onboarding flow, then go to **Settings → API Keys** and enter your key(s)

> **API keys are stored exclusively in Keychain** — never in code, UserDefaults, or SwiftData.

---

## Default Seed Data

Seeded once on first launch (no-op after that).

### Exercises

| Muscle Group | Exercises |
|---|---|
| Lower body | Leg Extension, Leg Press, Seated Leg Curl, Abductores Abrir/Cerrar, Hip Thrust, Calf Extension, Glute Machine |
| Upper body | Dominadas Asistidas, Fondos Paralelas, Shoulder Press, Chest Press, Seated Row, Lat Pulldown, Biceps Curl, Triceps Press, Pec Fly, Rear Delt |

### Foods

Avena, Crema de Cacahuate, Crema de Almendra, Huevos, Frijoles Refritos, Tortillas de Maíz, Manzana, Pollo Air Fryer, Carne de Cerdo, Pepinos, Papas al Vapor, Pan Masa Madre, Beef Jerky Mesquite, Galletas Marías, Jitomate.

---

## AI Analysis Format

The AI returns a structured response in Spanish, parsed into four sections:

| Section | Tag |
|---|---|
| Clinical Metabolic Analysis | `[METABOLIC]` |
| Functional Evaluation | `[FUNCTIONAL]` |
| Longevity & Prevention | `[LONGEVITY]` |
| Tomorrow's Micro-Mission | `[MISSION]` |

The traffic-light score (`VERDE` / `AMARILLO` / `ROJO`) is extracted and persisted with the report.

---

## Design

- Dark mode exclusive
- **Accent:** `#82B1FF`
- **Background:** `#0F1117` · **Surface:** `#1A1D26` · **Surface variant:** `#22263A`
- **Traffic light:** `#4CAF82` green · `#F6C453` yellow · `#F07070` red
- Cards: `cornerRadius(16)`, border `#2E3650`
- Typography: SF Pro (system), weights regular / medium / bold
- No face, body part, or rocket emojis anywhere in the UI

---

## Localization

English and Spanish (`en.lproj` / `es.lproj`). All string keys live in `Core/Utilities/Strings.swift`.

---

## License

Private — All rights reserved.
