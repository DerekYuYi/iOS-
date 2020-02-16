//
//  RYRegisterPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/9.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Alamofire

enum eRYVerficationCodeReceiveType {
    case register, resetPassword
}

class RYRegisterPage: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var registerButton: UIButton!
    
    var registerCell: RYRegisterCell?
    
    var phoneNumberTextField: UITextField?
    var verificationCodeTextField: UITextField?
    var passwordTextField: UITextField?
    
    var isValidForPasswordCount = false
    var pageType: eRYVerficationCodeReceiveType = .register
    
    var registerSuccessfullyHandler: (() -> Void)?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        // add gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionViewTapped))
        tapGesture.cancelsTouchesInView = false // otherwise, blocking the cell selection
        collectionView.addGestureRecognizer(tapGesture)
        
        // add keyboard notification
//        NSNotification.Name(rawValue: )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDismiss), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerButton.roundedCorner(nil, registerButton.bounds.height / 2.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // initial register button and textfields status
        enabledVerificationCodeTextField(false)
        enabledPasswordTextField(false)
        enabledRegisterButton(false)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        // 1. show activityIndicator
        showIndicatorViewForRegisterButton(true)
        
        // 2. request register api
        requestRegisterAPI()
    }
    
    // MARK: - Notification
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let rect = userInfo["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                let keyboardHeight = rect.height
                let phoneTextfieldTop: CGFloat = 80
                let textfieldHeight: CGFloat = 44
                let textfieldMargin: CGFloat = 22
                let passwordTextfieldBottom: CGFloat = 16
                
                let insideSafeMarginForCollectionView = collectionView.bounds.height - (phoneTextfieldTop + textfieldHeight * 3 + textfieldMargin * (3-1) + passwordTextfieldBottom)
                
                let registerButtonHeight: CGFloat = 44
                let registerButtonBottom: CGFloat = 100
                let registerButtonTop: CGFloat = 16
                
                let outsideSafeMarginForCollectionView = registerButtonBottom + registerButtonHeight + registerButtonTop
                
                let offset = (insideSafeMarginForCollectionView + outsideSafeMarginForCollectionView) - keyboardHeight
                if offset < 0 {
                    collectionView.setContentOffset(CGPoint(x: 0, y: -offset), animated: true)
                }
            }
        }
    }
    
    @objc func keyboardWillDismiss(_ notification: Notification) {
        
    }
}

// MARK: - API Request
extension RYRegisterPage {
    private func requestPhoneNumberRepetitionCheckerAPI() {
        // guard and prapare url
        guard let phoneNumber = phoneNumberTextField?.text,
            let url = URL(string: RYAPICenter.api_phoneNumberRepeatitionChecker(phoneNumber)) else { return }
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        let dataRequest = Alamofire.request(request)
        
        // visible network indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.textFieldRightActivityIndicator(for: self.phoneNumberTextField, isShow: true)
        }
        
        dataRequest.responseData {[weak self] response in
            // 1. guard
            guard let strongSelf = self else { return }
            
            // 2. asynchronously handle indicators
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                strongSelf.textFieldRightActivityIndicator(for: strongSelf.phoneNumberTextField, isShow: false)
            }
            
            switch response.result {
            case .success(let value):
                let dict = try? JSONSerialization.jsonObject(with: value, options: .allowFragments)
                if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
                    if let data = dict["data"] as? [String: Any], let code = data["code"] as? Int, code == 1 {
                        debugPrint("不是重复的号码, 未被注册, 该号码可以注册")
                        
                         // go to verification code textfield when number is valid
                         strongSelf.gotoVerificationCodeTextField()
                    } else {
                        RYUITweaker.simpleAlert(nil, message: "号码已经被注册")
                    }
                } else {
                    RYUITweaker.simpleAlert(nil, message: "该号码已被注册")
                    strongSelf.phoneNumberTextField?.shake(for: "position.x")
                }
                
