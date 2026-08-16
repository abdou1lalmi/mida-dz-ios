# MIDA DZ implementation report

## Experience contract

| Decision | Implementation |
| --- | --- |
| Primary job | Discover an Algerian recipe, save it, adjust servings, and cook it one step at a time. |
| Entry and exit | Users enter through Home, Discover, Saved, or Profile; recipe detail returns to the originating flow, while Cooking Mode exits back to detail. |
| Platforms | iPhone-first SwiftUI with iPad-safe adaptive stacks and Dynamic Type-friendly content. Arabic uses right-to-left layout direction; French and English are represented in the language architecture. |
| States | Catalog loading, populated content, search results, empty search, saved-empty, collection-empty, and local error state are represented. |
| Ownership | `RecipeCatalog` owns catalog and filter state; `UserLibraryStore` owns favorites, recent items, searches, and collections; `AppSettings` owns language and appearance. |
| Visual profile | Restrained native profile: semantic system controls, materials used as quiet surfaces, warm Algerian-inspired accents, no stacked glass or decorative shader work. |
| Evidence | Static SwiftUI audit and repository inspection are available in Linux; Xcode build, simulator, VoiceOver, and device performance verification require macOS/Xcode and remain unverified here. |

## Major implementation decisions

The application is local-first. `LocalRecipeRepository` is the seam for a later API-backed repository, while the view layer depends on `RecipeCatalog` rather than directly reaching into sample data. The seeded catalog contains 32 structured recipes with names, Arabic and French names, preparation and cooking times, difficulty, servings, ingredients, instructions, cooking tips, cultural notes, tags, categories, and regions.

Navigation uses a native `TabView` with four task-oriented sections and `NavigationStack` within each flow. Recipe detail uses a full-bleed hero abstraction, structured metadata, a serving `Stepper`, readable numbered preparation steps, and a primary Cooking Mode action. Cooking Mode owns one finite state, `stepIndex` plus `completed`, uses value-scoped spring transitions, exposes previous and next actions, keeps the screen awake while active, and offers an ingredient sheet.

The design system centralises palette, spacing, corner radius, card treatment, artwork placeholders, and metadata components. Food photography is represented through `MidaArtworkView`, an explicit asset abstraction that can later resolve bundled or remote editorial photography without changing any feature view.

## Accessibility and localization posture

Controls use native `Button`, `Toggle`, `Picker`, `Stepper`, `ShareLink`, `Label`, and `ContentUnavailableView` semantics. Favorite controls expose stateful labels and values. Cooking Mode respects Reduce Motion by disabling its spring animation path. The language setting changes locale and layout direction, with Arabic configured as right-to-left rather than only translated. All content is designed to remain readable under Dynamic Type, though final VoiceOver and large-content-size passes still require an Apple simulator.

## Verification commands

On macOS with XcodeGen and Xcode installed:

```bash
xcodegen generate
xcodebuild -project MidaDZ.xcodeproj -scheme MidaDZ -sdk iphonesimulator -configuration Debug build
xcodebuild test -project MidaDZ.xcodeproj -scheme MidaDZ -destination 'platform=iOS Simulator,name=iPhone 16'
python3 /home/ubuntu/skills/ios-native-uiux-development/scripts/audit_swiftui_ui.py . --profile native
```

## Known limitations

The current sandbox is Linux and does not include Swift or Xcode, so compilation, simulator snapshots, VoiceOver traversal, RTL visual verification, Instruments profiling, and actual device idle-timer behavior could not be executed here. The repository is therefore a production-oriented SwiftUI source foundation with a reproducible XcodeGen manifest, not a claimed device-verified App Store build. The artwork layer intentionally uses symbolic gradient placeholders until licensed photography is added to the asset catalog.
