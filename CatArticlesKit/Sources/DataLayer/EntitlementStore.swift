import Foundation
import Observation
import RevenueCat

/// Observable source of truth for the user's subscription state.
/// Keeps `CustomerInfo` live via `Purchases.shared.customerInfoStream`.
///
/// `start()` must be called *after* `Purchases.configure(...)`.
@MainActor
@Observable
public final class EntitlementStore {
    public private(set) var customerInfo: CustomerInfo?

    private var didStart = false

    public init() {}

    /// `true` when the `premium` entitlement is active.
    public var isPremium: Bool {
        customerInfo?.entitlements[CatConstants.premiumEntitlementID]?.isActive == true
    }

    public var isAnonymous: Bool {
        Purchases.shared.isAnonymous
    }

    /// Begins observing customer info. Idempotent.
    public func start() {
        guard !didStart else { return }
        didStart = true

        Task { @MainActor in
            self.customerInfo = try? await Purchases.shared.customerInfo()
        }
        Task { @MainActor in
            for await info in Purchases.shared.customerInfoStream {
                self.customerInfo = info
            }
        }
    }
}
