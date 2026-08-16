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

## GitHub Actions build

The repository includes `.github/workflows/ios.yml`. It runs on a GitHub-hosted macOS 14 runner, installs XcodeGen, generates an Xcode 15-compatible project, builds the app for the iOS Simulator without signing, runs unit tests on an iPhone 16 simulator when available, and uploads a zipped simulator `.app` plus diagnostics. To run it manually, open the repository on GitHub, select **Actions → MIDA DZ iOS → Run workflow**, and open the completed run’s **Artifacts** section. The simulator artifact is for CI inspection and cannot be installed directly on a physical iPhone.

The same workflow includes a protected **signed-release** job. To use it, create a GitHub Environment named `ios-release`, add the Apple signing and App Store Connect secrets described in `docs/github-signing.md`, and run the workflow manually with **release = true**. The job archives the app for a physical iPhone, exports a signed IPA, uploads the IPA as an artifact, and can upload it to TestFlight when **upload_testflight = true**. It never runs for ordinary pushes or pull requests, and the signing material is read only from GitHub Secrets.

## Verification checklist

The intended QA pass covers navigation across all four tabs, search and filters, favorite persistence, detail ingredient scaling, Cooking Mode progression and completion, Arabic RTL, French and English copy, dark mode, Dynamic Type, VoiceOver labels, Reduce Motion, empty and error states, and representative iPhone and iPad sizes. The static SwiftUI audit command is documented in `docs/implementation-report.md`.
