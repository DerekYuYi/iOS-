//
//  RYRegisterCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/9.
//  Copyright © 2018 RuiYu. All rights reserved.
//

// 比较好的优化做法是: 把关于 Textfield 的自定义操作, 都封装在 TextField 的子类中, 对外提供接口, 比如自定义 rightView, 自定义 leftView, 不同的 rightView 之间的状态切换

import UIKit

private let kRYTagForVerificationCodeTextFieldRightButton: Int = 1011
private let kRYTagForVerificationCodeTextFieldRightLabel: Int = 1011
private let kRYCountOfCountDown: Int = 59

protocol RYRegisterCellDelegate: NSObjectProtocol {
    func textFieldEditingChanged(_ textField: UITextField)
    func verificationCodeButtonDidTapped(_ sender: UIButton)
}

private let kRYNormalGap: CGFloat = 12.0

class RYRegisterCell: UICollectionViewCell {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var delegate: RYRegisterCellDelegate?
    
    private var countDownLabel: UILabel?
    private var downCount: Int = kRYCountOfCountDown {
        didSet(newValue) {
            countDownLabel?.text = "(\(newValue))s重新获取"
            if downCount == 0 {
                self.timer?.invalidate()
                self.timer = nil
                countDownLabel?.removeFromSuperview()
                countDownLabel = nil
                showCountDownViewInVerificationCodeTextFieldRightView(false)
            }
        }
    }
    private var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 1. setup textFields
        var font = RYFormatter.font(for: .regular, fontSize: 17)
        if UIScreen.main.bounds.width == 320.0 {
            font = RYFormatter.font(for: .regular, fontSize: 14)
        }
        phoneNumberTextField.roundedCorner(RYColors.color(from: 0xdddedd), 22.0)
        phoneNumberTextField.tintColor = RYColors.yellow_theme
        phoneNumberTextField.keyboardType = .numberPad
        phoneNumberTextField.font = font
        
        verificationCodeTextField.roundedCorner(RYColors.color(from: 0xdddedd), 22.0)
        verificationCodeTextField.tintColor = RYColors.yellow_theme
        verificationCodeTextField.keyboardType = .numberPad
        verificationCodeTextField.font = font
        
        passwordTextField.roundedCorner(RYColors.color(from: 0xdddedd), 22.0)
        passwordTextField.tintColor = RYColors.yellow_theme
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .continue
        passwordTextField.font = font
        
        // 2. custom leftviews or rightsviews
        
        // 2.1 phoneNumberTextField's leftView
        configLeftView(for: phoneNumberTextField, UIImage(named: "phone"))
        
        // 2.2 verificationCodeTextField's leftView and rightView
        configLeftView(for: verificationCodeTextField, UIImage(named: "password"))
        configVerificationCodeTextFieldRightButton()
        
        // 2.3 passwordTextfield's leftView and rightView
        configLeftView(for: passwordTextField, UIImage(named: "lock"))
        configPasswordTextFieldRightView()
    }
    
    /// Left Views pattern customization
    private func configLeftView(for textField: UITextField, _ image: UIImage?) {
        guard let image = image else { return }
        textField.leftViewMode = .always
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width + kRYNormalGap + 5, height: image.size.height))
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: kRYNormalGap, y: 0, width: image.size.width, height: image.size.height)
        leftView.addSubview(imageView)
        textField.leftView = leftView
    }
    
    private func configVerificationCodeTextFieldRightButton() {
        verificationCodeTextField.rightViewMode = .always
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 80 + kRYNormalGap + 10, height: 30))
        let seperatorView = UIView(frame: CGRect(x: 0, y: (30-16)/2, width: 1, height: 16))
        seperatorView.backgroundColor = RYColors.color(from: 0xD8D8D8)
        
        let rightButton = UIButton(type: .system)
        rightButton.tag = kRYTagForVerificationCodeTextFieldRightButton
        rightButton.tintColor = .black
        rightButton.frame = CGRect(x: seperatorView.frame.maxX + 9, y: 0, width: 80, height: 30)
        rightButton.setTitle("获取验证码", for: .normal)
        rightButton.setTitleColor(RYColors.black_333333, for: .normal)
        rightButton.setTitleColor(RYColors.black_333333.withAlphaComponent(0.3), for: .disabled)
        rightButton.titleLabel?.font = RYFormatter.fontLarge(for: .regular)
        rightButton.addTarget(self, action: #selector(verificationCodeButtonTapped), for: .touchUpInside)
        
        rightView.addSubview(seperatorView)
        rightView.addSubview(rightButton)
        verificationCodeTextField.rightView = rightView
    }
    
    private func configPasswordTextFieldRightView() {
        guard let eyelashImage = UIImage(named: "eyelash") else { return }
        
        passwordTextField.rightViewMode = .always
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: eyelashImage.size.width + kRYNormalGap, height: eyelashImage.size.height))
        let rightButton = UIButton(type: .system)
        rightButton.tintColor = .black
        rightButton.frame = CGRect(x: 0, y: 0, width: eyelashImage.size.width, height: eyelashImage.size.height)
        rightButton.setImage(eyelashImage, for: .normal)
        rightButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
        rightView.addSubview(rightButton)
        passwordTextField.rightView = rightView
    }
    
    // MARK: - Touch Events
    
    @IBAction func phoneNumberTextFieldEditingChanged(_ sender: UITextField) {
        delegate?.textFieldEditingChanged(sender)
    }
    
    @IBAction func verificationCodeTextFieldEditingChanged(_ sender: UITextField) {
        delegate?.textFieldEditingChanged(sender)
    }
    
    @IBAction func passwordTextFieldEditingChanged(_ sender: UITextField) {
        delegate?.textFieldEditingChanged(sender)
    }
    
    @objc private func eyeButtonTapped(_ sender: UIButton) {
        if passwordTextField.isSecureTextEntry {
            sender.setImage(UIImage(named: "eye"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "eyelash"), for: .normal)
        }
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    }
    
    @objc private func verificationCodeButtonTapped(_ sender: UIButton) {
        delegate?.verificationCodeButtonDidTapped(sender)
        // show count down label
        UIView.animate(withDuration: 0.3, animations: {
            self.verificationCodeTextField.rightView?.alpha = 0.0
        }) { isFinished in
            self.verificationCodeTextField.rightView = nil
            // reset downcount
            self.downCount = kRYCountOfCountDown
            // setup countdown label
            self.showCountDownViewInVerificationCodeTextFieldRightView(true)
            // add timer for countdown
            let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
            self.timer = timer
            // add timer to default runloop
            RunLoop.main.add(timer, forMode: .default)
        }
    }
    
    @objc private func countDown() {
        if let _ = self.timer {
            downCount -= 1
        }
    }
    
    // MARK: - UI Binding
    private func showCountDownViewInVerificationCodeTextFieldRightView(_ isShow: Bool) {
        if isShow {
            if let _ = self.countDownLabel { return }
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
            let countDownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 110, height: 30))
            countDownLabel.textColor = RYColors.black_999999
            countDownLabel.font = RYFormatter.fontLarge(for: .regular)
            countDownLabel.text = "(\(downCount))s重新获取"
            countDownLabel.textAlignment = .center
            view.addSubview(countDownLabel)
            self.countDownLabel = countDownLabel
            verificationCodeTextField.rightView = view
        } else {
            // remove
            if let countDownLabel = self.countDownLabel {
                countDownLabel.removeFromSuperview()
            }
            
            // add button
            configVerificationCodeTextFieldRightButton()
        }
    }
}
