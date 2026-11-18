import SwiftUI
import Model
import Kingfisher

// MARK: - Progress

/// Brand-colored loading spinner. Mirrors `CatArticlesCircularProgress`.
public struct CatProgressView: View {
    public init() {}
    public var body: some View {
        ProgressView()
            .tint(.catPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Async image (Kingfisher)

/// Cover-image loader backed by **Kingfisher** (`KFImage`) — async download,
/// memory + disk caching, and a fade-in. Replaces the Android sample's Landscapist.
public struct CatAsyncImage: View {
    private let urlString: String

    public init(_ urlString: String) {
        self.urlString = urlString
    }

    public var body: some View {
        KFImage(URL(string: urlString))
            .placeholder { Color.catSurfaceLight.opacity(0.4) }
            .resizable()
            .fade(duration: 0.25)
            .scaledToFill()
    }
}

// MARK: - Quota banner

/// Shows the daily free-reading quota. Mirrors the Android `QuotaBanner`.
public struct QuotaBanner: View {
    private let readCount: Int
    private let limit: Int

    public init(readCount: Int, limit: Int) {
        self.readCount = readCount
        self.limit = limit
    }

    private var limitReached: Bool { readCount >= limit }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: limitReached ? "lock.fill" : "book.fill")
            Text(limitReached
                 ? "Daily limit reached · Subscribe for unlimited access"
                 : "\(readCount) / \(limit) free articles read today")
                .font(.subheadline.weight(.medium))
            Spacer(minLength: 0)
        }
        .padding(12)
        .foregroundStyle(limitReached ? Color(hex: 0x8A6D00) : .primary)
        .background(limitReached ? Color(hex: 0xFFF3CD) : Color.catSurfaceLight.opacity(0.4))
        .clipShape(RoundedCornerShape(radius: 10))
    }
}

// MARK: - Premium badge

/// "Premium" pill for premium articles, with a lock while the user is not entitled.
/// Same dark translucent fill and white bold type as the card title banner, so it reads on photos.
public struct PremiumBadge: View {
    private let isLocked: Bool

    public init(isLocked: Bool) {
        self.isLocked = isLocked
    }

    public var body: some View {
        HStack(spacing: 4) {
            if isLocked {
                Image(systemName: "lock.fill")
            }
            Text("Premium")
        }
        .font(.system(size: 11, weight: .bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.65), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isLocked ? "Premium, locked" : "Premium")
    }
}

// MARK: - Article card

/// Grid cell for an article. Mirrors the Android/KMP card: a full-bleed cover
/// with the title in a translucent dark bottom banner (white text), and a
/// bookmark toggle top-right. 300pt tall, 6pt corners.
public struct ArticleCard: View {
    private let article: Article
    private let isBookmarked: Bool
    private let isPremiumUnlocked: Bool
    private let onBookmark: (() -> Void)?

    public init(
        article: Article,
        isBookmarked: Bool = false,
        isPremiumUnlocked: Bool = false,
        onBookmark: (() -> Void)? = nil
    ) {
        self.article = article
        self.isBookmarked = isBookmarked
        self.isPremiumUnlocked = isPremiumUnlocked
        self.onBookmark = onBookmark
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            CatAsyncImage(article.cover)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Translucent dark banner + white title (title only, no author).
            Text(article.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.black.opacity(0.65))
        }
        .frame(height: 300)
        .clipShape(RoundedCornerShape(radius: 6))
        .overlay(alignment: .topLeading) {
            if article.premium {
                PremiumBadge(isLocked: !isPremiumUnlocked)
                    .padding(10)
            }
        }
        .overlay(alignment: .topTrailing) {
            if let onBookmark {
                Button(action: onBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                        .padding(10)
                }
                .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Add bookmark")
            }
        }
    }
}

// MARK: - Shapes & modifiers

/// Rounded rectangle with a single corner radius (parity with Compose `RoundedCornerShape`).
public struct RoundedCornerShape: Shape {
    public var radius: CGFloat
    public init(radius: CGFloat) { self.radius = radius }
    public func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: radius)
    }
}

public extension View {
    /// Fades the bottom edge to transparent. Mirrors the Android `FadeEdge` modifier.
    func fadeBottomEdge(start: CGFloat = 0.55) -> some View {
        mask(
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: start),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
