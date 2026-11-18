import Foundation
import Testing
import Model
@testable import Networking

struct ArticleDecodingTests {
    private func decodeSingle(_ json: String) throws -> Article {
        let articles = try RemoteArticlesService.decodeArticles(from: Data(json.utf8))
        return try #require(articles.first)
    }

    @Test func missingPremiumKeyDecodesAsFalse() throws {
        let article = try decodeSingle("""
        [{"title": "Effective Kotlin", "content": "c", "description": "d",
          "author": "a", "date": "2025", "cover": "https://example.com/c.jpg"}]
        """)
        #expect(article.premium == false)
    }

    @Test func premiumTrueDecodesAsTrue() throws {
        let article = try decodeSingle("""
        [{"title": "Modern Android Testing", "content": "c", "description": "d",
          "author": "a", "date": "2025", "cover": "https://example.com/c.jpg", "premium": true}]
        """)
        #expect(article.premium == true)
    }

    @Test func encodedArticleDecodesBackUnchanged() throws {
        let original = Article(title: "T", content: "c", description: "d", author: "a", date: "2025", cover: "x", premium: true)
        let decoded = try RemoteArticlesService.decodeArticles(from: JSONEncoder().encode([original]))
        #expect(decoded == [original])
    }
}
