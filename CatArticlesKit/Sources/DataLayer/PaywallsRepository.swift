import Foundation
import RevenueCat

/// Wraps the RevenueCat SDK behind an `async`/`await` surface.
/// Mirrors `core/data/PaywallsRepository.kt` from the Android sample.
///
/// API verified against `purchases-ios` 5.x (see memory `revenuecat-ios-sdk-reference`).
public protocol PaywallsRepository: Sendable {
    /// The current offering configured on the RevenueCat dashboard.
    func fetchCurrentOffering() async throws -> Offering
    /// The latest customer info (entitlements, active subscriptions, user id).
    func fetchCustomerInfo() async throws -> CustomerInfo
    /// Purchases a package; the result tuple reports `userCancelled`.
    func purchase(package: Package) async throws -> PurchaseResultData
    /// Identifies the user (links purchases across devices).
    @discardableResult func logIn(_ userID: String) async throws -> CustomerInfo
    /// Returns to an anonymous app user id.
    @discardableResult func logOut() async throws -> CustomerInfo
    /// Whether the current app user id is anonymous.
    var isAnonymous: Bool { get }
}

public struct RevenueCatPaywallsRepository: PaywallsRepository {
    public init() {}

    public func fetchCurrentOffering() async throws -> Offering {
        let offerings = try await Purchases.shared.offerings()
        guard let current = offerings.current else {
            throw PaywallsError.noCurrentOffering
        }
        return current
    }

    public func fetchCustomerInfo() async throws -> CustomerInfo {
        try await Purchases.shared.customerInfo()
    }

    public func purchase(package: Package) async throws -> PurchaseResultData {
        try await Purchases.shared.purchase(package: package)
    }

    @discardableResult
    public func logIn(_ userID: String) async throws -> CustomerInfo {
        let (customerInfo, _) = try await Purchases.shared.logIn(userID)
        return customerInfo
    }

    @discardableResult
    public func logOut() async throws -> CustomerInfo {
        try await Purchases.shared.logOut()
    }

    public var isAnonymous: Bool {
        Purchases.shared.isAnonymous
    }
}

public enum PaywallsError: LocalizedError {
    case noCurrentOffering

    public var errorDescription: String? {
        switch self {
        case .noCurrentOffering:
            return "No current offering is configured in RevenueCat. Add one in the dashboard."
        }
    }
}
