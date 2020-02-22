//
//  RYAdItemCollectionCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYAdItemCollectionCell: UICollectionViewCell {
    
    private struct Constant {
        static let whiteSpaceString = " "
    }
    
    @IBOutlet weak var adsImageView: UIImageView!
    @IBOutlet weak var adsDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        adsImageView.contentMode = .scaleToFill
        adsImageView.backgroundColor = RYColors.color(from: 0xE3E6EF)
        adsImageView.kf.indicatorType = .activity
        
        adsDescriptionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    func update(_ ad: RYAdvertisement, hiddenDescriptionLabel hidden: Bool) {
        guard let adsUrl = ad.resource?.first, !adsUrl.isEmpty else { return }
        
        if let url = URL(string: adsUrl) {
            adsImageView.kf.setImage(with: url,
                                     options: [.transition(.fade(0.7)), .fromMemoryCacheOrRefresh])
        }
        
        if !hidden {
            if let descriptionText = ad.descriptionText {
                adsDescriptionLabel.text = Constant.whiteSpaceString + descriptionText
            } else {
                adsDescriptionLabel.text = Constant.whiteSpaceString + RYDeviceInfoCollector.shared.appDisplayName
            }
        }
        adsDescriptionLabel.isHidden = hidden
    }

}
