import SwiftUI
import AppNavigation
import DataLayer
import DesignSystem
import FeatureHome
import FeatureArticle
import FeaturePaywalls
import FeatureAccount
import FeatureSubscriptions
import FeatureBookmarks

struct RootView: View {
    @Environment(Router.self) private var router
    @Environment(EntitlementStore.self) private var entitlementStore

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            HomeScreen()
                .navigationDestination(for: CatRoute.self, destination: destination)
        }
        .tint(.catPrimary)
        // Runs after `Purchases.configure(...)` in the App initializer.
        .task { entitlementStore.start() }
    }

    @ViewBuilder
    private func destination(for route: CatRoute) -> some View {
        switch route {
        case .article(let article): ArticleScreen(article: article)
        case .paywalls: PaywallsScreen()
        case .account: AccountScreen()
        case .subscriptionManagement: SubscriptionManagementScreen()
        case .bookmarks: BookmarksScreen()
        }
    }
}
