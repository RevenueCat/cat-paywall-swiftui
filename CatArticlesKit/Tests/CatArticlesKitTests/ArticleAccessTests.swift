import Testing
import Model
import DataLayer

struct ArticleAccessTests {
    private let limit = CatConstants.freeArticlesPerDay

    private func article(premium: Bool) -> Article {
        Article(title: "Cat", content: "", description: "", author: "", date: "", cover: "", premium: premium)
    }

    @Test func entitledUserOpensArticleAtQuota() {
        let access = ArticleAccess.evaluate(article: article(premium: false), isEntitled: true, todayReadCount: limit)
        #expect(access == .open)
    }

    @Test func nonEntitledUserGetsPremiumPaywallForPremiumArticle() {
        let access = ArticleAccess.evaluate(article: article(premium: true), isEntitled: false, todayReadCount: 1)
        #expect(access == .premiumPaywall)
    }

    @Test func nonEntitledUserAtQuotaGetsDailyLimitPaywall() {
        let access = ArticleAccess.evaluate(article: article(premium: false), isEntitled: false, todayReadCount: limit)
        #expect(access == .dailyLimitPaywall)
    }

    @Test func nonEntitledUserUnderQuotaOpensArticle() {
        let access = ArticleAccess.evaluate(article: article(premium: false), isEntitled: false, todayReadCount: limit - 1)
        #expect(access == .open)
    }

    @Test(arguments: [CatConstants.freeArticlesPerDay, CatConstants.freeArticlesPerDay + 4])
    func entitledUserOpensPremiumArticleAtOrOverQuota(todayReadCount: Int) {
        let access = ArticleAccess.evaluate(article: article(premium: true), isEntitled: true, todayReadCount: todayReadCount)
        #expect(access == .open)
    }

    @Test func nonEntitledUserWithNoReadsGetsPremiumPaywallNotQuotaPaywall() {
        let access = ArticleAccess.evaluate(article: article(premium: true), isEntitled: false, todayReadCount: 0)
        #expect(access == .premiumPaywall)
    }

    @Test func premiumGateWinsOverSpentQuota() {
        let access = ArticleAccess.evaluate(article: article(premium: true), isEntitled: false, todayReadCount: limit)
        #expect(access == .premiumPaywall)
    }

    @Test func premiumPartLocksOnlyPremiumArticlesWithoutEntitlement() {
        #expect(ArticleAccess.requiresPremiumPaywall(article: article(premium: true), isEntitled: false))
        #expect(!ArticleAccess.requiresPremiumPaywall(article: article(premium: true), isEntitled: true))
        #expect(!ArticleAccess.requiresPremiumPaywall(article: article(premium: false), isEntitled: false))
        #expect(!ArticleAccess.requiresPremiumPaywall(article: article(premium: false), isEntitled: true))
    }
}
