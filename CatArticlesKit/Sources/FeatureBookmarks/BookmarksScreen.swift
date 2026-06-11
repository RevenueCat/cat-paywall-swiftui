import SwiftUI
import Model
import DataLayer
import DesignSystem
import AppNavigation

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
    @State private var model = BookmarksModel()

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
                        Button { router.push(.article(article)) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(article.title).font(.headline)
                                Text(article.author).font(.caption).foregroundStyle(.secondary)
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
    }
}
