//
//  RYEditNameCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/16.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

protocol RYEditNameCellDelegate: NSObjectProtocol {
    func nameTextFieldEditingChanged(_ textField: UITextField)
}

class RYEditNameCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UITextField!
    weak var delegate: RYEditNameCellDelegate?
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameTextField.tintColor = RYColors.yellow_theme
        nameTextField.textColor = RYColors.black_333333
        nameTextField.font = RYFormatter.fontLarge(for: .regular)
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.text = RYProfileCenter.me.nickName
    }
    
    @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
        delegate?.nameTextFieldEditingChanged(sender)
    }
    
}
