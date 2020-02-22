//
//  RYBaseTextField.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/12.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYBaseTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func configRightView(_ text: String?, imageName: String? = nil) {
        
    }
    
    func shakeWhenInputInvalidContent() {
        self.shake(for: "position.x")
    }
    
    /// validates whether the input phone number is valid.
    static func isValidPhoneNumber(for numberString: String?) -> Bool {
        guard let numberString = numberString, numberString.count == 11 else {
            return false
        }
        
        let mobile = "^1((3[0-9]|4[57]|5[0-35-9]|7[0678]|8[0-9])\\d{8}$)"
        let CM = "(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
        let CU = "(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
        let CT = "(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
        
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@", mobile)
        let regextestcm = NSPredicate(format: "SELF MATCHES %@", CM)
        let regextestcu = NSPredicate(format: "SELF MATCHES %@", CU)
        let regextestct = NSPredicate(format: "SELF MATCHES %@", CT)
        
        if ((regextestmobile.evaluate(with: numberString) == true)
            || (regextestcm.evaluate(with: numberString) == true)
            || (regextestct.evaluate(with: numberString) == true)
            || (regextestcu.evaluate(with: numberString) == true)) {
            return true
        } else {
            return false
        }
    }

}
