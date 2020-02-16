//
//  RYButton.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/3/6.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.15) {
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            } else {
                UIView.animate(withDuration: 0.15) {
                    self.transform = .identity
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
    }

}
