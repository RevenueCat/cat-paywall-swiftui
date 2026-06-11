import Foundation

enum Configuration {
    /// Your RevenueCat **App Store** API key (starts with `appl_`).
    ///
    /// Get it from the RevenueCat dashboard → Project Settings → API Keys.
    /// Until you set a real key, SDK calls return no offering / not-entitled,
    /// but the article feed (a public gist) still loads.
    static let revenueCatAPIKey = "appl_YOUR_REVENUECAT_API_KEY"
}
