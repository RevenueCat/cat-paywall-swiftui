import SwiftUI
import RevenueCat
import AppNavigation
import DataLayer

@main
struct CatArticlesApp: App {
    // Created before `init()` body runs; touches only UserDefaults (not Purchases).
    @State private var container = AppContainer()

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Configuration.revenueCatAPIKey)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container.router)
                .environment(container.entitlementStore)
                .environment(container.readingTracker)
                .environment(container.bookmarks)
        }
    }
}
