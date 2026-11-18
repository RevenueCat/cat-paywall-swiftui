import SwiftUI
import Model
import DataLayer
import DesignSystem
import AppNavigation
import FeaturePaywalls

@MainActor
@Observable
final class HomeModel {
    private(set) var state: LoadState<[Article]> = .loading
    private let repository: ArticlesRepository

    init(repository: ArticlesRepository = DefaultArticlesRepository()) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await repository.fetchArticles())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

public struct HomeScreen: View {
    @Environment(Router.self) private var router
    @Environment(EntitlementStore.self) private var entitlement
    @Environment(ReadingTrackerStore.self) private var readingTracker
    @Environment(BookmarksStore.self) private var bookmarks
    @State private var model = HomeModel()
    @State private var premiumArticle: Article?

    public init() {}

    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    public var body: some View {
        ScrollView {
            if !entitlement.isPremium {
                QuotaBanner(readCount: readingTracker.todayReadCount, limit: CatConstants.freeArticlesPerDay)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }

            switch model.state {
            case .loading:
                CatProgressView().frame(height: 320)
            case .failed(let message):
                ContentUnavailableView("Couldn’t load articles", systemImage: "wifi.slash", description: Text(message))
                    .frame(height: 320)
            case .loaded(let articles):
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(articles) { article in
                        Button { open(article) } label: {
                            ArticleCard(
                                article: article,
                                isBookmarked: bookmarks.isBookmarked(article.title),
                                isPremiumUnlocked: entitlement.isPremium,
                                onBookmark: { toggleBookmark(article) }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
        }
        .catBackground()
        .navigationTitle("Cat Articles")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { router.push(.bookmarks) } label: { Image(systemName: "bookmark") }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { router.push(.subscriptionManagement) } label: { Image(systemName: "creditcard") }
                Button { router.push(.account) } label: { Image(systemName: "person.crop.circle") }
            }
        }
        .task { await model.load() }
        .premiumPaywall(for: $premiumArticle) { router.push(.article($0)) }
    }

    private func open(_ article: Article) {
        switch ArticleAccess.evaluate(
            article: article,
            isEntitled: entitlement.isPremium,
            todayReadCount: readingTracker.todayReadCount
        ) {
        case .open: router.push(.article(article))
        case .premiumPaywall: premiumArticle = article
        case .dailyLimitPaywall: router.push(.paywalls)
        }
    }

    /// Bookmarking is a premium feature.
    private func toggleBookmark(_ article: Article) {
        if entitlement.isPremium {
            bookmarks.toggle(article.title)
        } else {
            router.push(.paywalls)
        }
    }
}
