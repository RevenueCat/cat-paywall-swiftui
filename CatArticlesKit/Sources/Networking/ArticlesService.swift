import Foundation
import Model

/// Fetches the article feed. Mirrors `core/network/CatArticlesService.kt`.
public protocol ArticlesService: Sendable {
    func fetchArticles() async throws -> [Article]
}

public enum Endpoints {
    /// Same public gist the Android & KMP samples read from.
    public static let articles = URL(
        string: "https://gist.githubusercontent.com/skydoves/f3836488f8d4f1bf3e3c239759d92c0d/raw/1376ef30281e9c9c0322c88281ea09d572b892a4/articles.json"
    )!
}

public struct RemoteArticlesService: ArticlesService {
    private let url: URL
    private let session: URLSession

    public init(url: URL = Endpoints.articles, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }

    public func fetchArticles() async throws -> [Article] {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try Self.decodeArticles(from: data)
    }

    /// The feed decoder. Internal so tests decode with exactly what production uses.
    static func decodeArticles(from data: Data) throws -> [Article] {
        try JSONDecoder().decode([Article].self, from: data)
    }
}
