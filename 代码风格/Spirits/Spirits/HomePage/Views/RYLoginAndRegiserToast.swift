//
//  RYLoginAndRegiserToast.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/12.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

enum eRYConfirmType {
    case login, register
}

protocol RYLoginAndRegiserToastDelegate: NSObjectProtocol {
    func confirmAccount(_ confirmType: eRYConfirmType)
}

class RYLoginAndRegiserToast: UIView {
    
    private struct Constants {
        static let maskViewTag = 2019
        static let countOfPhoneNumber: Int = 11
        static let countOfShowClearButtonMode: Int = 7
        static let countOfPasswords: Int = 6
    }

    // MARK: - Outlets
    
    @IBOutlet weak var phoneNumberTerxtField: RYBaseTextField!
    @IBOutlet weak var passwordTextField: RYBaseTextField!
    @IBOutlet weak var confirmButton: RYBaseButton!
    
    // MARK: - Properties
    
    weak var delegate: RYLoginAndRegiserToastDelegate?
    
    private var type: eRYConfirmType = .login {
        didSet {
            let confirmText = type == .login ? "登录" : "注册"
            confirmButton.setTitle(confirmText, for: .normal)
        }
    }
    
    private var isValidForPasswordCount = false
    
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 5.0
        enabledConfirmButton(false)
        
//        phoneNumberTerxtField.tintColor = RYColors.yellow_theme
        phoneNumberTerxtField.keyboardType = .numberPad
        
//        passwordTextfield.tintColor = RYColors.yellow_theme
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        
        phoneNumberTerxtField.delegate = self
        passwordTextField.delegate = self
    }
    
    /// Update data for initial subviews
    func update(_ type: eRYConfirmType) {
        self.type = type
    }
    
    // MARK: - Touch Event
    
    @IBAction func cofirmButtonTapped(_ sender: UIButton) {
        
        // show indicator
        showIndicatorViewInConfirmButton(true)
        
        // check password and request
        if isValidForPasswordCount {
            delegate?.confirmAccount(type)
        } else {
            self.makeToast("密码不能低于6位", duration: 1.4, position: .center)
            showIndicatorViewInConfirmButton(false)
        }
    }
    
    @IBAction func phoneNmberTextFieldEditingChanged(_ sender: UITextField) {
        // 1. guard input text
        guard let inputNumberString = phoneNumberTerxtField?.text, !inputNumberString.isEmpty else {
            phoneNumberValidator(false)
            return
        }
        
        // 2. trim text
        let trimmedText = inputNumberString.trimmingCharacters(in: CharacterSet(charactersIn: "\"_ *#-"))
        guard !trimmedText.isEmpty else {
            phoneNumberValidator(false)
            return
        }
        phoneNumberTerxtField?.text = trimmedText
        
        // 2.1. update clear button mode
        if trimmedText.count > Constants.countOfShowClearButtonMode {
            phoneNumberTerxtField?.clearButtonMode = .whileEditing
        } else {
            phoneNumberTerxtField?.clearButtonMode = .never
        }
        
        // 3. validate trimmedText
        if trimmedText.count < Constants.countOfPhoneNumber {
            phoneNumberValidator(false)
            return
        }
        
        guard RYBaseTextField.isValidPhoneNumber(for: trimmedText) else {
            self.makeToast("手机号码格式错误", duration: 1.4, position: .center)
            DispatchQueue.main.async {
                self.phoneNumberTerxtField?.shake(for: "position.x")
            }
            phoneNumberValidator(false)
            return
        }
        
        // 4. go to password textfield when number is valid
        dismissKeyboard()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.14) {
            if let passwordTextField = self.passwordTextField, !passwordTextField.isFirstResponder {
                self.phoneNumberValidator(true)
                passwordTextField.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func passwordTextFieldEditingChanged(_ sender: UITextField) {
        // 1. guard input text
        guard let inputString = passwordTextField?.text, !inputString.isEmpty else {
            passwordValidator(false)
            return
        }
        
        // 2. trim text
        let trimmedText = inputString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            passwordValidator(false)
            return
        }
        
        // 3. update tracking property
        if trimmedText.count >= Constants.countOfPasswords {
            passwordValidator(true)
        } else {
            passwordValidator(false)
        }
    }
    
}

