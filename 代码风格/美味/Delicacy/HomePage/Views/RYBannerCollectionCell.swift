//
//  RYBannerCollectionCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/10.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit
import Kingfisher

class RYBannerCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var coverView: UIView = {
        let view = UIView(frame: self.bounds)
        view.roundedCorner()
        return view
    }()
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.18) {
                    self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                    self.contentView.addSubview(self.coverView)
                    self.contentView.bringSubviewToFront(self.coverView)
                    
                    self.coverView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                }
            } else {
                UIView.animate(withDuration: 0.18) {
                    self.transform = .identity
                    self.coverView.backgroundColor = nil
                    self.coverView.removeFromSuperview()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.roundedCorner()
        imageView.backgroundColor = RYColors.gray_imageViewBg
        imageView.kf.indicatorType = .activity
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        imageView.backgroundColor = nil
//    }
    
    func update(_ data: RYBanner) {
        if let imageUrlString = data.imageUrlString, let url = URL(string: imageUrlString) {
            imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
        }
    }
    
}
