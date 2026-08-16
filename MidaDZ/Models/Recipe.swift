import Foundation

struct Recipe: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let arabicName: String
    let frenchName: String
    let englishName: String
    let imageName: String
    let shortDescription: String
    let regions: [Region]
    let categories: [RecipeCategory]
    let preparationMinutes: Int
    let cookingMinutes: Int
    let difficulty: Difficulty
    let servings: Int
    let ingredients: [Ingredient]
    let instructions: [String]
    let cookingTips: [String]
    let traditionalNote: String
    let tags: [String]

    var totalMinutes: Int { preparationMinutes + cookingMinutes }
    var totalTimeLabel: String { "\(totalMinutes) min" }
    var primaryRegion: Region { regions.first ?? .central }
    var primaryCategory: RecipeCategory { categories.first ?? .traditional }
}

struct Ingredient: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let quantity: Double
    let unit: String
    let note: String?

    func scaled(for servings: Int, baseServings: Int) -> String {
        let value = quantity * Double(servings) / Double(max(baseServings, 1))
        let formatted: String
        if value.rounded() == value {
            formatted = String(Int(value))
        } else {
            formatted = String(format: "%.1f", value)
        }
        return "\(formatted) \(unit)"
    }
}

enum Difficulty: String, Codable, CaseIterable, Hashable, Sendable {
    case easy
    case medium
    case advanced

    var label: String {
        switch self {
        case .easy: return String(localized: "difficulty.easy")
        case .medium: return String(localized: "difficulty.medium")
        case .advanced: return String(localized: "difficulty.advanced")
        }
    }
}

enum Region: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case algiers, oran, constantine, annaba, tlemcen, bejaia, setif, batna, ghardaia, laghouat, ouargla, tamanrasset, kabylie, sahara, aures, west, east, central

    var id: String { rawValue }

    var title: String {
        switch self {
        case .algiers: return "Algiers"
        case .oran: return "Oran"
        case .constantine: return "Constantine"
        case .annaba: return "Annaba"
        case .tlemcen: return "Tlemcen"
        case .bejaia: return "Béjaïa"
        case .setif: return "Sétif"
        case .batna: return "Batna"
        case .ghardaia: return "Ghardaïa"
        case .laghouat: return "Laghouat"
        case .ouargla: return "Ouargla"
        case .tamanrasset: return "Tamanrasset"
        case .kabylie: return "Kabylie"
        case .sahara: return "Sahara"
        case .aures: return "Aurès"
        case .west: return "Western Algeria"
        case .east: return "Eastern Algeria"
        case .central: return "Central Algeria"
        }
    }

    var shortDescription: String {
        switch self {
        case .kabylie: return "Mountain cooking, generous and bright"
        case .sahara: return "Desert pantry, deep flavours"
        case .aures: return "Highland dishes with character"
        case .west: return "Coastal warmth and festive tables"
        case .east: return "Robust stews and grain dishes"
        default: return "A taste of Algerian home cooking"
        }
    }
}

enum RecipeCategory: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case traditional, tajines, soups, breads, salads, meat, seafood, grains, potatoes, breakfast, pastries, sweets, desserts, drinks, ramadan, celebrations, tea, quick

    var id: String { rawValue }

    var title: String {
        switch self {
        case .traditional: return "Couscous & traditions"
        case .tajines: return "Tajines & stews"
        case .soups: return "Soups"
        case .breads: return "Breads & doughs"
        case .salads: return "Salads & starters"
        case .meat: return "Meat & chicken"
        case .seafood: return "Seafood"
        case .grains: return "Rice & grains"
        case .potatoes: return "Potato dishes"
        case .breakfast: return "Breakfast"
        case .pastries: return "Algerian pastries"
        case .sweets: return "Cookies & sweets"
        case .desserts: return "Traditional desserts"
        case .drinks: return "Drinks"
        case .ramadan: return "Ramadan"
        case .celebrations: return "Celebrations"
        case .tea: return "Tea & coffee"
        case .quick: return "Quick recipes"
        }
    }

    var symbol: String {
        switch self {
        case .traditional: return "leaf.fill"
        case .tajines: return "flame.fill"
        case .soups: return "cup.and.saucer.fill"
        case .breads: return "birthday.cake.fill"
        case .salads: return "carrot.fill"
        case .meat: return "fork.knife"
        case .seafood: return "fish.fill"
        case .grains: return "circle.grid.2x2.fill"
        case .potatoes: return "circle.fill"
        case .breakfast: return "sunrise.fill"
        case .pastries, .sweets, .desserts: return "birthday.cake"
        case .drinks, .tea: return "mug.fill"
        case .ramadan: return "moon.stars.fill"
        case .celebrations: return "sparkles"
        case .quick: return "bolt.fill"
        }
    }
}

struct RecipeFilter: Equatable, Sendable {
    var category: RecipeCategory?
    var region: Region?
    var difficulty: Difficulty?
    var maximumMinutes: Int?
    var query: String

    static let empty = RecipeFilter(category: nil, region: nil, difficulty: nil, maximumMinutes: nil, query: "")

    var isActive: Bool {
        category != nil || region != nil || difficulty != nil || maximumMinutes != nil || !query.isEmpty
    }
}
