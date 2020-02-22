//
//  RYLanuchPage.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/3/6.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import Alamofire

class RYLanuchPage: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var networkErrorImageView: UIImageView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    // MARK: - Public Interface
    /// Returns an instance of Class `RYLanuchPage`.
    @objc static func launchPage() -> RYLanuchPage? {
        let launchStoryboard = UIStoryboard(name: "Launch", bundle: nil)
        if let launchPage = launchStoryboard.instantiateViewController(withIdentifier: "RYLanuchPage") as? RYLanuchPage {
            return launchPage
        }
        return nil
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        setBackgroundImageView()
        
        networkErrorImageView.isUserInteractionEnabled = true
        networkErrorLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        showNetworkErrorViews(false)
        
        // access status
        accessAssistantStatus()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Request APIs
    
    private func accessAssistantStatus() {
        
        // 1. UI loading
        showNetworkErrorViews(false)
        
        // 2. request
        RYLaunchHelper.request(RYAPICenter.api_assistantControl(), method: .get, successHandler: { [weak self] data in
            
            guard let strongSelf = self else { return }
            
            strongSelf.showButton(false)
            
            if let content = data["data"] as? [String: Any], content.count > 0 {
                if let status = content["assistant_switch"] as? Int {
                    
                    if status == 1 {
                        debugPrint("\(#function) status is available.")
                        // check idfa is avaliable
                        let idfaString = RYDeviceInfoCollector.shared.identifierForAdvertising
                        if idfaString.isEmpty || (idfaString.hasPrefix("0000") && (idfaString.hasSuffix("0000"))) {
                            
                            let alert = UIAlertController(title: "温馨提示", message: "请到 设置 -> 隐私 -> 广告 关闭限制广告跟踪", preferredStyle: .alert)
                            
                            let okAction =  UIAlertAction(title: "确定", style: .cancel, handler: { _ in
                                self?.showButton(true)
                            })
                            alert.addAction(okAction)
                            strongSelf.present(alert, animated: true, completion: nil)
                            return
                        }
                        
                        // retrieve target url
                        var urlString: String?
                        if let adUrlString = content["jump_url"] as? String {
                            urlString = adUrlString
                        }
                        
                        // request preparation api
                        strongSelf.requestPreparationAPI(urlString)
                        
                    } else if status == 0 {
                        debugPrint("\(#function) status is unavailable.")
                        // go to homepage
                        RYAdsDataCenter.sharedInstance.requestAdsAPI()
                        strongSelf.whereToGo()
                    }
                }
            }
        }) { [weak self] error in
            guard let strongSelf = self else { return }
            
            if let statusCode = error as? Int, statusCode == 500 {
                debugPrint("\(#function) The services is unavailable.")
                // go to homepage if pre service is unavailabled
                RYAdsDataCenter.sharedInstance.requestAdsAPI()
                strongSelf.whereToGo()
                return
            } else {
                debugPrint(error ?? "\(#function) Somethings unknowed occured.")
            }
            
            // Show failure UI
            strongSelf.showButton(true)
            
            // Show error views
            strongSelf.showNetworkErrorViews(true)
        }
    }

    /// Requests preparation api.
    /// - Parameter targetUrlString: An url string that webview will opened.
    private func requestPreparationAPI(_ targetUrlString: String?) {
        
        guard let parameters = prepareParams() else {
            debugPrint("Parameters is nil")
            return
        }
        
        let encoding = JSONEncoding.default
        
        RYLaunchHelper.request(RYAPICenter.api_prepareList(),
                               method: .post,
                               parameters: parameters,
                               encoding: encoding,
                               successHandler: { [weak self] data in
            guard let strongSelf = self else { return }
            
            // go to webpage
            if let targetUrlString = targetUrlString, !targetUrlString.isEmpty {
                strongSelf.gotoEntryPage(to: targetUrlString)
            }
            
        }) {[weak self] error in
            guard let _ = self else { return }
            debugPrint("requestPreparationAPI failed.")
        }
    }
    
    private func prepareParams() -> [String: Any]? {
        let basicInfos = RYDeviceInfoCollector.shared.basicInfos()
        var aesInfos = basicInfos
        let validList = RYLaunchHelper.validList()
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        
        // basicInfos
        aesInfos.updateValue(validList, forKey: "app_list")
        aesInfos.updateValue(currentTimestamp, forKey: "timestamp")
        
        // Dictionary -> string -> aes -> base64
        let jsonData = try? JSONSerialization.data(withJSONObject: aesInfos, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        guard let aesInfosDatas = jsonData else { return nil }
        
        guard let aesInfosJsonString = String(data: aesInfosDatas, encoding: .utf8) else { return nil } // String.Encoding.ascii
        
        // 1. encrypt with aes
        let aesKey = RYEncryptHelper.generateKeysForAES()
        let iV = String(aesKey.prefix(16))
        
        guard let aesEncryptedBase64String = RYEncryptor.encryptedAES(aesKey, iV: iV, willBeEncryptedString: aesInfosJsonString) else {
            return nil
        }
        
        // 2. encrypt with rsa
        let assistantId = RYDeviceInfoCollector.shared.bundleIdentifier
        let deviceId = RYDeviceInfoCollector.shared.identifierForAdvertising
        let idfv = RYDeviceInfoCollector.shared.identifierForVerdor
        let isJailbroken = RYDeviceInfoCollector.adapter()
        let jointString =  "device_id=\(deviceId)&idfv=\(idfv)&assistant_id=\(assistantId)&is_jailbroken=\(isJailbroken)"
        
        guard let rsaEncryptedBase64String = RSA.encryptString(jointString, publicKey: RYEncryptHelper.rsaPublicString) else {
            return nil
        }
        
        var summaryParams = basicInfos
        summaryParams.updateValue(aesEncryptedBase64String, forKey: "data")
        summaryParams.updateValue(rsaEncryptedBase64String, forKey: "sign")
        
        return summaryParams
    }
    
    private func gotoEntryPage(to urlString: String) {
        let storybard = UIStoryboard(name: "WebPage", bundle: nil)
        
        if let entryPage = storybard.instantiateViewController(withIdentifier: String(describing: RYEntryPage.self)) as? RYEntryPage {
            let entryPageNav = RYBaseNavigationController(rootViewController: entryPage)
            entryPage.isRefreshOnTop = true
            entryPage.entryUrlString = urlString
            if #available(iOS 13.0, *) {
                entryPageNav.overrideUserInterfaceStyle = .light
            }
            entryPageNav.modalPresentationStyle = .fullScreen
            entryPageNav.modalTransitionStyle = .crossDissolve
            present(entryPageNav, animated: true, completion: nil)
        }
    }
    
    private func whereToGo() {
        if RYAdsPage.isEnableShowAdsPage() {
            RYAdsPage.presentAds(from: self)
        } else {
            if let app = UIApplication.shared.delegate as? AppDelegate {
                app.gotoHomePage(from: self)
            }
        }
    }
    
}

