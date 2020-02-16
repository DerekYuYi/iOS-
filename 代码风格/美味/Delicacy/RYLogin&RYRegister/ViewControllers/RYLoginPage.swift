//
//  RYLoginPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/9.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Alamofire

private let kRYTagForTempViewInPasswordTextField: Int = 1009

class RYLoginPage: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loginButton: UIButton!
    
    
    var phoneNumberTextField: UITextField?
    var passwordTextField: UITextField?
    
    var isValidForPasswordCount = false
    var loginSuccessfullyHandler: (() -> Void)?
    var resetPasswordHandler: (() -> Void)?
    
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 2. corner
        loginButton.roundedCorner(nil, loginButton.bounds.height / 2.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // initial register button and textfields status
        enabledPasswordTextField(false)
        enabledLoginButton(false)
    }
    
    deinit {
        collectionView?.delegate = nil
    }
    
    // MARK: - Touch Events
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // show indicator
        showIndicatorViewForLoginButton(true)
        
        // check password and request
        if isValidForPasswordCount {
            requestLoginAPI()
        } else {
            RYUITweaker.simpleAlert("密码错误", message: "密码不能低于8位")
            showIndicatorViewForLoginButton(false)
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        if let resetPasswordHandler = resetPasswordHandler {
            resetPasswordHandler()
        }
    }
    
    func requestLoginAPI() {
        // guard and prapare url
        guard let url = URL(string: RYAPICenter.api_login()) else { return }
        
        // construct request
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        request.httpMethod = "POST"
        
        // Note: Generally, phone number and password have checked when input, so there is no need to check detailly.
        if let phoneNumber = phoneNumberTextField?.text,
            let password = passwordTextField?.text {
            let params = ["username": phoneNumber,
                          "password": password]
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
                strongSelf.showIndicatorViewForLoginButton(false)
            }
            
            switch response.result {
            case .success(let value):
                
                // NOTE: Save sessionid value to maintain login status
                let tempCookie = HTTPCookieStorage.shared
                if let tempCookies = tempCookie.cookies {
                    for item in tempCookies {
                        RYUserDefaultCenter.archiverSessionID(item.value)
                    }
                }
                
                let dict = try? JSONSerialization.jsonObject(with: value, options: .allowFragments)
                if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
                    // login successfully
                    if let data = dict["data"] as? [String: Any], data.count > 0 {
                        // retrieve profileData and update profile data
                        RYProfileCenter.me.profileData = RYProfileItem(data)
                    }
                    RYUITweaker.simpleAlert(nil, message: "登录成功", triggerOK: {
                        if let loginSuccessfullyHandler = strongSelf.loginSuccessfullyHandler {
                            loginSuccessfullyHandler()
                        }
                    })
                } else {
                    // login failed
                    RYUITweaker.simpleAlert(nil, message: "登录失败")
                }
                
            case .failure:
                // login failed
                RYUITweaker.simpleAlert(nil, message: "登录失败")
            }
        }
    }
    
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
        
        if let passwordTextField = passwordTextField,
            passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
    }
    
    /// Show activity indicator for login button
    private func showIndicatorViewForLoginButton(_ isShow: Bool) {
        loginButton.showIndicatorView(isShow, parentView: view)
        loginButton.isEnabled = !isShow
        let buttonTitleText = isShow ? "" : "登录"
        loginButton.setTitle(buttonTitleText, for: .normal)
    }
    
    /// Control the login button whether is enabled.
    private func enabledLoginButton(_ isEnabled: Bool) {
        guard loginButton.isEnabled != isEnabled else { return }
        loginButton.isEnabled = isEnabled
        if isEnabled {
            loginButton.setTitleColor(RYColors.black_333333, for: .normal)
            loginButton.backgroundColor = RYColors.yellow_theme
        } else {
            loginButton.setTitleColor(RYColors.black_333333.withAlphaComponent(0.4), for: .normal)
            loginButton.backgroundColor = RYColors.yellow_theme.withAlphaComponent(0.4)
        }
    }
    
    /// Control the password textfield whether is enabled.
    private func enabledPasswordTextField(_ isEnabled: Bool) {
        guard let passwordTextField = passwordTextField else { return }
        passwordTextField.isEnabled = isEnabled
        if isEnabled {
            if let view = passwordTextField.viewWithTag(kRYTagForTempViewInPasswordTextField) {
                view.removeFromSuperview()
            }
        } else {
            if let _ = passwordTextField.viewWithTag(kRYTagForTempViewInPasswordTextField) { return }
            let view = UIView(frame: passwordTextField.bounds)
            view.tag = kRYTagForTempViewInPasswordTextField
            view.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.5)
            passwordTextField.addSubview(view)
            passwordTextField.bringSubviewToFront(view)
        }
    }
}


extension RYLoginPage: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RYLoginCell", for: indexPath)
        if let cell = cell as? RYLoginCell {
            cell.delegate = self
            phoneNumberTextField = cell.phoneNumberTextField
            passwordTextField = cell.passwordTextfield
            phoneNumberTextField?.delegate = self
            passwordTextField?.delegate = self
        }
        return cell
    }
}

extension RYLoginPage: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

private let kRYCountOfPhoneNumber: Int = 11
private let kRYCountOfShowClearButtonMode: Int = 7
private let kRYCountOfPassword: Int = 8

extension RYLoginPage: UITextFieldDelegate, RYLoginCellDelegate {
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let phoneNumberTextField = phoneNumberTextField, phoneNumberTextField == textField {
            phoneNumberTextFieldDidBeginEditing()
        }
    
        if let passwordTextField = passwordTextField, passwordTextField == textField {
            passwordTextFieldDidBeginEditing()
        }
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
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    // MARK: - RYLoginCellDelegate
    func textFieldEditingChanged(_ textfield: UITextField) {
        if let phoneNumberTextField = phoneNumberTextField, phoneNumberTextField == textfield {
            phoneNumberTextFieldEditingChanged()
        }
        
        if let passwordTextField = passwordTextField, passwordTextField == textfield {
            passwordTextFieldEditingChanged()
        }
        
    }
    
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
        guard RYFormatter.isValidPhoneNumber(for: trimmedText) else {
            RYUITweaker.simpleAlert("手机号码格式错误", message: "手机号暂只支持中国大陆号码")
            DispatchQueue.main.async {
                self.phoneNumberTextField?.shake(for: "position.x")
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
    
    private func phoneNumberValidator(_ invalid: Bool) {
        if invalid {
            enabledPasswordTextField(invalid)
        } else {
            enabledPasswordTextField(invalid)
            enabledLoginButton(invalid)
        }
    }
    
    private func passwordValidator(_ invalid: Bool) {
        isValidForPasswordCount = invalid
        enabledLoginButton(invalid)
    }
}

extension RYLoginPage: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}


