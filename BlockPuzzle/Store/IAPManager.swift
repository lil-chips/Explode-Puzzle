import Combine
import Foundation
import StoreKit
import SwiftUI

@MainActor
final class IAPManager: ObservableObject {
    static let shared = IAPManager()

    enum ProductID {
        static let coinPack5000 = "com.ed.blockpuzzle.coinpack.5000"
    }

    @Published private(set) var coinPackProduct: Product?
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false

    private let deliveredTransactionsKey = "neonpuzzles.iap.deliveredTransactions"
    private var deliveredTransactionIDs: Set<UInt64>
    private var updatesTask: Task<Void, Never>?

    private init() {
        let stored = UserDefaults.standard.array(forKey: deliveredTransactionsKey) as? [NSNumber] ?? []
        deliveredTransactionIDs = Set(stored.map { $0.uint64Value })
        updatesTask = observeTransactionUpdates()
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let products = try await Product.products(for: [ProductID.coinPack5000])
            coinPackProduct = products.first(where: { $0.id == ProductID.coinPack5000 })
        } catch {
            coinPackProduct = nil
        }
    }

    func purchaseCoinPack5000() async -> PurchaseOutcome {
        guard let product = coinPackProduct else {
            return .unavailable
        }
        guard !isPurchasing else {
            return .pending
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                return await handleVerificationResult(verification)
            case .userCancelled:
                return .cancelled
            case .pending:
                return .pending
            @unknown default:
                return .failed("Unknown purchase state.")
            }
        } catch {
            return .failed("Purchase failed. Please try again.")
        }
    }

    func syncUnfinishedTransactions() async -> Int {
        var restoredCoins = 0
        for await result in Transaction.currentEntitlements {
            let outcome = await handleVerificationResult(result)
            if case .success(let coins) = outcome {
                restoredCoins += coins
            }
        }
        return restoredCoins
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            for await result in Transaction.updates {
                await self.handleBackgroundTransactionUpdate(result)
            }
        }
    }

    @MainActor
    private func handleBackgroundTransactionUpdate(_ result: VerificationResult<StoreKit.Transaction>) async {
        _ = await handleVerificationResult(result)
    }

    private func handleVerificationResult(_ verification: VerificationResult<StoreKit.Transaction>) async -> PurchaseOutcome {
        switch verification {
        case .verified(let transaction):
            let outcome = deliver(transaction: transaction)
            await transaction.finish()
            return outcome
        case .unverified:
            return .failed("Purchase could not be verified.")
        }
    }

    private func deliver(transaction: StoreKit.Transaction) -> PurchaseOutcome {
        guard transaction.productID == ProductID.coinPack5000 else {
            return .failed("Unknown product purchased.")
        }

        let transactionID = transaction.id
        guard deliveredTransactionIDs.insert(transactionID).inserted else {
            return .duplicate
        }

        persistDeliveredTransactions()
        return .success(coins: 5000)
    }

    private func persistDeliveredTransactions() {
        let values = deliveredTransactionIDs.map { NSNumber(value: $0) }
        UserDefaults.standard.set(values, forKey: deliveredTransactionsKey)
    }

    enum PurchaseOutcome {
        case success(coins: Int)
        case cancelled
        case pending
        case unavailable
        case duplicate
        case failed(String)
    }
}