// MARK: - UI Related

private let kRYTagForBottomButton: Int = 2019

extension RYLanuchPage {
    private func showButton(_ isShow: Bool) {
        if isShow {
            if let _ = view.viewWithTag(kRYTagForBottomButton) as? RYBaseButton {
                return
            }
            let button = RYBaseButton(type: .system)
            button.setTitle("点击刷新", for: .normal)
            button.tag = kRYTagForBottomButton
            button.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(bottomButtonTapped), for: .touchUpInside)
            view.addSubview(button)
            
            // layout
            button.translatesAutoresizingMaskIntoConstraints = false
            
            let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
            let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48)
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: networkErrorLabel, attribute: .bottom, multiplier: 1.0, constant: 80)
            let centerXConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
            
            view.addConstraints([widthConstraint, heightConstraint, topConstraint, centerXConstraint])
            
        } else {
            if let button = view.viewWithTag(kRYTagForBottomButton) as? RYBaseButton {
                button.removeFromSuperview()
            }
        }
    }
    
    private func showNetworkErrorViews(_ isShow: Bool) {
        networkErrorImageView.isHidden = !isShow
        networkErrorLabel.isHidden = !isShow
    }
    
    private func setBackgroundImageView() {
        let imageName: String
        switch RYDisplay.inch {
        case .inch4:
            imageName = "launchImage4.png"
            
        case .inch47:
            imageName = "launchImage4.7.png"
            
        case .inch55:
             imageName = "launchImage5.5.png"
            
        case .inch58:
             imageName = "launchImage5.8.png"
            
        case .inch61:
             imageName = "launchImage6.1.png"
            
        case .inch65:
             imageName = "launchImage6.5.png"
            
        default:
            imageName = "launchImage5.8.png"
        }
        
        if let fileString = Bundle.main.path(forResource: imageName, ofType: nil),
            let image = UIImage(contentsOfFile: fileString) {
            bgImageView.image = image
        }
    }
}

extension RYLanuchPage {
    @objc private func bottomButtonTapped() {
        accessAssistantStatus()
    }
}

