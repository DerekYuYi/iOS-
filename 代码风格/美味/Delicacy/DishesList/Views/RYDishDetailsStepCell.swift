//
//  RYDishDetailsStepCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/24.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYDishDetailsStepCell: UITableViewCell {
    
    @IBOutlet weak var stepFlagLabel: UILabel!
    @IBOutlet weak var stepImageView: UIImageView!
    
    @IBOutlet weak var stepDescriptionLabel: UILabel!
    @IBOutlet weak var stepImageViewRatioConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stepImageView.roundedCorner()
        stepImageView.contentMode = .scaleAspectFill
        stepImageView.backgroundColor = RYColors.gray_imageViewBg
        stepImageView.kf.indicatorType = .activity
    }
    
    func update(_ data: RYStep, totalStep: Int) {
        if let order = data.order {
            setupFlagLabelText("步骤\(order)/\(totalStep)")
        }
        
        if let stepImageUrlStr = data.imageLinkString,
            let url = URL(string: stepImageUrlStr) {
            stepImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
            stepImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil) {[weak self] (image, error, cacheType, url) in
                if let image = image {
                    let ratio = image.size.width / image.size.height
                    self?.stepImageViewRatioConstraint.constant = ratio
                    self?.contentView.layoutIfNeeded()
                }
            }
        }
        
        if let des = data.content {
            stepDescriptionLabel.text = des
        }
    }
    
    private func setupFlagLabelText(_ string: String) {
        let mutableString = NSMutableAttributedString(string: string)
        let paras: [NSAttributedString.Key: Any] = [.foregroundColor: RYFormatter.color(from: 0x3f3f3f),
                                                    .font: RYFormatter.font(for: .regular, fontSize: 10.0),
                                                    .baselineOffset: 0]
        let range = NSMakeRange(mutableString.length - 2, 2)
        mutableString.addAttributes(paras, range: range)
        stepFlagLabel.attributedText = mutableString
    }
    
}
