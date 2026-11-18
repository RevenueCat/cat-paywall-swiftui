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
    /// Requires the `premium` entitlement to open.
    public let premium: Bool

    public var id: String { title }

    public init(
        title: String,
        content: String,
        description: String,
        author: String,
        date: String,
        cover: String,
        premium: Bool = false
    ) {
        self.title = title
        self.content = content
        self.description = description
        self.author = author
        self.date = date
        self.cover = cover
        self.premium = premium
    }

    /// The feed only sets `premium` on premium articles, so a missing key decodes as `false`.
    /// Encoding stays synthesized and always writes the key.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        description = try container.decode(String.self, forKey: .description)
        author = try container.decode(String.self, forKey: .author)
        date = try container.decode(String.self, forKey: .date)
        cover = try container.decode(String.self, forKey: .cover)
        premium = try container.decodeIfPresent(Bool.self, forKey: .premium) ?? false
    }
}
