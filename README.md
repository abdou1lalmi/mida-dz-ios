# MIDA DZ

MIDA DZ is a native SwiftUI recipe discovery and cooking companion for Algerian cuisine. The project is intentionally local-first: recipes, favorites, search, serving adjustment, collections, and Cooking Mode work without a network connection, while the repository boundaries leave room for future synchronization, authentication, subscriptions, and analytics.

## Product direction

The interface follows a restrained native iOS profile with warm saffron, olive, and clay accents inspired by Algerian food culture rather than flag colors. Native navigation, semantic controls, Dynamic Type, dark mode, RTL-ready layout direction, Reduce Motion handling, and local persistence are first-class requirements.

## Project structure

| Area | Responsibility |
| --- | --- |
| `MidaDZ/App` | App entry point and root dependency composition |
| `MidaDZ/Models` | Recipe, ingredient, category, region, and filter value types |
| `MidaDZ/Data` | Seeded offline recipe catalog |
| `MidaDZ/Services` | Repository boundary for local and future remote content |
| `MidaDZ/Core/DesignSystem` | Tokens and reusable visual primitives |
| `MidaDZ/Core/Localization` | Language selection and RTL-aware presentation helpers |
| `MidaDZ/Core/Persistence` | User-owned favorites, recent searches, and collections |
| `MidaDZ/ViewModels` | Screen state and business logic |
| `MidaDZ/Views` | Feature screens and reusable components |

## Requirements

The source targets iOS 17 or later and uses Swift 5.9+, SwiftUI, Observation-compatible state patterns, async/await boundaries, and `UserDefaults` for the initial local persistence layer. A Mac with Xcode is required to build and run the application; this repository was authored in a Linux environment, so Xcode build and simulator verification remain to be performed on Apple hardware.

## Opening the project

The repository includes `project.yml` for [XcodeGen](https://github.com/yonaskolb/XcodeGen). From a Mac with XcodeGen installed, run:

```bash
xcodegen generate
open MidaDZ.xcodeproj
```

Alternatively, create an iOS App target in Xcode named `MidaDZ`, add the `MidaDZ` and `MidaDZTests` folders, and set the deployment target to iOS 17.0.

## Verification checklist

The intended QA pass covers navigation across all four tabs, search and filters, favorite persistence, detail ingredient scaling, Cooking Mode progression and completion, Arabic RTL, French and English copy, dark mode, Dynamic Type, VoiceOver labels, Reduce Motion, empty and error states, and representative iPhone and iPad sizes. The static SwiftUI audit command is documented in `docs/implementation-report.md`.
