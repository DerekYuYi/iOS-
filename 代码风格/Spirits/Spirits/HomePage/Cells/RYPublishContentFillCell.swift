//
//  RYPublishContentFillCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/10.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

@objc protocol RYPublishContentFillCellDelegate: NSObjectProtocol {
    @objc optional func textViewDidBeginEditing()
}

class RYPublishContentFillCell: UITableViewCell {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    weak var delegate: RYPublishContentFillCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if #available(iOS 11.0, *) {
            cornerView.backgroundColor = UIColor(named: "Color_FCFCFC")
            contentTextView.backgroundColor = UIColor(named: "Color_FCFCFC")
        } else {
            cornerView.backgroundColor = .white
            contentTextView.backgroundColor = RYColors.color(from: 0xfcfcfc)
        }
        
        cornerView.layer.masksToBounds = true
        cornerView.layer.cornerRadius = 5.0
        cornerView.layer.borderColor = RYColors.color(from: 0xF3F1F1).cgColor
        cornerView.layer.borderWidth = 1.0
        
        contentTextView.delegate = self
//        contentTextView.returnKeyType = .done
    }
}


// MARK: - Helper method

extension RYPublishContentFillCell {
    
    func dismissKeyboard() {
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        }
    }
    
    func isFirstResponderForInterResponder() -> Bool {
        return contentTextView.isFirstResponder
    }
    
    func filledText() -> String {
        return contentTextView.text
    }
}



// MARK: - UITextViewDelegate

extension RYPublishContentFillCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        DispatchQueue.main.async {
            self.placeholderLabel.isHidden = !textView.text.isEmpty
        }
        
        delegate?.textViewDidBeginEditing?()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 250 {
            textView.shake(for: "position.x")
            textView.text = String(textView.text.prefix(200))
        }
        
        DispatchQueue.main.async {
            self.placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        dismissKeyboard()
//        return true
//    }

}
