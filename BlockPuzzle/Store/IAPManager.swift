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

    private init() {}

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
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    return .success(coins: 5000)
                case .unverified:
                    return .failed("Purchase could not be verified.")
                }
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

    enum PurchaseOutcome {
        case success(coins: Int)
        case cancelled
        case pending
        case unavailable
        case failed(String)
    }
}