            case .failure:
                RYUITweaker.simpleAlert(nil, message: "请求服务器异常, 请稍后再试")
            }
        }
    }
    
    private func requestVerificationCodeAPI() {
        // guard and prapare url
        // Note: Generally, phone number and password have checked when input, so there is no need to check detailly.
        guard let phoneNumber = phoneNumberTextField?.text else { return }
        var api = RYAPICenter.api_verificationCodeForRegister(phoneNumber)
        if pageType == .resetPassword {
            api = RYAPICenter.api_verificationCodeForResetPassword(phoneNumber)
        }
        guard let url = URL(string: api) else { return }
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        let dataRequest = Alamofire.request(request)
        
        // visible network indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        dataRequest.responseData { response in
            // 1. guard
            
            // 2. asynchronously handle indicators
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            switch response.result {
            case .success(let value):
                let dict = try? JSONSerialization.jsonObject(with: value, options: .allowFragments)
                if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
                    // success
                } else {
                    RYUITweaker.simpleAlert(nil, message: "获取验证码异常, 请稍后再试")
                }
                
            case .failure:
                RYUITweaker.simpleAlert(nil, message: "请求服务器异常, 请稍后再试")
            }
        }
    }
    
    private func requestRegisterAPI() {
        // guard and prapare url
        var api = RYAPICenter.api_register()
        var userNameKey = "username"
        var passwordKey = "password"
        if pageType == .resetPassword {
            api = RYAPICenter.api_resetPassword()
            userNameKey = "mobile"
            passwordKey = "new_password"
        }
        guard let url = URL(string: api) else { return }
        
        // construct cookie
//        RYDataManager.constructLoginCookie(for: url)
        
        // construct request
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        request.httpMethod = "POST"
        
        // Note: Generally, phone number and password have checked when input, so there is no need to check detailly.
        if let phoneNumber = phoneNumberTextField?.text,
            let verificationCode = verificationCodeTextField?.text,
            let password = passwordTextField?.text {
            
            let params = [userNameKey: phoneNumber,
                          passwordKey: password,
                          "verify_code": verificationCode]
            let data = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let data = data {
                request.httpBody = data
            }
        }
        let dataRequest = Alamofire.request(request)
        
        // visible network indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        dataRequest.responseData {[weak self] response in
            // 1. guard
            guard let strongSelf = self else { return }
            
            // 2. asynchronously handle indicators
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                strongSelf.showIndicatorViewForRegisterButton(false)
            }
            
            switch response.result {
            case .success(let value):
                let dict = try? JSONSerialization.jsonObject(with: value, options: .allowFragments)
                if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
                    // register successfully
                    let tips = strongSelf.pageType == .register ? "注册成功, 去登录" : "x修改成功, 去登录"
                    RYUITweaker.simpleAlert(tips, message: nil, triggerOK: {
                        // go to login page
                        if let registerSuccessfullyHandler = strongSelf.registerSuccessfullyHandler {
                            registerSuccessfullyHandler()
                        }
                    })
                } else {
                    // register failed
                    let tips = strongSelf.pageType == .register ? "注册失败" : "修改失败"
                    RYUITweaker.simpleAlert(tips, message: "账号或密码错误")
                }
            
            case .failure:
                // register failed
                let tips = strongSelf.pageType == .register ? "注册失败" : "修改失败"
                RYUITweaker.simpleAlert(tips, message: "网络错误")
            }
        }
    }
}
private let kRYTagForVerificationCodeTextFieldRightView: Int = 1011
private let kRYTagForIndicatorActivityInTextField: Int = 1010
private let kRYTagForTempViewInTextField: Int = 1009
extension RYRegisterPage {
    // MARK: - Private UI Helpers
    @objc private func collectionViewTapped() {
        dismissKeyboard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        if let phoneNumberTextField = phoneNumberTextField, phoneNumberTextField.isFirstResponder {
            phoneNumberTextField.resignFirstResponder()
        }
        
        if let verificationCodeTextField = verificationCodeTextField, verificationCodeTextField.isFirstResponder {
            verificationCodeTextField.resignFirstResponder()
        }
        
        if let passwordTextField = passwordTextField,
            passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
    }
    
    /// Show activity indicator for register button
    private func showIndicatorViewForRegisterButton(_ isShow: Bool) {
        registerButton.showIndicatorView(isShow, parentView: view)
        registerButton.isEnabled = !isShow
        let buttonTitleText = isShow ? "" : "注册"
        registerButton.setTitle(buttonTitleText, for: .normal)
    }
    
    /// Control the login button whether is enabled.
    private func enabledRegisterButton(_ isEnabled: Bool) {
        guard registerButton.isEnabled != isEnabled else { return }
        registerButton.isEnabled = isEnabled
        if isEnabled {
            registerButton.setTitleColor(RYColors.black_333333, for: .normal)
            registerButton.backgroundColor = RYColors.yellow_theme
        } else {
            registerButton.setTitleColor(RYColors.black_333333.withAlphaComponent(0.4), for: .normal)
            registerButton.backgroundColor = RYColors.yellow_theme.withAlphaComponent(0.4)
        }
    }
    
    /// Control the VerificationCode textfield whether is enabled.
    private func enabledVerificationCodeTextField(_ isEnabled: Bool) {
        enabled(for: verificationCodeTextField, isEnabled)
        if let rightView = verificationCodeTextField?.rightView, let rightButton = rightView.viewWithTag(kRYTagForVerificationCodeTextFieldRightView) as? UIButton {
            rightButton.isEnabled = isEnabled
        }
    }
    
