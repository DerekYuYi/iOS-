//
//  RYAdsView.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/10.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

protocol RYAdsViewDelegate: NSObjectProtocol {
    func closeAds(for type: eRYAdsType)
    func didSelectAd(at advertiment: RYAdvertisement)
}

class RYAdsView: UIView, RYNibLoadable {
    
    struct Constants {
        static let identifierForAdItem = String(describing: RYAdItemCollectionCell.self)
        static let timeIntervalForSrollAdsAlternately: TimeInterval = 6.0
    }

    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topLeftCornerTagLabel: UILabel!
    @IBOutlet weak var bottomRightCornerTagLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Properties
    
    weak var delegate: RYAdsViewDelegate?
    
    var hiddenAdsDescription: Bool = false {
        didSet {
            topLeftCornerTagLabel.isHidden = !hiddenAdsDescription
            bottomRightCornerTagLabel.isHidden = hiddenAdsDescription
        }
    }
    
    private var ads: [RYAdvertisement] = []
    
    // for ads automatic scroll
    private var currentIndex: Int = 0
    private var isScrollAlternately: Bool = true
    
    private var type: eRYAdsType?
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.register(UINib(nibName: Constants.identifierForAdItem, bundle: nil), forCellWithReuseIdentifier: Constants.identifierForAdItem)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -3, right: 0)
        
        topLeftCornerTagLabel.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        topLeftCornerTagLabel.roundedCorner(UIColor.white.withAlphaComponent(0.5), 2.0)
        
        bottomRightCornerTagLabel.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        bottomRightCornerTagLabel.roundedCorner(UIColor.white.withAlphaComponent(0.5), 2.0)
        
        hiddenAdsDescription = false
    }
    
    
    // MARK: - Update
    
    func update(_ data: [RYAdvertisement], type: eRYAdsType) {
        guard data.count > 0 else { return }
        self.type = type
        ads = data
        collectionView.reloadData()
        //        startShowAdsAlternately()
    }
    
    // MARK: - Selectors
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        if let type = type {
            delegate?.closeAds(for: type)
        }
    }
    
    // MARK: - Scroll Alternately
    
    func startShowAdsAlternately() {
        isScrollAlternately = true
        self.perform(#selector(scrollAdsAlternately), with: nil, afterDelay: Constants.timeIntervalForSrollAdsAlternately)
    }
    
    func endShowAdsAlternately() {
        isScrollAlternately = false
    }
    
    @objc private func scrollAdsAlternately() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(scrollAdsAlternately), object: nil)
        
        if !isScrollAlternately { return }
        if ads.count <= 0 || ads.count == 1 { return }
        //        guard ads.count > 0 || isScrollAlternately || ads.count == 1 else { return } // ???
        
        if (currentIndex+1) < ads.count {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        self.perform(#selector(scrollAdsAlternately), with: nil, afterDelay: Constants.timeIntervalForSrollAdsAlternately)
    }
}

// MARK: - UICollectionViewDelegate

extension RYAdsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegate && UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.identifierForAdItem, for: indexPath)
        if let cell = cell as? RYAdItemCollectionCell, indexPath.row < ads.count {
            cell.update(ads[indexPath.row], hiddenDescriptionLabel: hiddenAdsDescription)
        }
        return cell
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row < ads.count else { return }
        // count the ad's adid that has shown.
        let ad = ads[indexPath.row]
        if !RYAdsRecorder.shared.hasShownAd(for: ad.id) {
            RYAdsRecorder.shared.showAd(for: ad.id)
            RYAdsDataCenter.sharedInstance.countAds(for: ad.id, withType: .present)
        }
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row < ads.count else { return }
        // count the ad's adid that has shown.
        let ad = ads[indexPath.row]
        if !RYAdsRecorder.shared.hasShownAd(for: ad.id) {
            RYAdsRecorder.shared.showAd(for: ad.id)
            RYAdsDataCenter.sharedInstance.countAds(for: ad.id, withType: .present)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // delegate to controller with click_url
        guard ads.count > 0, indexPath.row < ads.count else {
            return
        }
        let ad = ads[indexPath.row]
        delegate?.didSelectAd(at: ad)
        RYAdsDataCenter.sharedInstance.countAds(for: ad.id, withType: .click)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
