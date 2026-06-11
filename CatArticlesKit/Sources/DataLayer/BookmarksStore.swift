import Foundation
import Observation

/// Persists bookmarked article titles. Mirrors `core/data/BookmarksRepository.kt`
/// (key `bookmarked_articles`, stored as a set of titles).
@MainActor
@Observable
public final class BookmarksStore {
    public private(set) var bookmarkedTitles: Set<String> = []

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        bookmarkedTitles = Set(defaults.stringArray(forKey: DefaultsKey.bookmarkedArticles) ?? [])
    }

    public func isBookmarked(_ title: String) -> Bool {
        bookmarkedTitles.contains(title)
    }

    public func toggle(_ title: String) {
        if bookmarkedTitles.contains(title) {
            bookmarkedTitles.remove(title)
        } else {
            bookmarkedTitles.insert(title)
        }
        defaults.set(Array(bookmarkedTitles), forKey: DefaultsKey.bookmarkedArticles)
    }
}
