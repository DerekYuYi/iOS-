//
//  RYAdsLoader.swift
//  Spirits
//
//  Created by DerekYuYi on 2020/1/7.
//  Copyright © 2020 RuiYu. All rights reserved.
//

import Foundation
import MDAd
import BUAdSDK

protocol RYAdsLoaderDelegate: NSObjectProtocol {
    func rewardVideoWillClose(_ isPlaySucceed: Bool)
}

extension RYAdsLoaderDelegate {
    func rewardVideoWillClose(_ isPlaySucceed: Bool) {}
}

/// Manages related logics about MDAd and ChuanShanJia.
class RYAdsLoader: NSObject {
    
    weak var delegate: RYAdsLoaderDelegate?
    
    fileprivate weak var rootViewController: UIViewController?

    // MARK: MDAd ads
    
    fileprivate let topTextBottomImageFirstAd = RYCustomAd(adsID: "850006")
    fileprivate let topTextBottomImageSecondAd = RYCustomAd(adsID: "850006")
    fileprivate let topTextBottomImageThirdAd = RYCustomAd(adsID: "850006")
    fileprivate var topTextBottomImageAds: [RYNewsItem] = []
    
    fileprivate let tripleImageFirstAd = RYCustomAd(adsID: "850011")
    fileprivate let tripleImageSecondAd = RYCustomAd(adsID: "850011")
    fileprivate var tripleImageAds: [RYNewsItem] = []
    
    fileprivate var buoyView: RYBuoyView?
    
    // MARK: Bytedance ads
    
    fileprivate var rewardedVideoAd: BUNativeExpressRewardedVideoAd?
    fileprivate var buNativeAdsManagerExpress: BUNativeExpressAdManager?
    
    fileprivate let bytedanceTripleImageAds: [RYNewsItem] = []
    
    init(_ controller: UIViewController) {
        super.init()
        
        rootViewController = controller
        
        topTextBottomImageFirstAd.rootViewController = controller
        topTextBottomImageFirstAd.delegate = self
        topTextBottomImageSecondAd.rootViewController = controller
        topTextBottomImageSecondAd.delegate = self
        topTextBottomImageThirdAd.rootViewController = controller
        topTextBottomImageThirdAd.delegate = self
        
        tripleImageFirstAd.rootViewController = controller
        tripleImageFirstAd.delegate = self
        tripleImageSecondAd.rootViewController = controller
        tripleImageSecondAd.delegate = self
        
        setupBuoyView()
        setupBURewardedVideoAd()
        setupBUFeedAd()
    }
    
    deinit {
        topTextBottomImageFirstAd.delegate = nil
        topTextBottomImageSecondAd.delegate = nil
        topTextBottomImageThirdAd.delegate = nil
        tripleImageFirstAd.delegate = nil
        tripleImageSecondAd.delegate = nil
        
        rewardedVideoAd?.delegate = nil
//        buNativeAdsManager?.delegate = nil
        
        delegate = nil
    }
    
    fileprivate func setupBURewardedVideoAd() {
        self.rewardedVideoAd = nil
        self.rewardedVideoAd?.delegate = nil
        
        let model = BURewardedVideoModel()
        model.userId = "123"
        self.rewardedVideoAd = BUNativeExpressRewardedVideoAd(slotID: "945012735", rewardedVideoModel: model)
        self.rewardedVideoAd?.delegate = self
        self.rewardedVideoAd?.loadData()
    }
    
    fileprivate func setupBUFeedAd() {
        
        let slot1 = BUAdSlot()
        slot1.id = "945009547"
        slot1.adType = .feed
        slot1.imgSize = BUSize(by: .feed690_388)
        slot1.isSupportDeepLink = true
        buNativeAdsManagerExpress = BUNativeExpressAdManager(slot: slot1, adSize: CGSize(width: 80, height: 80))
        buNativeAdsManagerExpress?.delegate = self
        DispatchQueue.global(qos: .background).async {
            self.buNativeAdsManagerExpress?.loadAd(3)
        }
    }
    
    fileprivate func setupBuoyView() {
        guard let rootVC = rootViewController else { return }
        let buoyView = RYBuoyView()
        buoyView.adsID = "860001"
        buoyView.rootViewController = rootViewController
        buoyView.delegate = self
        buoyView.isHidden = true
        buoyView.alpha = 0
        self.buoyView = buoyView
        
        rootVC.view.addSubview(buoyView)
        
        buoyView.translatesAutoresizingMaskIntoConstraints = false
        buoyView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        buoyView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        buoyView.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor, constant: -100).isActive = true
        buoyView.trailingAnchor.constraint(equalTo: rootVC.view.trailingAnchor, constant: -10).isActive = true
    }
}

// MARK: - Public interfaces

extension RYAdsLoader {
    
