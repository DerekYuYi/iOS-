//
//  RYHotCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/17.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

private let kRYTitleLabelLeading: CGFloat = 15
private let kRYTitleLabelTrailing: CGFloat = kRYTitleLabelLeading
private let kRYTitleLabelTop: CGFloat = 5
private let kRYTitleLabelBottom: CGFloat = kRYTitleLabelTop

class RYHotCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cornerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerView.backgroundColor = RYFormatter.shallowGrayColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerView.roundedCorner(nil, 15)
        
    }
    
    func update(_ title: String) {
        titleLabel.text = title
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        if #available(iOS 9.3, *) {
            let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            
            if let title = titleLabel.text {
                var newFrame = title.boundingRect(with:
                    CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30),
                                                  options: [.usesLineFragmentOrigin],
                                                  attributes: [.font: titleLabel.font],
                                                  context: nil)
                let width = ceil(newFrame.width)
                newFrame.size.width = width + (kRYTitleLabelLeading + kRYTitleLabelTrailing)
                newFrame.size.height = 30.0
                attributes.frame = newFrame
            }
            return attributes
        }
        return layoutAttributes
    }

}

