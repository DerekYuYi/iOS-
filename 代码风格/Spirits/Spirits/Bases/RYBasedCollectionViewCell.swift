//
//  RYBasedCollectionViewCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/9.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYBasedCollectionViewCell: UICollectionViewCell {
    
    var cornerRadius: CGFloat?
    
    private lazy var tappedView: UIView = {
        let view = UIView(frame: self.bounds)
        
        if let cornerRadiusValue = cornerRadius {
            view.layer.masksToBounds = true
            view.layer.cornerRadius = cornerRadiusValue
        }
        
        return view
    }()
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.18) {
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    self.contentView.addSubview(self.tappedView)
                    self.contentView.bringSubviewToFront(self.tappedView)
                    
                    self.tappedView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                }
            } else {
                UIView.animate(withDuration: 0.18) {
                    self.transform = .identity
                    self.tappedView.backgroundColor = nil
                    self.tappedView.removeFromSuperview()
                }
            }
        }
    }
}
