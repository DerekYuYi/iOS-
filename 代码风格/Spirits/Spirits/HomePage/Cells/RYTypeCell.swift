//
//  RYTypeCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/8.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYTypeCell: RYBasedCollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var shadowView: RYShadowView!
    @IBOutlet weak var cornerView: RYGradientView!
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = false
        contentView.clipsToBounds = false
        
        cornerView.layer.cornerRadius = 10.0
        cornerView.layer.masksToBounds = true
        self.cornerRadius = 10.0
    }
    
    
    // MARK: - Update
    
    func updateData(_ data: TypeDataItem) {
        contentImageView.image = UIImage(named: data.imageName)
        contentLabel.text = data.title.name
        
        cornerView.startColor = data.startColor
        cornerView.endColor = data.endColor
        cornerView.update()
        
        shadowView.shadowColor = data.shadowColor
        shadowView.update()
    }
}
