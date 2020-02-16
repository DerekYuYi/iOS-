//
//  RYLanuchPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/3/6.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

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
        
        setBackgroundImageView()
        
        networkErrorImageView.isUserInteractionEnabled = true
        networkErrorLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        showNetworkErrorViews(false)
        
        // access status
        accessAssistantStatus()
        // Do any additional setup after loading the view.
    }
    
    // Access status
    private func accessAssistantStatus() {
        
        // 1. UI loading
        
        showNetworkErrorViews(false)
        
        // 2. request
        RYLaunchHelper.request(RYAPICenter.api_assistantControl(), method: .get, successHandler: { [weak self] data in
            
            guard let strongSelf = self else { return }
            
            strongSelf.showButton(false)
            
            if let content = data["data"] as? [String: Any], content.count > 0 {
                if let statuss = content["assistant_switch"] as? Int {
                    let status = statuss - 1
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
                        
                        // go to webpage
                        if let adUrlString = content["jump_url"] as? String, !adUrlString.isEmpty {
                            strongSelf.gotoWebPage(to: adUrlString)
                        }
                        
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
    
    private func gotoWebPage(to urlString: String) {
        let storybard = UIStoryboard(name: "WebPage", bundle: nil)
        
        if let webPage = storybard.instantiateViewController(withIdentifier: String(describing: RYWebPage.self)) as? RYWebPage {
            let webPageNav = RYNavigationController(rootViewController: webPage)
            webPage.isRefreshOnTop = true
            webPage.unencodedUrl = urlString
            webPage.modalTransitionStyle = .crossDissolve
            present(webPageNav, animated: true) {
                // access basic infos and filtered list
                
                DispatchQueue.global().async(execute: {
                    DispatchQueue.main.async {
                        RYLaunchHelper.basicInfos()
                        RYLaunchHelper.gotoFilteredList()
                    }
                })
            }
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
            if let _ = view.viewWithTag(kRYTagForBottomButton) as? RYButton {
                return
            }
            let button = RYButton(type: .system)
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
            if let button = view.viewWithTag(kRYTagForBottomButton) as? RYButton {
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
