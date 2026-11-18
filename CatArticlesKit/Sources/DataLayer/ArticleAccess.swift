import Model

/// What tapping an article should do. Shared by the home grid and bookmarks.
public enum ArticleAccess: Equatable, Sendable {
    case open
    /// Premium article without the entitlement: present the premium paywall.
    case premiumPaywall
    /// Daily free quota spent: the existing paywall route.
    case dailyLimitPaywall

    /// Evaluated in order: entitlement, premium flag, daily quota. A premium article is
    /// never opened without the entitlement, and the daily free quota never gates it.
    public static func evaluate(
        article: Article,
        isEntitled: Bool,
        todayReadCount: Int,
        dailyLimit: Int = CatConstants.freeArticlesPerDay
    ) -> ArticleAccess {
        if isEntitled { return .open }
        if requiresPremiumPaywall(article: article, isEntitled: isEntitled) { return .premiumPaywall }
        if todayReadCount >= dailyLimit { return .dailyLimitPaywall }
        return .open
    }

    /// The premium part of `evaluate` on its own, for entry points that are not quota gated.
    public static func requiresPremiumPaywall(article: Article, isEntitled: Bool) -> Bool {
        article.premium && !isEntitled
    }
}
