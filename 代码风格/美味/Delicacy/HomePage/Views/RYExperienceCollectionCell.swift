//
//  RYExperienceCollectionCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/11.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit
import Kingfisher

class RYExperienceCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var collectButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    
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
        
        collectButton.isEnabled = false
        likeButton.isEnabled = false
        
        contentView.backgroundColor = .white
        imageView.backgroundColor = RYColors.gray_imageViewBg
        imageView.contentMode = .scaleAspectFill
        imageView.kf.indicatorType = .activity
        
        avatarImageView.backgroundColor = RYColors.gray_imageViewBg
        
        backView.roundedCorner()
        
        shadowView.backgroundColor = .white // NOTE: Because of shadowView and backView are brother views, so set color except clear. Remembers set clear color when shadowView is parent view of backView(should called cornerView).
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowRadius = 7.0
        shadowView.layer.shadowColor = RYFormatter.milkWhiteColor().withAlphaComponent(0.4).cgColor
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.layer.bounds, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: 2, height: 2)).cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.roundedCorner(nil, avatarImageView.bounds.height / 2.0)
    }
    
    func update(_ data: RYExperience) {
        if let imageUrlString = data.imageUrlString, let url = URL(string: imageUrlString) {
            imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
        }
        
        if let imageUrlString = data.cook?.avatarUrlString, let url = URL(string: imageUrlString) {
            avatarImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
        }
        
        if let brief = data.intro {
            titleLabel.text = brief
        }
        
        if let nickName = data.cook?.nickName {
            nickNameLabel.text = nickName
        } else {
            nickNameLabel.text = "有鱼用户"
        }
        
        if let likeCount = data.likeCount {
            likeCountLabel.text = "\(likeCount)"
        } else {
             likeCountLabel.text = "0"
        }
        
    }
    
    
}
