import SwiftUI
import Model
import DataLayer
import DesignSystem
import AppNavigation
import RevenueCat

@MainActor
@Observable
final class ArticleModel {
    private(set) var offering: Offering?
    var showPromo = false
    private var dismissedPromo = false
    private let repository: PaywallsRepository

    init(repository: PaywallsRepository = RevenueCatPaywallsRepository()) {
        self.repository = repository
    }

    func onAppear(isPremium: Bool, tracker: ReadingTrackerStore, title: String) async {
        if !isPremium {
            tracker.recordArticleRead(title)
        }
        offering = try? await repository.fetchCurrentOffering()
        showPromo = !isPremium
            && tracker.todayReadCount >= CatConstants.freeArticlesPerDay
            && !dismissedPromo
    }

    func dismissPromo() {
        dismissedPromo = true
        showPromo = false
    }
}

public struct ArticleScreen: View {
    private let article: Article

    @Environment(Router.self) private var router
    @Environment(EntitlementStore.self) private var entitlement
    @Environment(ReadingTrackerStore.self) private var readingTracker
    @Environment(BookmarksStore.self) private var bookmarks
    @State private var model = ArticleModel()

    public init(article: Article) {
        self.article = article
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CatAsyncImage(article.cover)
                    .frame(height: 240)
                    .clipShape(RoundedCornerShape(radius: 12))

                Text(article.title).font(.largeTitle.bold())

                HStack {
                    Text(article.author)
                    Spacer()
                    Text(article.date)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(article.content).font(.body)
            }
            .padding(16)
        }
        .catBackground()
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { toggleBookmark() } label: {
                    Image(systemName: bookmarks.isBookmarked(article.title) ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .task { await model.onAppear(isPremium: entitlement.isPremium, tracker: readingTracker, title: article.title) }
        .sheet(isPresented: Binding(get: { model.showPromo }, set: { if !$0 { model.dismissPromo() } })) {
            PromoSheet(offering: model.offering) {
                model.dismissPromo()
                router.push(.paywalls)
            }
            .presentationDetents([.medium])
        }
    }

    private func toggleBookmark() {
        if entitlement.isPremium {
            bookmarks.toggle(article.title)
        } else {
            router.push(.paywalls)
        }
    }
}

/// Bottom sheet shown when a free user hits the daily limit (parity with the
/// Android article-detail promo sheet).
private struct PromoSheet: View {
    let offering: Offering?
    let onSubscribe: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.catPrimary)
            Text("You’ve reached today’s free limit")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Subscribe for unlimited access to every cat article.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let package = offering?.availablePackages.first {
                Text(package.storeProduct.localizedPriceString).font(.headline)
            }
            Button(action: onSubscribe) {
                Text("Subscribe").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.catPrimary)
            .controlSize(.large)
        }
        .padding(24)
    }
}