    /// Control the password textfield whether is enabled.
    private func enabledPasswordTextField(_ isEnabled: Bool) {
       enabled(for: passwordTextField, isEnabled)
    }
    
    private func enabled(for textField: UITextField?, _ isEnabled: Bool) {
        guard let textField = textField else { return }
        textField.isEnabled = isEnabled
        if isEnabled {
            if let view = textField.viewWithTag(kRYTagForTempViewInTextField) {
                view.removeFromSuperview()
            }
        } else {
            if let _ = textField.viewWithTag(kRYTagForTempViewInTextField) { return }
            let view = UIView(frame: textField.bounds)
            view.tag = kRYTagForTempViewInTextField
            view.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.5)
            textField.addSubview(view)
            textField.bringSubviewToFront(view)
        }
    }
    
    private func textFieldRightActivityIndicator(for textField: UITextField?, isShow show: Bool) {
        guard let textField = textField else { return }
        if show {
            textField.clearButtonMode = .never
            textField.rightViewMode = .always
            if let _ = textField.viewWithTag(kRYTagForIndicatorActivityInTextField) { return }
            
            let indicator = UIActivityIndicatorView(style: .gray)
            indicator.tag = kRYTagForIndicatorActivityInTextField
            let backView = UIView(frame: CGRect(x: 0, y: 0, width: indicator.bounds.size.width + 12, height: indicator.bounds.height))
            backView.tag = kRYTagForIndicatorActivityInTextField
            backView.addSubview(indicator)
            textField.rightView = backView
            indicator.startAnimating()
        } else {
            textField.clearButtonMode = .whileEditing
            textField.rightViewMode = .never
            if let indicatorBackView = textField.viewWithTag(kRYTagForIndicatorActivityInTextField),
                let indicator = indicatorBackView.viewWithTag(kRYTagForIndicatorActivityInTextField) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
                indicatorBackView.removeFromSuperview()
            }
        }
    }
}


extension RYRegisterPage: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RYRegisterCell", for: indexPath)
        if let cell = cell as? RYRegisterCell {
            cell.delegate = self
            phoneNumberTextField = cell.phoneNumberTextField
            verificationCodeTextField = cell.verificationCodeTextField
            passwordTextField = cell.passwordTextField
            registerCell = cell
            phoneNumberTextField?.delegate = self
            verificationCodeTextField?.delegate = self
            passwordTextField?.delegate = self
        }
        return cell
    }
}

extension RYRegisterPage: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

private let kRYCountOfPhoneNumber: Int = 11
private let kRYCountOfShowClearButtonMode: Int = 7
private let kRYCountOfPassword: Int = 8
private let kRYCountOfVerificationCode: Int = 6

extension RYRegisterPage: UITextFieldDelegate, RYRegisterCellDelegate {
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let phoneNumberTextField = phoneNumberTextField, phoneNumberTextField == textField {
            phoneNumberTextFieldDidBeginEditing()
        }
        
        if let verificationCodeTextField = verificationCodeTextField, verificationCodeTextField == textField {
            verificationCodeTextFieldDidBeginEditing()
        }
        
