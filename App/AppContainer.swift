import Observation
import AppNavigation
import DataLayer

/// Composition root. Owns the long-lived observable stores and the router,
/// injected into the SwiftUI environment. (Repositories are stateless and
/// created where used.) Mirrors the role of the Hilt/Metro graph.
@MainActor
@Observable
final class AppContainer {
    let router = Router()
    let entitlementStore = EntitlementStore()
    let readingTracker = ReadingTrackerStore()
    let bookmarks = BookmarksStore()

    init() {}
}
