//
//  RYFavoritesContentCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/11.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

@objc protocol RYFavoritesContentCellDelegate: NSObjectProtocol {
    @objc optional func cancelCollection(at indexPath: IndexPath)
}

class RYFavoritesContentCell: UITableViewCell {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var cornerView: UIView!
    
    weak var delegate: RYFavoritesContentCellDelegate?
    
    /// Indicates indexpath which button belongs to.
    private var locatedIndexPath: IndexPath?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if #available(iOS 11.0, *) {
            backgroundColor = UIColor(named: "Color_f1f8f9")
        } else {
            backgroundColor = RYColors.color(from: 0xF1F8F9)
        }
        contentView.backgroundColor = self.backgroundColor
        
        cornerView.layer.masksToBounds = true
        cornerView.layer.cornerRadius = 5.0
        cornerView.layer.borderColor = RYColors.color(from: 0xF3F1F1).cgColor
        cornerView.layer.borderWidth = 1.0
        configForUserInterfaceStyle()
    }

    private func configForUserInterfaceStyle() {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                cornerView.backgroundColor = UIColor.white
            } else {
                if #available(iOS 13.0, *) {
                    cornerView.backgroundColor = UIColor.secondarySystemBackground
                }
            }
        } else {
            cornerView.backgroundColor = UIColor.white
        }
    }
    
    func update(_ data: RYTypeContentItem, indexPath: IndexPath) {
        locatedIndexPath = indexPath
        
        topLabel.text = data.title
        bottomLabel.text = data.content
    }
    
    
    @IBAction func collectionButtonTapped(_ sender: UIButton) {
        guard let indexPath = locatedIndexPath else {
            fatalError("Selected Invalid indexpath.")
        }
        
        delegate?.cancelCollection?(at: indexPath)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                configForUserInterfaceStyle()
            }
        }
    }
    
}
