import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case arabic = "ar"
    case french = "fr"
    case english = "en"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .arabic: return "العربية"
        case .french: return "Français"
        case .english: return "English"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }
    var isRTL: Bool { self == .arabic }
}

@MainActor
final class AppSettings: ObservableObject {
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Keys.language) }
    }
    @Published var useSystemAppearance: Bool {
        didSet { UserDefaults.standard.set(useSystemAppearance, forKey: Keys.systemAppearance) }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: Keys.language).flatMap(AppLanguage.init(rawValue:))
        language = stored ?? .english
        useSystemAppearance = UserDefaults.standard.object(forKey: Keys.systemAppearance) as? Bool ?? true
    }

    private enum Keys {
        static let language = "mida.language"
        static let systemAppearance = "mida.systemAppearance"
    }
}
