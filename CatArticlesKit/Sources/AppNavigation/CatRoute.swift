import Model

/// Navigation destinations. Mirrors `core/navigation/CatArticlesScreen.kt`.
/// `home` is the `NavigationStack` root and so is not a case here.
public enum CatRoute: Hashable {
    case article(Article)
    case paywalls
    case account
    case subscriptionManagement
    case bookmarks
}
