//
//  RYLoginBoard.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/9.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

private let kRYGap: CGFloat = 3.0

enum ERYLoginBoardPresentMode {
    case login, register
}

class RYLoginBoard: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var loginNavigationBar: UINavigationBar!
    @IBOutlet weak var loginNavigationItem: UINavigationItem!
    @IBOutlet var closeBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var topLoginButton: UIButton!
    @IBOutlet weak var topRegisterButton: UIButton!
    @IBOutlet weak var trackingContentView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    private var presentMode: ERYLoginBoardPresentMode = .login {
        didSet(newValue) {
            switch newValue {
            case .register:
                if let registerTrackingView = registerTrackingView,
                    let loginTrackingView = loginTrackingView {
                    UIView.transition(from: registerTrackingView, to: loginTrackingView, duration: 0.7, options: UIView.AnimationOptions.transitionCrossDissolve, completion: nil)
                }
                
            case .login:
                if let registerTrackingView = registerTrackingView,
                    let loginTrackingView = loginTrackingView {
                    UIView.transition(from: loginTrackingView, to: registerTrackingView, duration: 0.7, options: UIView.AnimationOptions.transitionCrossDissolve, completion: nil)
                }
            }
        }
    }
    
    private var loginPage: RYLoginPage?
    
    private lazy var registerPage: RYRegisterPage? = {
        guard let registerVC = UIStoryboard.loginStoryboard_registerPage() else {
            return nil
        }
        
        registerVC.registerSuccessfullyHandler = {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.topLoginButtonTapped(strongSelf.topLoginButton)
        }
    
        addChild(registerVC)
        contentView.addSubview(registerVC.view)
        if let loginPage = self.loginPage {
            registerVC.view.frame = loginPage.view.frame
        }
        return registerVC
    }()
    
    private lazy var registerTrackingView: UIView? = {
        let view = UIView(frame: CGRect(x: trackingContentView.bounds.width - topRegisterButton.bounds.width + kRYGap, y: 0, width: topRegisterButton.bounds.width - kRYGap * 2, height: trackingContentView.bounds.height))
        view.backgroundColor = RYColors.yellow_theme
        view.roundedCorner(nil, view.bounds.height / 2.0)
        trackingContentView.addSubview(view)
        return view
    }()
    
    private lazy var loginTrackingView: UIView? = {
        let view = UIView(frame: CGRect(x: kRYGap, y: 0, width: topLoginButton.bounds.width - kRYGap * 2, height: trackingContentView.bounds.height))
        view.backgroundColor = RYColors.yellow_theme
        view.roundedCorner(nil, view.bounds.height / 2.0)
        trackingContentView.addSubview(view)
        return view
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. setup UI
        loginNavigationBar.tintColor = .black
        loginNavigationBar.isTranslucent = true
        let image = UIImage.image(from: .clear)
        loginNavigationBar.setBackgroundImage(image, for: .default)
        loginNavigationBar.shadowImage = UIImage()
        loginNavigationItem.rightBarButtonItems = [closeBarButtonItem]
        
        topLoginButton.setTitleColor(RYColors.black_999999, for: .normal)
        topLoginButton.setTitleColor(RYColors.black_333333, for: .selected)
        
        topRegisterButton.setTitleColor(RYColors.black_999999, for: .normal)
        topRegisterButton.setTitleColor(RYColors.black_333333, for: .selected)
        
        // 2. add login vc
        addLoginPage()
    }
    
    private func addLoginPage() {
        if let loginPage = UIStoryboard.loginStoryboard_loginPage() {
            loginPage.loginSuccessfullyHandler = {[weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            loginPage.resetPasswordHandler = {[weak self] in
                self?.transitionRegisterPage(.resetPassword)
            }
            
            addChild(loginPage)
            contentView.addSubview(loginPage.view)
            self.loginPage = loginPage
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 1. add constraint for loginPage
        if let loginPage = loginPage {
            loginPage.view.frame = contentView.bounds
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topLoginButton.isSelected = true
    }
    
    // MARK: - Touch Events
    /// dismiss
    @IBAction func closeBarButtonItemTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// CrossDissolve to loginPage
    @IBAction func topLoginButtonTapped(_ sender: UIButton) {
        topLoginButton.isSelected = true
        topRegisterButton.isSelected = !topLoginButton.isSelected
        
        guard presentMode == .register else {
            return
        }
        
        // CrossDissolve animation
        if let loginPage = self.loginPage, let registerPage = self.registerPage {
            UIView.transition(from: registerPage.view, to: loginPage.view, duration: 0.8, options: UIView.AnimationOptions.transitionCrossDissolve) { finished in
            }
            // update mode
            presentMode = .login
        }
    }
    
    /// CrossDissolve to register page
    @IBAction func topRegisterButtonTapped(_ sender: UIButton) {
        transitionRegisterPage(.register)
    }
    
    private func transitionRegisterPage(_ type: eRYVerficationCodeReceiveType) {
        topRegisterButton.isSelected = true
        topLoginButton.isSelected = !topRegisterButton.isSelected
        
        guard presentMode == .login else {
            return
        }
        
        if let loginPage = self.loginPage, let registerPage = self.registerPage {
            // set pagetype to register rather than resetpassword
            registerPage.pageType = type
            // CrossDissolve animation
            UIView.transition(from: loginPage.view, to: registerPage.view, duration: 0.8, options: UIView.AnimationOptions.transitionCrossDissolve) { finished in
            }
            
            // update mode
            presentMode = .register
        }
    }

}
