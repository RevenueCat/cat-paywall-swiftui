import Foundation
import Model
import Networking

/// Exposes article data to the app. Mirrors `core/data/ArticlesRepository.kt`.
public protocol ArticlesRepository: Sendable {
    func fetchArticles() async throws -> [Article]
}

public struct DefaultArticlesRepository: ArticlesRepository {
    private let service: ArticlesService

    public init(service: ArticlesService = RemoteArticlesService()) {
        self.service = service
    }

    public func fetchArticles() async throws -> [Article] {
        try await service.fetchArticles()
    }
}
