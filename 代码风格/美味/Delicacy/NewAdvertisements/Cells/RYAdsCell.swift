//
//  RYAdsCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/5/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

protocol RYAdsCellDelegate: NSObjectProtocol {
    func closeAds(for type: eRYAdsType)
    func didSelectAd(at advertiment: RYAdvertisement)
}

class RYAdsCell: UITableViewCell {
    
    // MARK: - Properties
    
    var hiddenAdsDescription: Bool = false {
        didSet {
            adsView?.hiddenAdsDescription = hiddenAdsDescription
        }
    }
    weak var delegate: RYAdsCellDelegate?
    
    private var adsView = RYAdsView.loadFromNib()
    private var ads: [RYAdvertisement] = []
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        adsView?.delegate = self
        if let adsView = adsView {
            contentView.addSubview(adsView)
            RYUITweaker.addConstraints(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), for: adsView, in: contentView, related: contentView)
        }
        
        hiddenAdsDescription = false
    }
    
    // MARK: - Update
    func update(_ data: [RYAdvertisement], type: eRYAdsType) {
        guard data.count > 0 else { return }
        ads = data
        adsView?.update(data, type: type)
    }
}


// MARK: - RYAdsViewDelegate

extension RYAdsCell: RYAdsViewDelegate {
    
    func closeAds(for type: eRYAdsType) {
        delegate?.closeAds(for: type)
    }
    
    func didSelectAd(at advertiment: RYAdvertisement) {
        delegate?.didSelectAd(at: advertiment)
    }
}