    func requestTopTextBottomImageAd() {
        DispatchQueue.global(qos: .background).async {
            self.topTextBottomImageFirstAd.loadRequest()
            self.topTextBottomImageSecondAd.loadRequest()
            self.topTextBottomImageThirdAd.loadRequest()
        }
    }
    
    func topTextBottomImageAdArray() -> [RYNewsItem] {
        return topTextBottomImageAds
    }
    
    func topTextBottomImageCustomAds() -> [RYCustomAd] {
        return [topTextBottomImageFirstAd,
                topTextBottomImageSecondAd,
                topTextBottomImageThirdAd]
    }
    
    func requestTripleImageAd() {
        DispatchQueue.global(qos: .background).async {
            self.tripleImageFirstAd.loadRequest()
            self.tripleImageSecondAd.loadRequest()
        }
    }
    
    func tripleImageAdArray() -> [RYNewsItem] {
        return tripleImageAds
    }
    
    func tripleImageCustomAds() -> [RYCustomAd] {
        return [tripleImageFirstAd,
                tripleImageSecondAd]
    }
    
    func requestBuoyAd() {
        DispatchQueue.global(qos: .background).async {
            self.buoyView?.loadRequest()
        }
    }
    
    func showBuoyAd(_ needShow: Bool) {
        DispatchQueue.main.async {
            self.buoyView?.isHidden = !needShow
        }
    }
    
    func bytedanceTripleImageAdArray() -> [RYNewsItem] {
        return bytedanceTripleImageAds
    }
    
    func requestRewardVideoAds() {
        rewardedVideoAd?.show(fromRootViewController: rootViewController!,
                              ritScene: BURitSceneType.home_open_bonus,
                              ritSceneDescribe: nil)
    }
}

// MARK: - MDAds

extension RYAdsLoader: RYCustomAdDelegate, RYBuoyViewDelegate {
    
    func customAdDidReceiveAd(_ customAd: RYCustomAd, receivedData item: RYCustomAdItem) {
        
        /// NOTE: the `order` is match logic order for RYCustomAd and its data source.
        
        var order: Int = 0
        if customAd.isEqual(topTextBottomImageFirstAd) || customAd.isEqual(tripleImageFirstAd) {
            order = 0
        } else if customAd.isEqual(topTextBottomImageSecondAd) || customAd.isEqual(tripleImageSecondAd) {
            order = 1
        } else if customAd.isEqual(topTextBottomImageThirdAd) {
            order = 2
        }
        
        let dType: String
        if isMdadTripleImageCustomAd(customAd) {
            dType = "mdadTripleImages"
        } else {
            dType = "mdadTopTextBottomImage"
        }
        
        let dict: [AnyHashable: Any] = ["title": item.title ?? "",
                                        "image_urls": item.imageUrls ?? "",
                                        "desc": item.desc ?? "",
                                        "dtype": dType,
                                        "order": order]
        let item = RYNewsItem(dict)
        
        if isMdadTripleImageCustomAd(customAd) {
            tripleImageAds.append(item)
        } else {
            topTextBottomImageAds.append(item)
        }
    }
    
    private func isMdadTripleImageCustomAd(_ customAd: RYCustomAd) -> Bool {
        return customAd.isEqual(tripleImageFirstAd) || customAd.isEqual(tripleImageSecondAd)
    }
    
    func customAdDidFailToReceiveAd(_ customAd: RYCustomAd, error: RYError) {
    }
    
    func buoyDidReceiveAd(_ buoyView: RYBuoyView) {
        DispatchQueue.main.async {
            self.buoyView?.isHidden = false
            UIView.animate(withDuration: 0.8) {
                self.buoyView?.alpha = 1.0
            }
        }
    }
    
    func buoyDidFailToReceiveAd(_ buoyView: RYBuoyView, error: RYError) {
        showBuoyAd(false)
    }
    
}


// MARK: - BURewardedVideoAdDelegate

extension RYAdsLoader: BUNativeExpressRewardedVideoAdDelegate {
    
    func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
    }
    
    func nativeExpressRewardedVideoAdWillClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        delegate?.rewardVideoWillClose(true)
    }
    
    func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        /// setup again to prevent using the same ad repeatly.
        setupBURewardedVideoAd()
    }
    
    func nativeExpressRewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        delegate?.rewardVideoWillClose(false)
    }
    
    func nativeExpressRewardedVideoAdViewRenderFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, error: Error?) {
        delegate?.rewardVideoWillClose(false)
    }
}

// MARK: - BUNativeAdsManagerDelegate

extension RYAdsLoader: BUNativeExpressAdViewDelegate {
    
    func nativeExpressAdSuccess(toLoad nativeExpressAd: BUNativeExpressAdManager, views: [BUNativeExpressAdView]) {
        // save views (three)
    }
    
    func nativeExpressAdViewRenderFail(_ nativeExpressAdView: BUNativeExpressAdView, error: Error?) {
//        debugPrint(error)
    }
}
