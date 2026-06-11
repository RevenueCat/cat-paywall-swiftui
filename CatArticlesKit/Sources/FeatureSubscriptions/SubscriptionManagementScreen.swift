import SwiftUI
import DataLayer
import DesignSystem
import RevenueCat

@MainActor
@Observable
final class SubscriptionsModel {
    enum State {
        case loading
        case failed(String)
        case loaded(offering: Offering?, info: CustomerInfo)
    }

    private(set) var state: State = .loading
    private let repository: PaywallsRepository

    init(repository: PaywallsRepository = RevenueCatPaywallsRepository()) {
        self.repository = repository
    }

    func load() async {
        do {
            let info = try await repository.fetchCustomerInfo()
            let offering = try? await repository.fetchCurrentOffering()
            state = .loaded(offering: offering, info: info)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

public struct SubscriptionManagementScreen: View {
    @State private var model = SubscriptionsModel()

    public init() {}

    public var body: some View {
        List {
            switch model.state {
            case .loading:
                CatProgressView()
                    .frame(height: 240)
                    .listRowSeparator(.hidden)
            case .failed(let message):
                ContentUnavailableView("Couldn’t load", systemImage: "wifi.slash", description: Text(message))
            case .loaded(let offering, let info):
                currentPlanSection(info)
                activeSubscriptionsSection(info)
                if let offering { availablePackagesSection(offering) }
            }
        }
        .navigationTitle("Subscriptions")
        .task { await model.load() }
    }

    @ViewBuilder
    private func currentPlanSection(_ info: CustomerInfo) -> some View {
        let entitlement = info.entitlements[CatConstants.premiumEntitlementID]
        Section("Current plan") {
            LabeledContent("Status", value: entitlement?.isActive == true ? "Premium" : "Free")
            if let entitlement, entitlement.isActive, let expiration = entitlement.expirationDate {
                LabeledContent("Renews", value: expiration.formatted(date: .abbreviated, time: .omitted))
            }
        }
    }

    @ViewBuilder
    private func activeSubscriptionsSection(_ info: CustomerInfo) -> some View {
        if !info.activeSubscriptions.isEmpty {
            Section("Active subscriptions") {
                ForEach(info.activeSubscriptions.sorted(), id: \.self) { productID in
                    Text(productID)
                }
            }
        }
    }

    @ViewBuilder
    private func availablePackagesSection(_ offering: Offering) -> some View {
        Section("Available packages") {
            ForEach(offering.availablePackages, id: \.identifier) { package in
                let title = package.storeProduct.localizedTitle
                LabeledContent(
                    title.isEmpty ? package.identifier : title,
                    value: package.storeProduct.localizedPriceString
                )
            }
        }
    }
}
