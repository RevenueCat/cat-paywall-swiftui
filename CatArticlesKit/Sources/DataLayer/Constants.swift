import Foundation

/// App-wide constants shared with the Android/KMP samples for true parity.
public enum CatConstants {
    /// RevenueCat entitlement that unlocks premium (unlimited reading + bookmarking).
    public static let premiumEntitlementID = "premium"

    /// Free articles a non-subscriber may read per day.
    public static let freeArticlesPerDay = 3
}

/// `UserDefaults` keys — same string keys the Android DataStore uses.
enum DefaultsKey {
    static let lastResetDate = "last_reset_date"
    static let readArticlesToday = "read_articles_today"
    static let bookmarkedArticles = "bookmarked_articles"
}
