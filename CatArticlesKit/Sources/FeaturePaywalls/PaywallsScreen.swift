import SwiftUI
import DataLayer
import DesignSystem
import AppNavigation
import RevenueCat
import RevenueCatUI

@MainActor
@Observable
final class PaywallsModel {
    enum State {
        case loading
        case failed(String)
        case loaded(Offering)
    }

    private(set) var state: State = .loading
    private(set) var purchasing = false
    private let repository: PaywallsRepository

    init(repository: PaywallsRepository = RevenueCatPaywallsRepository()) {
        self.repository = repository
    }

    func load() async {
        do {
            state = .loaded(try await repository.fetchCurrentOffering())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Purchases the first package; returns `true` only on a real (non-cancelled) purchase.
    func purchaseFirstPackage(of offering: Offering) async -> Bool {
        guard let package = offering.availablePackages.first else { return false }
        purchasing = true
        defer { purchasing = false }
        do {
            let result = try await repository.purchase(package: package)
            return !result.userCancelled
        } catch {
            return false
        }
    }
}

/// Shows the server-driven RevenueCat paywall with a custom slide-to-unlock
/// overlay that drives a manual purchase — mirroring the Android `CatCustomPaywalls`.
public struct PaywallsScreen: View {
    @Environment(Router.self) private var router
    @State private var model = PaywallsModel()
    @State private var sliderReset = 0

    public init() {}

    private var isPaywallLoaded: Bool {
        if case .loaded = model.state { return true }
        return false
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            switch model.state {
            case .loading:
                CatProgressView()
            case .failed(let message):
                ContentUnavailableView("No paywall available", systemImage: "exclamationmark.triangle", description: Text(message))
            case .loaded(let offering):
                // Edge-to-edge paywall; its own close button handles dismissal.
                PaywallView(offering: offering, displayCloseButton: true)
                    .ignoresSafeArea()

                SlideToUnlock(text: "Slide to subscribe", isLoading: model.purchasing) {
                    Task {
                        let purchased = await model.purchaseFirstPackage(of: offering)
                        if purchased {
                            router.pop()
                        } else {
                            sliderReset += 1 // reset the slider to allow another try
                        }
                    }
                }
                .id(sliderReset)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Subscribe")
        .navigationBarTitleDisplayMode(.inline)
        // Loaded paywall is full-screen (the paywall's own close button dismisses);
        // keep a titled bar + back button for the loading/error states.
        .toolbar(isPaywallLoaded ? .hidden : .visible, for: .navigationBar)
        .task { await model.load() }
    }
}
