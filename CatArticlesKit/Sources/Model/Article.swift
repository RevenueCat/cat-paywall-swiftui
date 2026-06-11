import Foundation

/// A cat article. Mirrors `core/model/Article.kt` from the Android sample.
///
/// Identity is the `title` (bookmarks and the reading tracker key off the title),
/// matching how the Android/KMP samples track read + bookmarked articles.
public struct Article: Codable, Identifiable, Hashable, Sendable {
    public let title: String
    public let content: String
    public let description: String
    public let author: String
    public let date: String
    public let cover: String

    public var id: String { title }

    public init(
        title: String,
        content: String,
        description: String,
        author: String,
        date: String,
        cover: String
    ) {
        self.title = title
        self.content = content
        self.description = description
        self.author = author
        self.date = date
        self.cover = cover
    }
}
