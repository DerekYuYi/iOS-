//
//  RYLoginPannel.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/11.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import Toast_Swift

class RYLoginPannel: UIViewController {
    
    private struct Constants {
        static let normalStateColor = RYColors.color(from: 0x999999).withAlphaComponent(0.5)
        static let selectedStateColor = RYColors.color(from: 0x333333)
        static let cornerRadiusValue: CGFloat = 5.0
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginAreaView: UIView!
    
    // MARK: - Properties
    
    /// the internal property indicates that excute somethings for presenting view controller after dissmiss self.
    var backCallBack: ((_ username: String?) -> Void)?
    
    private lazy var loginToastView: RYLoginAndRegiserToast? = {
        
        let loginToast = produceToastView()
        loginToast?.update(.login)
        loginToast?.delegate = self
        return loginToast
        
    }()
    
    private var registerToastView: RYLoginAndRegiserToast?
    
    private var presentType: eRYConfirmType = .login {
        didSet(newValue) {  // should use willSet ????
            switch newValue {
            case .login:
                debugPrint("login")
            case .register:
                 debugPrint("register")
            }
        }
    }
    
    /// manage login and register requests
    private var requester: RYLoginRequester?
    
    private let toastBgColor = ToastManager.shared.style.backgroundColor
    private let toastTitleColor = ToastManager.shared.style.titleColor
    private let toastMessageColor = ToastManager.shared.style.messageColor
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Do any additional setup after loading the view.
        
        initialUI()
        
        // initial request
        requester = RYLoginRequester(self)
        
        // firstly show loginToast when view did load
        loginButton.isSelected = true
        registerButton.isSelected = !loginButton.isSelected
        presentType = .login
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ToastManager.shared.style.backgroundColor = .groupTableViewBackground
        ToastManager.shared.style.titleColor = .black
        ToastManager.shared.style.messageColor = .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configForUserInterfaceStyle()
    }
    
    fileprivate func configForUserInterfaceStyle() {
        ToastManager.shared.style.backgroundColor = toastBgColor
        ToastManager.shared.style.titleColor = toastTitleColor
        ToastManager.shared.style.messageColor = toastMessageColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginToastView?.frame = loginAreaView.bounds
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        // dismissa keyboard
        dismissKeyboard()
        
        // change button state is selected
        loginButton.isSelected = true
        registerButton.isSelected = !loginButton.isSelected
        
        // return if it's login type
        guard presentType == .register else { return }
        
        // transition: crossDissolve
        if let loginToast = self.loginToastView, let registerToast = self.registerToastView {
            UIView.transition(from:
                registerToast,
                              to: loginToast,
                              duration: 0.8,
                              options: .transitionFlipFromLeft,
                              completion: nil)
        }
        
        // update type
        presentType = .login
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        // create registerToastView when transit to register view
        if registerToastView == nil {
            let registerToast = produceToastView()
            registerToast?.update(.register)
            registerToast?.delegate = self
            registerToastView = registerToast
        }
        
        // dismissa keyboard
        dismissKeyboard()
        
        // change button state is selected
        registerButton.isSelected = true
        loginButton.isSelected = !registerButton.isSelected
        
        // return if it's register type
        guard presentType == .login else { return }
        
        // transition: crossDissolve
        if let loginToast = self.loginToastView, let registerToast = self.registerToastView {
            UIView.transition(from:
                loginToast,
                              to: registerToast,
                              duration: 0.8,
                              options: .transitionFlipFromRight,
                              completion: nil)
        }
        
        // update type
        presentType = .register
    }
    
}

// MARK: - UI related

extension RYLoginPannel {
    
    private func initialUI() {
        
        cornerView.layer.masksToBounds = true
        cornerView.layer.cornerRadius = Constants.cornerRadiusValue
        
        loginButton.setTitleColor(Constants.normalStateColor, for: .normal)
        loginButton.setTitleColor(Constants.selectedStateColor, for: .selected)
        
        registerButton.setTitleColor(Constants.normalStateColor, for: .normal)
        registerButton.setTitleColor(Constants.selectedStateColor, for: .selected)
    }
    
    /// load login and register toast view
    private func produceToastView() -> RYLoginAndRegiserToast? {
        
        if let views = Bundle.main.loadNibNamed(String(describing: RYLoginAndRegiserToast.self), owner: nil, options: nil),
            let toastView = views.first as? RYLoginAndRegiserToast {
            
            self.loginAreaView.addSubview(toastView)
            toastView.frame = self.loginAreaView.bounds
        
            return toastView
        }
        return nil
    }
    
    /// dismiss keyboard
    private func dismissKeyboard() {
        if let loginToast = self.loginToastView {
            loginToast.dismissKeyboard()
        }
            
        if let registerToast = registerToastView {
            registerToast.dismissKeyboard()
        }
    }
}

// MARK: - RYLoginAndRegiserToastDelegate

extension RYLoginPannel: RYLoginAndRegiserToastDelegate {
    
    func confirmAccount(_ confirmType: eRYConfirmType) {
        
        // dismiss keyboard
        dismissKeyboard()
        
        // request api
        if confirmType == .login {
            requester?.requestLogin()
            return
        }
        
        if confirmType == .register {
            requester?.requestRegister()
            return
        }
    }
}


// MARK: - Data Provider as Presenter (may be like MVP)

extension RYLoginPannel {
    
    /// provide phoneNumber to loginrequester
    func phoneNumber() -> String? {
        if presentType == .login {
            return loginToastView?.phoneNumberString()
        }
        if presentType == .register {
            return registerToastView?.phoneNumberString()
        }
        
        return nil
    }
    
    /// provide password to loginrequester
    func password() -> String? {
        if presentType == .login {
            return loginToastView?.passwordString()
        }
        if presentType == .register {
            return registerToastView?.passwordString()
        }
        
        return nil
    }
    
    func disEnabledConfirmButton() {
        if presentType == .login {
            loginToastView?.disEnabledConfirmButton()
        }
        if presentType == .register {
            registerToastView?.disEnabledConfirmButton()
        }
    }
    
    func showUIWhenLoginSuccessfully() {
        if presentType == .login {
            // show toast
            view.makeToast("登录成功", duration: 1.4, position: .center)
            
            // dismiss self pannel
            dismiss(animated: true, completion: nil)
            
            // reload person page if located at RYPreferencesPage
            if let backCallback = backCallBack {
                backCallback(RYProfileCenter.me.nickName)
            }
            
        } else {
            view.makeToast("注册成功, 请登录", duration: 1.4, position: .center)
            loginButtonTapped(loginButton)
        }
    }
    
    func showUIWhenLoginFailed() {
        let text = presentType == .login ? "账号或密码错误, 请重试" : "注册失败, 请重试"
        view.makeToast(text, duration: 1.4, position: .center)
    }
}

extension RYLoginPannel {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismissKeyboard()
    }
}

extension RYLoginPannel {
    
    static func presentLoginPannel(from viewController: UIViewController?, callBack:((String?) -> Void)? = nil) {
        guard let vc = viewController else { return }
        
        let mainStoryboard = UIStoryboard(storyboard: .Main)
        let loginPage: RYLoginPannel = mainStoryboard.instantiateViewController()
        loginPage.modalPresentationStyle = .overCurrentContext
        loginPage.modalTransitionStyle = .crossDissolve
        
        if let callBack = callBack {
            loginPage.backCallBack = callBack
        }
        
        vc.present(loginPage, animated: true, completion: nil)
    }
}
