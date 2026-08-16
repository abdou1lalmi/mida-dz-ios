import SwiftUI

@main
struct MidaDZApp: App {
    @StateObject private var catalog = RecipeCatalog()
    @StateObject private var library = UserLibraryStore()
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(catalog)
                .environmentObject(library)
                .environmentObject(settings)
                .environment(\.locale, settings.language.locale)
                .environment(\.layoutDirection, settings.language.isRTL ? .rightToLeft : .leftToRight)
                .preferredColorScheme(settings.useSystemAppearance ? nil : .light)
                .task { await catalog.load() }
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "safari.fill") }
                .tag(1)
            SavedView()
                .tabItem { Label("Saved", systemImage: "bookmark.fill") }
                .tag(2)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
        .tint(MidaColor.olive)
    }
}