// MARK: - UI related

extension RYLoginAndRegiserToast {
    
    /// control confirm button enabled
    private func enabledConfirmButton(_ isEnabled: Bool) {
        
        guard confirmButton.isEnabled != isEnabled else { return }
        
        if isEnabled {
            confirmButton.isEnabled = true
            confirmButton.backgroundColor = RYColors.color(from: 0x306EE6)
            
        } else {
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = RYColors.color(from: 0xCECECE)
        }
    }
    
    /// Show activity indicator for login button
    private func showIndicatorViewInConfirmButton(_ isShow: Bool) {
        
        confirmButton.showIndicatorView(isShow, parentView: self)
        confirmButton.isEnabled = !isShow
        
        let buttonTitleText = isShow ? "" : (type == .login ? "登录" : "注册")
        confirmButton.setTitle(buttonTitleText, for: .normal)
    }
    
    /// control password textfield enabled
    private func enabledPasswordTextField(_ isEnabled: Bool) {
        
        guard let passwordTextField = passwordTextField else { return }
        passwordTextField.isEnabled = isEnabled
        if isEnabled {
            if let view = passwordTextField.viewWithTag(Constants.maskViewTag) {
                view.removeFromSuperview()
            }
        } else {
            if let _ = passwordTextField.viewWithTag(Constants.maskViewTag) { return }
            let view = UIView(frame: passwordTextField.bounds)
            view.tag = Constants.maskViewTag
            view.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.5)
            passwordTextField.addSubview(view)
            passwordTextField.bringSubviewToFront(view)
        }
    }
    
    private func phoneNumberTextFieldDidBeginEditing() {
        
        // 1. guard input text
        guard let inputString = phoneNumberTerxtField?.text, !inputString.isEmpty else {
            phoneNumberValidator(false)
            return
        }
        
        // 2. trim text
        let trimmedText = inputString.trimmingCharacters(in: CharacterSet(charactersIn: "\"_ *#-"))
        guard !trimmedText.isEmpty else {
            phoneNumberValidator(false)
            return
        }
        
        // 3. update tracking property
        if trimmedText.count == Constants.countOfPhoneNumber {
            phoneNumberValidator(true)
        } else {
            phoneNumberValidator(false)
        }
    }
    
    private func passwordTextFieldDidBeginEditing() {
        // 1. guard input text
        guard let inputString = passwordTextField?.text, !inputString.isEmpty else {
            passwordValidator(false)
            return
        }
        
        // 2. trim text
        let trimmedText = inputString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            passwordValidator(false)
            return
        }
        
        // 3. update tracking property
        if trimmedText.count >= Constants.countOfPasswords {
            passwordValidator(true)
        } else {
            passwordValidator(false)
        }
    }
    
    /// validate phone number
    private func phoneNumberValidator(_ invalid: Bool) {
        if invalid {
            enabledPasswordTextField(invalid)
        } else {
            enabledPasswordTextField(invalid)
            enabledConfirmButton(invalid)
        }
    }
    
    /// validate password
    private func passwordValidator(_ invalid: Bool) {
        isValidForPasswordCount = invalid
        enabledConfirmButton(invalid)
    }
}

// MARK: - UITextFieldDelegate

extension RYLoginAndRegiserToast: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let phoneNumberTextField = phoneNumberTerxtField, phoneNumberTextField == textField {
            phoneNumberTextFieldDidBeginEditing()
        }
        
        if let passwordTextField = passwordTextField, passwordTextField == textField {
            passwordTextFieldDidBeginEditing()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}


// MARK: - Helper method

extension RYLoginAndRegiserToast {
    
    func dismissKeyboard() {
        if phoneNumberTerxtField.isFirstResponder {
            phoneNumberTerxtField.resignFirstResponder()
        }
        
        if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
    }
    
    func phoneNumberString() -> String? {
        return phoneNumberTerxtField.text
    }
    
    func passwordString() -> String? {
        return passwordTextField.text
    }
    
    func disEnabledConfirmButton() {
        showIndicatorViewInConfirmButton(false)
    }
    
}

