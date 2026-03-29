import Foundation
import SwiftUI

enum RarityTier: String, CaseIterable, Identifiable {
    case n = "N"
    case r = "R"
    case sr = "SR"
    case ssr = "SSR"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .n: .gray
        case .r: .blue
        case .sr: .purple
        case .ssr: .orange
        }
    }
}

enum BlindBoxCategory: String, CaseIterable, Identifiable {
    case daily = "活力日常"
    case urban = "城市跑场"
    case legend = "冠军传说"

    var id: String { rawValue }

    var keyCost: Int {
        switch self {
        case .daily: 1
        case .urban: 2
        case .legend: 3
        }
    }
}

struct HealthSnapshot {
    var moveCalories: Int
    var steps: Int
    var distance: Double
    var standHours: Int
    var winStreak: Int
    var weeklyGoalHits: Int
    var goalCalories: Int
}

struct Collectible: Identifiable, Hashable {
    let id: UUID
    let remoteCardID: Int?
    let name: String
    let series: String
    let rarity: RarityTier
    let style: String
    let chainValue: Int
    let isFavorite: Bool
    let imageURL: String?
    let ownedCount: Int
}

struct BlindBox: Identifiable, Hashable {
    let id: UUID
    let remoteSeriesID: Int?
    let title: String
    let category: BlindBoxCategory
    let subtitle: String
    let releaseDateText: String
    let priceInCoins: Int
    let keyCost: Int
    let highlight: String
    let rarityRates: [RarityTier: Int]
    let imageURL: String?
    let previewCards: [BlindBoxCardPreview]
}

struct BlindBoxCardPreview: Identifiable, Hashable {
    let id: UUID
    let remoteCardID: Int?
    let name: String
    let rarity: RarityTier
    let description: String
    let imageURL: String?
}

struct MarketListing: Identifiable {
    enum ListingType: String {
        case key = "钥匙"
        case collectible = "数字藏品"
    }

    let id: UUID
    let title: String
    let type: ListingType
    let price: Int
    let chainValue: Int
    let seller: String
    let subtitle: String
}

struct ActivityEntry: Identifiable {
    let id: UUID
    let title: String
    let detail: String
    let timestamp: String
}

struct UserProfile {
    var userId: String
    var name: String
    var email: String?
    var vitalityCoins: Int
    var keys: Int
    var totalBoxes: Int
}
