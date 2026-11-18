import SwiftUI
import Model
import DataLayer
import DesignSystem
import AppNavigation
import FeaturePaywalls

@MainActor
@Observable
final class BookmarksModel {
    private(set) var state: LoadState<[Article]> = .loading
    private let repository: ArticlesRepository

    init(repository: ArticlesRepository = DefaultArticlesRepository()) {
        self.repository = repository
    }

    func load(bookmarkedTitles: Set<String>) async {
        do {
            let all = try await repository.fetchArticles()
            state = .loaded(all.filter { bookmarkedTitles.contains($0.title) })
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

public struct BookmarksScreen: View {
    @Environment(Router.self) private var router
    @Environment(BookmarksStore.self) private var bookmarks
    @Environment(EntitlementStore.self) private var entitlement
    @State private var model = BookmarksModel()
    @State private var premiumArticle: Article?

    public init() {}

    public var body: some View {
        Group {
            switch model.state {
            case .loading:
                CatProgressView()
            case .failed(let message):
                ContentUnavailableView("Couldn’t load", systemImage: "wifi.slash", description: Text(message))
            case .loaded(let articles):
                if articles.isEmpty {
                    ContentUnavailableView(
                        "No bookmarks yet",
                        systemImage: "bookmark",
                        description: Text("Bookmark articles to find them here.")
                    )
                } else {
                    List(articles) { article in
                        Button { open(article) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(article.title).font(.headline)
                                Text(article.author).font(.caption).foregroundStyle(.secondary)
                                if article.premium {
                                    PremiumBadge(isLocked: !entitlement.isPremium)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
        .catBackground()
        .task { await model.load(bookmarkedTitles: bookmarks.bookmarkedTitles) }
        .premiumPaywall(for: $premiumArticle) { router.push(.article($0)) }
    }

    /// Bookmarks were never quota gated, so only the premium part of the access rule applies here.
    private func open(_ article: Article) {
        if ArticleAccess.requiresPremiumPaywall(article: article, isEntitled: entitlement.isPremium) {
            premiumArticle = article
        } else {
            router.push(.article(article))
        }
    }
}
