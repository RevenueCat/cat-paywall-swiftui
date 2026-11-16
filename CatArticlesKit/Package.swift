// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CatArticlesKit",
    platforms: [.iOS(.v17)],
    products: [
        // Single umbrella product the app links against.
        .library(
            name: "CatArticlesKit",
            targets: [
                "Model", "Networking", "DataLayer", "DesignSystem", "AppNavigation",
                "FeatureHome", "FeatureArticle", "FeaturePaywalls",
                "FeatureAccount", "FeatureSubscriptions", "FeatureBookmarks",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "5.103.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.16.0"),
    ],
    targets: [
        // MARK: Core
        .target(name: "Model"),
        .target(name: "Networking", dependencies: ["Model"]),
        .target(
            name: "DataLayer",
            dependencies: [
                "Model", "Networking",
                .product(name: "RevenueCat", package: "purchases-ios"),
            ]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
                "Model",
                .product(name: "Kingfisher", package: "Kingfisher"),
            ]
        ),
        .target(name: "AppNavigation", dependencies: ["Model"]),

        // MARK: Features
        .target(
            name: "FeatureHome",
            dependencies: [
                "Model", "DataLayer", "DesignSystem", "AppNavigation",
                .product(name: "RevenueCat", package: "purchases-ios"),
            ]
        ),
        .target(
            name: "FeatureArticle",
            dependencies: [
                "Model", "DataLayer", "DesignSystem", "AppNavigation",
                .product(name: "RevenueCat", package: "purchases-ios"),
            ]
        ),
        .target(
            name: "FeaturePaywalls",
            dependencies: [
                "Model", "DataLayer", "DesignSystem", "AppNavigation",
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "RevenueCatUI", package: "purchases-ios"),
            ]
        ),
        .target(
            name: "FeatureAccount",
            dependencies: [
                "Model", "DataLayer", "DesignSystem", "AppNavigation",
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "RevenueCatUI", package: "purchases-ios"),
            ]
        ),
        .target(
            name: "FeatureSubscriptions",
            dependencies: [
                "Model", "DataLayer", "DesignSystem", "AppNavigation",
                .product(name: "RevenueCat", package: "purchases-ios"),
            ]
        ),
        .target(
            name: "FeatureBookmarks",
            dependencies: ["Model", "DataLayer", "DesignSystem", "AppNavigation"]
        ),
    ]
)
