import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var catalog: RecipeCatalog
    @EnvironmentObject private var library: UserLibraryStore

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MIDA DZ").font(.system(size: 30, weight: .bold, design: .rounded)).foregroundStyle(MidaColor.olive)
                        Text("A table full of stories.").font(.body).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                Section("Preferences") {
                    Picker("Language", selection: $settings.language) {
                        ForEach(AppLanguage.allCases) { language in Text(language.title).tag(language) }
                    }
                    Toggle("Use system appearance", isOn: $settings.useSystemAppearance)
                }
                Section("Your kitchen") {
                    LabeledContent("Favourites", value: "\(library.favoriteIDs.count)")
                    LabeledContent("Recently viewed", value: "\(library.recentRecipeIDs.count)")
                    LabeledContent("Recipes available offline", value: "\(catalog.recipes.count)")
                }
                Section("About MIDA DZ") {
                    Label("Algerian cuisine, thoughtfully organised", systemImage: "leaf.fill")
                    Label("Local-first by design", systemImage: "icloud.slash")
                    Label("Built for calm, confident cooking", systemImage: "flame.fill")
                }
            }
            .navigationTitle("Profile")
        }
    }
}
