// StoreManager.swift
// Tink
//
// StoreKit 2 subscription management

import StoreKit
import Observation

@Observable
@MainActor
final class StoreManager {
    var isPro = false
    var products: [Product] = []

    private let productIDs = ["com.daodaolee.tink.pro.monthly", "com.daodaolee.tink.pro.yearly"]
    private var updateTask: Task<Void, Never>?

    init() {
        updateTask = Task { await listenForTransactions() }
        Task { await loadProducts() }
        Task { await checkEntitlements() }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
                .sorted(by: { $0.price < $1.price })
        } catch {
            print("Tink: failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verification.payloadValue
            await transaction.finish()
            isPro = true
            return true
        default:
            return false
        }
    }

    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue,
               productIDs.contains(transaction.productID) {
                isPro = true
                return
            }
        }
        isPro = false
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await checkEntitlements()
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? result.payloadValue {
                await transaction.finish()
                await checkEntitlements()
            }
        }
    }
}
