import Foundation
import UIKit
import Combine

// MARK: - AdManager
// AppLovin MAX mediation layer.
//
// SETUP INSTRUCTIONS (one-time, before first build):
// ─────────────────────────────────────────────────
// 1. Add the AppLovin MAX SDK via Swift Package Manager:
//    https://github.com/AppLovin/AppLovin-MAX-Swift-Package
//    or CocoaPods: pod 'AppLovinSDK'
//
// 2. In Info.plist add:
//    AppLovinSdkKey  →  <your MAX SDK key>
//    SKAdNetworkItems (generated from MAX dashboard)
//
// 3. In AppDelegate.swift add:
//    ALSdk.shared().mediationProvider = "max"
//    ALSdk.shared().initializeSdk { _ in }
//
// 4. Create ad unit IDs in the MAX dashboard and paste them below.
// ─────────────────────────────────────────────────────────────────
//
// When the AppLovin SDK is NOT yet integrated, this file compiles fine
// (all MAX calls are wrapped in #if canImport(AppLovinSDK) guards).
// Once integrated, flip APPLOVIN_INTEGRATED to true.

// ─── Set true once SDK is installed ──────────────────────────────
private let APPLOVIN_INTEGRATED = false

// ─── Ad Unit IDs — replace with your real IDs from MAX dashboard ──
private enum AdUnitID {
    static let interstitial = "ENTER_YOUR_INTERSTITIAL_UNIT_ID"
    static let rewarded     = "ENTER_YOUR_REWARDED_UNIT_ID"
    static let banner       = "ENTER_YOUR_BANNER_UNIT_ID"
    static let mrec         = "ENTER_YOUR_MREC_UNIT_ID"       // optional
}

// ─── Callbacks ────────────────────────────────────────────────────
typealias AdCompletion    = (Bool) -> Void   // true = rewarded granted
typealias AdLoadCallback  = () -> Void

// MARK: - AdManager

@MainActor
final class AdManager: NSObject, ObservableObject {

    static let shared = AdManager()

    // ── Published state (drives UI) ────────────────────────────────
    @Published var interstitialReady: Bool = false
    @Published var rewardedReady:     Bool = false

    // ── Internal ───────────────────────────────────────────────────
    private var rewardCompletion:  AdCompletion?
    private var interstitialCompletion: AdCompletion?

    // Interstitial show policy: show every N game-over events
    private var gameOverCount:   Int = 0
    static let interstitialEvery = 3

    private override init() {
        super.init()
        if APPLOVIN_INTEGRATED { initMAX() }
    }

    // MARK: - SDK init (called only when SDK is present)

    private func initMAX() {
        #if canImport(AppLovinSDK)
        ALSdk.shared().mediationProvider = "max"
        ALSdk.shared().initializeSdk { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadInterstitial()
                self?.loadRewarded()
            }
        }
        #endif
    }

    // MARK: - ══ PUBLIC API ══

    // ── Interstitial ───────────────────────────────────────────────
    /// Call on every game-over. Shows an interstitial every N calls.
    func onGameOver(from viewController: UIViewController,
                    completion: AdCompletion? = nil) {
        gameOverCount += 1
        guard gameOverCount % AdManager.interstitialEvery == 0 else {
            completion?(false)
            return
        }
        showInterstitial(from: viewController, completion: completion)
    }

    func showInterstitial(from vc: UIViewController,
                          completion: AdCompletion? = nil) {
        guard APPLOVIN_INTEGRATED, interstitialReady else {
            completion?(false)
            return
        }
        interstitialCompletion = completion
        #if canImport(AppLovinSDK)
        // MAXInterstitialAd — attach delegates below
        #endif
    }

    // ── Rewarded ───────────────────────────────────────────────────
    /// Show rewarded ad (e.g. "continue game").
    /// completion(true) = reward granted, completion(false) = skipped/failed.
    func showRewarded(from vc: UIViewController,
                      completion: @escaping AdCompletion) {
        guard APPLOVIN_INTEGRATED, rewardedReady else {
            completion(false)
            return
        }
        rewardCompletion = completion
        #if canImport(AppLovinSDK)
        // MAXRewardedAd — attach delegates below
        #endif
    }

    // ── Load helpers ───────────────────────────────────────────────
    private func loadInterstitial() {
        #if canImport(AppLovinSDK)
        // let ad = MAXInterstitialAd(adUnitIdentifier: AdUnitID.interstitial)
        // ad.delegate = self
        // ad.load()
        #endif
    }

    private func loadRewarded() {
        #if canImport(AppLovinSDK)
        // let ad = MAXRewardedAd.shared(withAdUnitIdentifier: AdUnitID.rewarded)
        // ad.delegate = self
        // ad.load()
        #endif
    }
}

// MARK: - MAX Delegate stubs
// Uncomment and expand once AppLovin SDK is installed.

/*
extension AdManager: MAXInterstitialAdDelegate {
    func didLoad(_ ad: MAXInterstitialAd) {
        interstitialReady = true
    }
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String,
                         withError error: MAXError) {
        interstitialReady = false
    }
    func didHide(_ ad: MAXInterstitialAd) {
        interstitialCompletion?(false)
        interstitialCompletion = nil
        loadInterstitial()
    }
}

extension AdManager: MAXRewardedAdDelegate {
    func didLoad(_ ad: MAXRewardedAd) {
        rewardedReady = true
    }
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String,
                         withError error: MAXError) {
        rewardedReady = false
    }
    func didRewardUser(for ad: MAXRewardedAd, with reward: MAXReward) {
        rewardCompletion?(true)
        rewardCompletion = nil
    }
    func didHide(_ ad: MAXRewardedAd) {
        // If user skipped reward, fire false
        if rewardCompletion != nil {
            rewardCompletion?(false)
            rewardCompletion = nil
        }
        loadRewarded()
    }
}
*/

// MARK: - UIViewController helper
// Finds the topmost view controller to present ads over.

extension UIViewController {
    static func topMost(
        base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
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
