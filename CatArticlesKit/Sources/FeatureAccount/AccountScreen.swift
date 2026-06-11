import SwiftUI
import DataLayer
import DesignSystem
import RevenueCat
import RevenueCatUI

@MainActor
@Observable
final class AccountModel {
    var userIDInput = ""
    private(set) var working = false
    var errorMessage: String?

    private let repository: PaywallsRepository

    init(repository: PaywallsRepository = RevenueCatPaywallsRepository()) {
        self.repository = repository
    }

    var isAnonymous: Bool { repository.isAnonymous }

    func logIn() async {
        let id = userIDInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else { return }
        working = true
        defer { working = false }
        do {
            _ = try await repository.logIn(id)
            userIDInput = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logOut() async {
        working = true
        defer { working = false }
        do {
            _ = try await repository.logOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

public struct AccountScreen: View {
    @Environment(EntitlementStore.self) private var entitlement
    @State private var model = AccountModel()
    @State private var showCustomerCenter = false

    public init() {}

    public var body: some View {
        @Bindable var model = model
        Form {
            Section("Subscription") {
                LabeledContent("Status", value: entitlement.isPremium ? "Premium" : "Free")
                Button("Manage Subscription") { showCustomerCenter = true }
            }

            Section("Account") {
                if model.isAnonymous {
                    TextField("User ID", text: $model.userIDInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button {
                        Task { await model.logIn() }
                    } label: {
                        if model.working { ProgressView() } else { Text("Log In") }
                    }
                    .disabled(model.userIDInput.isEmpty || model.working)
                } else {
                    Button(role: .destructive) {
                        Task { await model.logOut() }
                    } label: {
                        Text("Log Out")
                    }
                    .disabled(model.working)
                }
            }
        }
        .navigationTitle("Account")
        .tint(.catPrimary)
        .sheet(isPresented: $showCustomerCenter) {
            CustomerCenterView()
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
