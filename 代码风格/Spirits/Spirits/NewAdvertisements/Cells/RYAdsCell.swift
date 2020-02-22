//
//  RYAdsCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/5/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

@objc protocol RYAdsCellDelegate {}

class RYAdsCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var adsView: RYAdsView!
    
    // MARK: - Properties
    
    weak var delegate: RYAdsCellDelegate?
    
    private var ads: [RYAdvertisement] = []
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Update
    func update(withData data: [RYAdvertisement], andType type: String) { /// grammar such as "withData" for OC
        guard data.count > 0 else { return }
//        self.type = type
        ads = data
    }
    
}
