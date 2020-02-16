//
//  RYShareItemCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/1/25.
//  Copyright © 2019 SmartRuiYu. All rights reserved.
//

import UIKit

class RYShareItemCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.15) {
                    self.contentView.backgroundColor = RYColors.gray_imageViewBg
                    self.contentView.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
                }
            } else {
                UIView.animate(withDuration: 0.15) {
                    self.contentView.backgroundColor = .white
                    self.contentView.transform = .identity
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(_ data: [String: String]) {
        guard data.count > 0 else { return }
        
        // Note: The data structure agreed on `RYShareBoard` class.
        if let key = data.keys.first, !key.isEmpty {
            itemTitleLabel.text = key
        }
        
        if let value = data.values.first, !value.isEmpty {
            itemImageView.image = UIImage(named: value)
        }
    }

}