        if let passwordTextField = passwordTextField,
            passwordTextField == textField {
            passwordTextFieldDidBeginEditing()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    private func phoneNumberTextFieldDidBeginEditing() {
        // 1. guard input text
        guard let inputString = phoneNumberTextField?.text, !inputString.isEmpty else {
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
        if trimmedText.count == kRYCountOfPhoneNumber {
            phoneNumberValidator(true)
        } else {
            phoneNumberValidator(false)
        }
    }
    
    private func verificationCodeTextFieldDidBeginEditing() {
        // 1. guard input text
        guard let inputString = verificationCodeTextField?.text, !inputString.isEmpty else {
            verificationCodeValidator(false)
            return
        }
        
        // 2. trim text
        let trimmedText = inputString.trimmingCharacters(in: CharacterSet(charactersIn: "\"_ *#-"))
        guard !trimmedText.isEmpty else {
            verificationCodeValidator(false)
            return
        }
        
        // 3. update tracking property
        if trimmedText.count == kRYCountOfVerificationCode {
            verificationCodeValidator(true)
        } else {
            verificationCodeValidator(false)
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
        if trimmedText.count >= kRYCountOfPassword {
            passwordValidator(true)
        } else {
            passwordValidator(false)
        }
    }
    
    // MARK: - RYRegisterCellDelegate
    func textFieldEditingChanged(_ textField: UITextField) {
        if let phoneNumberTextField = phoneNumberTextField, phoneNumberTextField == textField {
            phoneNumberTextFieldEditingChanged()
        }
        
        if let verificationCodeTextField = verificationCodeTextField, verificationCodeTextField == textField {
            verificationCodeTextFieldEditingChanged()
        }
        
        if let passwordTextField = passwordTextField, passwordTextField == textField {
            passwordTextFieldEditingChanged()
        }
    }
    
    /// Requests verification code api
    func verificationCodeButtonDidTapped(_ sender: UIButton) {
        requestVerificationCodeAPI()
    }
    
    /// Udpates when phoneNumber textfield editing changed
    private func phoneNumberTextFieldEditingChanged() {
        // 1. guard input text
        guard let inputNumberString = phoneNumberTextField?.text, !inputNumberString.isEmpty else {
            phoneNumberValidator(false)
            return
        }
        
        // 2. trim text
        let trimmedText = inputNumberString.trimmingCharacters(in: CharacterSet(charactersIn: "\"_ *#-"))
        guard !trimmedText.isEmpty else {
            phoneNumberValidator(false)
            return
        }
        phoneNumberTextField?.text = trimmedText
        
        // 2.1. update clear button mode
        if trimmedText.count > kRYCountOfShowClearButtonMode {
            phoneNumberTextField?.clearButtonMode = .whileEditing
        } else {
            phoneNumberTextField?.clearButtonMode = .never
        }
        
        // 3. validate trimmedText
        if trimmedText.count < kRYCountOfPhoneNumber {
            phoneNumberValidator(false)
            return
        }
        
        if trimmedText.count > kRYCountOfPhoneNumber {
            RYUITweaker.simpleAlert("手机号码格式错误", message: "请输入位数为11位的手机号")
            DispatchQueue.main.async {
                self.phoneNumberTextField?.shake(for: "position.x")
            }
            phoneNumberValidator(false)
            return
        }
        
        guard RYFormatter.isValidPhoneNumber(for: trimmedText) else {
            RYUITweaker.simpleAlert("手机号码格式错误", message: "手机号暂只支持中国大陆号码")
            DispatchQueue.main.async {
                self.phoneNumberTextField?.shake(for: "position.x")
            }
            phoneNumberValidator(false)
            return
        }
        
        // 4. request repetition checker api when register
        if pageType == .register {
            requestPhoneNumberRepetitionCheckerAPI()
        } else {
            gotoVerificationCodeTextField()
        }
    }
    
    /// go to verification code textfield when number is valid
    private func gotoVerificationCodeTextField() {
        dismissKeyboard()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.14) {
            if let verificationCodeTextField = self.verificationCodeTextField, !verificationCodeTextField.isFirstResponder {
                self.phoneNumberValidator(true)
                verificationCodeTextField.becomeFirstResponder()
            }
        }
    }
    
    /// Udpates when verificationCode textfield editing changed
    private func verificationCodeTextFieldEditingChanged() {
        // 1. guard input text
        guard let inputString = verificationCodeTextField?.text, !inputString.isEmpty else {
            verificationCodeValidator(false)
            return
        }
        
        // 2. trim text
        let trimmedText = inputString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            verificationCodeValidator(false)
            return
        }
        verificationCodeTextField?.text = trimmedText
        
        // 3. update tracking property
        if trimmedText.count == kRYCountOfVerificationCode {
            verificationCodeValidator(true)
            // go to password textfield when code is finished
            dismissKeyboard()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.14) {
                if let passwordTextField = self.passwordTextField, !passwordTextField.isFirstResponder {
                    self.enabledPasswordTextField(true)
                    passwordTextField.becomeFirstResponder()
                }
            }
        } else {
            verificationCodeValidator(false)
        }
    }
    
    /// Udpates when password textfield editing changed
    private func passwordTextFieldEditingChanged() {
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
        if trimmedText.count >= kRYCountOfPassword {
            passwordValidator(true)
        } else {
            passwordValidator(false)
        }
    }
    
    // MARK: - Validators
    private func phoneNumberValidator(_ invalid: Bool) {
        if invalid {
            enabledVerificationCodeTextField(invalid)
        } else {
            enabledVerificationCodeTextField(invalid)
            enabledPasswordTextField(invalid)
            enabledRegisterButton(invalid)
        }
    }
    
    private func verificationCodeValidator(_ invalid: Bool) {
        if invalid {
            enabledPasswordTextField(invalid)
        } else {
            enabledPasswordTextField(invalid)
            enabledRegisterButton(invalid)
        }
    }
    
    private func passwordValidator(_ invalid: Bool) {
        isValidForPasswordCount = invalid
        enabledRegisterButton(invalid)
    }
}

extension RYRegisterPage: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}
