//
//  RYTitleView.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/22.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYTitleView: UIView {
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingCompressedSize
//        return UIView.layoutFittingExpandedSize
        
    }

}
