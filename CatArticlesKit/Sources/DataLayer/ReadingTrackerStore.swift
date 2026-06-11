import Foundation
import Observation

/// Tracks how many articles a non-subscriber has read today (free quota).
/// Mirrors `core/data/ReadingTrackerRepository.kt` — same daily-reset rule and
/// `UserDefaults` keys (`last_reset_date`, `read_articles_today`).
@MainActor
@Observable
public final class ReadingTrackerStore {
    public private(set) var todayReadCount: Int = 0

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        refresh()
    }

    /// Records a read for `articleTitle`, resetting the set on a new day.
    public func recordArticleRead(_ articleTitle: String) {
        let today = Self.todayString()
        var titles: Set<String>
        if defaults.string(forKey: DefaultsKey.lastResetDate) != today {
            titles = [articleTitle]
            defaults.set(today, forKey: DefaultsKey.lastResetDate)
        } else {
            titles = Set(defaults.stringArray(forKey: DefaultsKey.readArticlesToday) ?? [])
            titles.insert(articleTitle)
        }
        defaults.set(Array(titles), forKey: DefaultsKey.readArticlesToday)
        todayReadCount = titles.count
    }

    private func refresh() {
        let today = Self.todayString()
        if defaults.string(forKey: DefaultsKey.lastResetDate) != today {
            todayReadCount = 0
        } else {
            todayReadCount = (defaults.stringArray(forKey: DefaultsKey.readArticlesToday) ?? []).count
        }
    }

    /// ISO `yyyy-MM-dd`, matching Kotlin's `LocalDate.now().toString()`.
    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
