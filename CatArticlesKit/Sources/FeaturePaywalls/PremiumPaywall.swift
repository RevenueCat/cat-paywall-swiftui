import SwiftUI
import Model
import DataLayer
import RevenueCat
import RevenueCatUI

@MainActor
@Observable
final class PremiumPaywallModel {
    /// Drives `presentPaywall(offering:)`; RevenueCatUI resets it to `nil` when the paywall closes.
    var offering: Offering?
    var errorMessage: String?
    private var unlockedPremium = false
    private let repository: PaywallsRepository

    init(repository: PaywallsRepository = RevenueCatPaywallsRepository()) {
        self.repository = repository
    }

    func load() async {
        do {
            let current = try await repository.fetchCurrentOffering()
            guard !Task.isCancelled else { return }
            offering = current
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }

    /// RevenueCatUI closes the paywall after any successful purchase, and after a restore that
    /// found any purchase, so closing alone does not mean `premium` is active. Checking the
    /// transaction's own `CustomerInfo` keeps this independent of when `EntitlementStore` updates.
    func purchaseOrRestoreCompleted(_ customerInfo: CustomerInfo) {
        if customerInfo.entitlements[CatConstants.premiumEntitlementID]?.isActive == true {
            unlockedPremium = true
        }
    }

    /// Ends the presentation and reports whether it unlocked `premium`.
    func finish() -> Bool {
        defer { unlockedPremium = false }
        return unlockedPremium
    }
}

private struct PremiumPaywallModifier: ViewModifier {
    @Binding var article: Article?
    let onUnlock: (Article) -> Void

    @State private var model = PremiumPaywallModel()

    func body(content: Content) -> some View {
        let model = model
        content
            .task(id: article) {
                guard let requested = article else { return }
                await model.load()
                // Leaving the screen mid-load cancels the task. Drop the request, or it would
                // resurface as an unprompted paywall when the screen appears again.
                if Task.isCancelled, article == requested { article = nil }
            }
            .presentPaywall(
                offering: Bindable(model).offering,
                purchaseCompleted: { model.purchaseOrRestoreCompleted($0) },
                restoreCompleted: { model.purchaseOrRestoreCompleted($0) },
                // Fires once, after the paywall and any exit offer are fully dismissed, so the
                // push below never races a sheet that is still on screen.
                onDismiss: {
                    let unlocked = model.finish()
                    let tapped = article
                    article = nil
                    if unlocked, let tapped { onUnlock(tapped) }
                }
            )
            .alert(
                "No paywall available",
                isPresented: Binding(
                    get: { model.errorMessage != nil },
                    set: { if !$0 { model.errorMessage = nil; article = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(model.errorMessage ?? "")
            }
    }
}

public extension View {
    /// Presents the premium paywall for `article` while it is non-nil.
    ///
    /// Uses `presentPaywall(offering:)` because it shows the dashboard-configured exit offer when
    /// the user closes the paywall; a `PaywallView` in a plain sheet does not. If a purchase or
    /// restore activates `premium`, `onUnlock` receives the article once everything is dismissed.
    /// Otherwise `article` is reset and the user stays where they were.
    func premiumPaywall(for article: Binding<Article?>, onUnlock: @escaping (Article) -> Void) -> some View {
        modifier(PremiumPaywallModifier(article: article, onUnlock: onUnlock))
    }
}
