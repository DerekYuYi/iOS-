//
//  RYPublishTitleFillCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/10.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYPublishTitleFillCell: UITableViewCell {

    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if #available(iOS 11.0, *) {
            cornerView.backgroundColor = UIColor(named: "Color_FCFCFC")
            titleTextField.backgroundColor = UIColor(named: "Color_FCFCFC")
        } else {
            cornerView.backgroundColor = .white
            titleTextField.backgroundColor = RYColors.color(from: 0xfcfcfc)
        }
        
        cornerView.layer.masksToBounds = true
        cornerView.layer.cornerRadius = 5.0
        cornerView.layer.borderColor = RYColors.color(from: 0xF3F1F1).cgColor
        cornerView.layer.borderWidth = 1.0
        
        titleTextField.delegate = self
        titleTextField.returnKeyType = .done
    }
    
    @IBAction func titleTextFieldEditingChanged(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            if text.count > 15 {
                
                // shake
                sender.shake(for: "position.x")
                
                // access content between 0 and 15
                sender.text = String(text.prefix(14))
            }
        }
    }
}

// MARK: - Helper method

extension RYPublishTitleFillCell {
    
    func dismissKeyboard() {
        if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        }
    }
    
    func filledText() -> String? {
        return titleTextField.text
    }
}


extension RYPublishTitleFillCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}
