import Foundation
import UIKit
import SwiftUI
import Combine
import GoogleMobileAds

// MARK: - AdMob Rewarded Ads
// Replace these with your real production IDs before App Store release.
private enum AdMobConfig {
    // Test app ID from Google docs.
    static let appID = "ca-app-pub-3940256099942544~1458002511"

    // Test rewarded ad unit IDs from Google docs.
    static let continueRewardedUnitID = "ca-app-pub-3940256099942544/1712485313"
    static let freeCoinsRewardedUnitID = "ca-app-pub-3940256099942544/1712485313"

    static let freeCoinsRewardAmount = 1000
}

enum RewardPlacement {
    case continueGame
    case freeCoins

    var adUnitID: String {
        switch self {
        case .continueGame: return AdMobConfig.continueRewardedUnitID
        case .freeCoins:    return AdMobConfig.freeCoinsRewardedUnitID
        }
    }
}

@MainActor
final class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    @Published var continueRewardReady: Bool = false
    @Published var freeCoinsRewardReady: Bool = false
    @Published var isShowingAd: Bool = false

    private var rewardedAds: [RewardPlacement: RewardedAd] = [:]
    private var currentPlacement: RewardPlacement?
    private var rewardGranted = false
    private var completion: ((Bool) -> Void)?

    private override init() {
        super.init()
    }

    func start() {
        MobileAds.shared.start(completionHandler: nil)
        Task {
            await loadRewarded(for: .continueGame)
            await loadRewarded(for: .freeCoins)
        }
    }

    func showRewarded(for placement: RewardPlacement, completion: @escaping (Bool) -> Void) {
        guard !isShowingAd else {
            completion(false)
            return
        }
        guard let root = UIViewController.topMost() else {
            completion(false)
            return
        }
        guard let ad = rewardedAds[placement] else {
            completion(false)
            Task { await loadRewarded(for: placement) }
            return
        }

        isShowingAd = true
        currentPlacement = placement
        rewardGranted = false
        self.completion = completion
        ad.fullScreenContentDelegate = self
        ad.present(from: root) { [weak self] in
            self?.rewardGranted = true
        }
    }

    func loadIfNeeded() {
        Task {
            if rewardedAds[.continueGame] == nil {
                await loadRewarded(for: .continueGame)
            }
            if rewardedAds[.freeCoins] == nil {
                await loadRewarded(for: .freeCoins)
            }
        }
    }

    private func loadRewarded(for placement: RewardPlacement) async {
        do {
            let request = Request()
            let ad = try await RewardedAd.load(with: placement.adUnitID, request: request)
            rewardedAds[placement] = ad
            updateReadyFlags()
        } catch {
            rewardedAds[placement] = nil
            updateReadyFlags()
        }
    }

    private func updateReadyFlags() {
        continueRewardReady = rewardedAds[.continueGame] != nil
        freeCoinsRewardReady = rewardedAds[.freeCoins] != nil
    }

    private func finish(result: Bool) {
        let done = completion
        completion = nil
        isShowingAd = false
        let finishedPlacement = currentPlacement
        currentPlacement = nil
        rewardGranted = false
        done?(result)
        if let finishedPlacement {
            Task { await loadRewarded(for: finishedPlacement) }
        }
    }
}

extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        finish(result: rewardGranted)
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        finish(result: false)
    }
}

extension UIViewController {
    static func topMost(
        base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: \.isKeyWindow)?
            .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMost(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMost(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMost(base: presented)
        }
        return base
    }
}
