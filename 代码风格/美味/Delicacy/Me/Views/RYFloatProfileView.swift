//
//  RYFloatProfileView.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/7.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Kingfisher

typealias RYFloatProfileViewClosure = () -> Void

class RYFloatProfileView: UIView {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cornerView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var tapClosure: RYFloatProfileViewClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cornerView.roundedCorner()
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: -1)
        shadowView.layer.shadowOpacity = 0.7
        shadowView.layer.shadowRadius = 9.0
        
        avatarImageView.backgroundColor = RYColors.gray_imageViewBg
        editButton.setImage(UIImage(named: "editting"), for: .normal)
        
        update()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.roundedCorner(nil, 30)
    }
    
    @IBAction func cornerViewTapped(_ sender: UITapGestureRecognizer) {
        excuteClosure()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        excuteClosure()
    }
    
    private func excuteClosure() {
        if let closure = tapClosure {
            closure()
        }
    }
    
    func update() {
        // update data
        if RYProfileCenter.me.isLogined {
            // avatar
            if let imageUrlString = RYProfileCenter.me.avatarUrlString,
                let url = URL(string: imageUrlString) {
                avatarImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.6)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
            }
            
            // nick name
            if let nickName = RYProfileCenter.me.nickName {
                nickNameLabel.text = nickName
            }
            
            // introduction
            if let introduction = RYProfileCenter.me.introduction {
                descriptionLabel.text = introduction
            }
        } else {
            avatarImageView.image = nil
            nickNameLabel.text = "您还没有名字噢"
            descriptionLabel.text = "您登录之后, 将在这里显示您的个性签名"
        }
    }
    
}
