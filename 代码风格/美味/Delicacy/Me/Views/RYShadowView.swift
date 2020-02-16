//
//  RYShadowView.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/4/4.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

@IBDesignable class RYShadowView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 5.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // add corner radius
        roundedCorner()
        backgroundColor = UIColor.white
        
        layer.shadowColor = UIColor.red.cgColor

        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 9.0
    }

}
