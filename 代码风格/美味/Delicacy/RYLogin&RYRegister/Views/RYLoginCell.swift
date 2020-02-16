//
//  RYLoginCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/9.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

protocol RYLoginCellDelegate: NSObjectProtocol {
    func textFieldEditingChanged(_ textfield: UITextField)
}

private let kRYNormalGap: CGFloat = 12.0

class RYLoginCell: UICollectionViewCell {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    weak var delegate: RYLoginCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 1. setup textFields
        phoneNumberTextField.roundedCorner(RYColors.color(from: 0xdddedd), 22.0)
        phoneNumberTextField.tintColor = RYColors.yellow_theme
        phoneNumberTextField.keyboardType = .numberPad
        
        passwordTextfield.roundedCorner(RYColors.color(from: 0xdddedd), 22.0)
        passwordTextfield.tintColor = RYColors.yellow_theme
        passwordTextfield.clearButtonMode = .whileEditing
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.returnKeyType = .done
        
        // 2. custom leftviews or rightviews
        let phoneImage = UIImage(named: "phone")
        let lockImage = UIImage(named: "lock")
        let eyelashImage = UIImage(named: "eyelash")
        
        // phoneNumberTextField's leftView
        if let phoneImage = phoneImage {
            phoneNumberTextField.leftViewMode = .always
            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: phoneImage.size.width + kRYNormalGap + 5, height: phoneImage.size.height))
            let phoneImageView = UIImageView(image: phoneImage)
            phoneImageView.frame = CGRect(x: kRYNormalGap, y: 0, width: phoneImage.size.width, height: phoneImage.size.height)
            leftView.addSubview(phoneImageView)
            phoneNumberTextField.leftView = leftView
        }
        
        // passwordTextfield's leftView
        if let lockImage = lockImage {
            passwordTextfield.leftViewMode = .always
            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: lockImage.size.width + kRYNormalGap + 5, height: lockImage.size.height))
            let lockImageView = UIImageView(image: lockImage)
            lockImageView.frame = CGRect(x: kRYNormalGap, y: 0, width: lockImage.size.width, height: lockImage.size.height)
            leftView.addSubview(lockImageView)
            passwordTextfield.leftView = leftView
        }
        
        // passwordTextfield's rightView
        if let eyelashImage = eyelashImage {
            passwordTextfield.rightViewMode = .always
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: eyelashImage.size.width + kRYNormalGap, height: eyelashImage.size.height))
            let rightButton = UIButton(type: .system)
            rightButton.tintColor = .black
            rightButton.frame = CGRect(x: 0, y: 0, width: eyelashImage.size.width, height: eyelashImage.size.height)
            rightButton.setImage(eyelashImage, for: .normal)
            rightButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
            rightView.addSubview(rightButton)
            passwordTextfield.rightView = rightView
        }
    }
    
    // MARK: - Touch Events
    @IBAction func phoneNumberEditingChanged(_ sender: UITextField) {
        delegate?.textFieldEditingChanged(sender)
    }
    
    @IBAction func passwordEditingChanged(_ sender: UITextField) {
        delegate?.textFieldEditingChanged(sender)
    }
    
    @objc private func eyeButtonTapped(_ sender: UIButton) {
        if passwordTextfield.isSecureTextEntry {
            sender.setImage(UIImage(named: "eye"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "eyelash"), for: .normal)
        }
        passwordTextfield.isSecureTextEntry = !passwordTextfield.isSecureTextEntry
    }
    
    
}
