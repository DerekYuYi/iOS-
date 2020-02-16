//
//  RYWebPage.swift
//  YunLingTenemental
//
//  Created by DerekYuYi on 2018/8/7.
//  Copyright © 2018年 RuiYu. All rights reserved.
//
/*
 Abstract:
          Manages all requests related webview and all interactive between JS and webview.
 */

import UIKit
import WebKit

let nRYNotificationForWechatLoginSuccessfully = "wechatLoginedSuccessfully"

class RYWebPage: UIViewController {
    
    private struct Constants {
        static let checkAppStatus = "checkAppStatus"
        static let isIdfaAvailable = "isIdfaAvailable"
        static let wechatShare = "wechatShare"
        static let wechatLogin = "wechatLogin"
        static let observedKeyPath = "title"
        static let tagForTipsLabel: Int = 801
        
        static let minimumPressDuration: TimeInterval = 15
        static let minimumFontSizeOfWebView: CGFloat = 6
        
        static var isPresenting = false
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var refreshBarButtonItem: UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(refreshBarButtonItemTapped))
        return barButtonItem
    }
    
    private var activityBarButtonItem: UIBarButtonItem {
        let activityView = UIActivityIndicatorView(style: .gray)
        let barButtonItem = UIBarButtonItem(customView: activityView)
        activityView.startAnimating()
        return barButtonItem
    }
    
    private var webView: WKWebView?
    var hookingVC: UIViewController? // Saving vc for adding colse button on navigation bar items, and operating action of close webpage.
    var unencodedUrl: String = ""
    var isRefreshOnTop = false // A boolean value indicates there are two positions for show UIActivityIndicatorView: rightBarButtonItem and center of self.view.
    private var isFirstRefresh = true // A boolean value Indicates whether loading webpage is the first time. return false if has already loaded webpage.
    
    
    lazy var alertViewController = UIAlertController(title: "Choose Channel", message: nil, preferredStyle: .actionSheet) // Show in debug. You can ignore it when you are product.
    
    // MARK: - Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYWebPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYWebPage()
    }
    
    func setup_RYWebPage() {
    }
    
    // MARK: - Deinit
    deinit {
        webView?.stopLoading()
        webView?.removeObserver(self, forKeyPath: Constants.observedKeyPath)
        webView?.removeObserver(self, forKeyPath: nRYNotificationForWechatLoginSuccessfully)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: Constants.checkAppStatus)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: Constants.isIdfaAvailable)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: Constants.wechatShare)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: Constants.wechatLogin)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        activityIndicatorView.isHidden = isRefreshOnTop
        
        if let navbar = self.navigationController?.navigationBar {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction))
            longPressGesture.minimumPressDuration = Constants.minimumPressDuration
            navbar.addGestureRecognizer(longPressGesture)
        }
        
        // 1. set webview preferences
        let preferences = WKPreferences()
        preferences.minimumFontSize = Constants.minimumFontSizeOfWebView
        
        // 2. set configuration
        let configuration = WKWebViewConfiguration()
        /*
         configuration.applicationNameForUserAgent = " " + RYDeviceInfoCollector.shared.bundleIdentifier + "/" + RYDeviceInfoCollector.shared.appBuildVersion
         */
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
        
        // uses RYWKLeakAvoider to prevent retain cycle
        let leakAvoider = RYWKLeakAvoider(self)
        configuration.userContentController.add(leakAvoider, name: Constants.checkAppStatus)
        configuration.userContentController.add(leakAvoider, name: Constants.isIdfaAvailable)
        configuration.userContentController.add(leakAvoider, name: Constants.wechatShare)
        configuration.userContentController.add(leakAvoider, name: Constants.wechatLogin)
        
        // 3. setup webView
        let height: CGFloat = RYFormatter.navigationBarPlusStatusBarHeight(for: self)
        let webViewFrame = CGRect(x: 0, y: height, width: view.bounds.width, height: view.bounds.height - height)
        webView = WKWebView(frame: webViewFrame, configuration: configuration)
        if let webView = webView,
            let urlString = unencodedUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !urlString.isEmpty {
            
            webView.customUserAgent = RYUserDefaultCenter.webViewCustomUserAgent()
            
            //            view.addSubview(webView)
            view.insertSubview(webView, at: 0)
            
            webView.allowsLinkPreview = false
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.addObserver(self, forKeyPath: Constants.observedKeyPath, options: .new, context: nil)
            
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
                webView.load(request)
            }
        }
        
        // 4. configuration
        if #available(iOS 11.0, *) {
            webView?.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        // 5. receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(wechatLogined), name: NSNotification.Name(nRYNotificationForWechatLoginSuccessfully), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height: CGFloat = RYFormatter.navigationBarPlusStatusBarHeight(for: self)
        webView?.frame = CGRect(x: 0, y: height, width: view.bounds.width, height: view.bounds.height - height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Loading Life Style
    private func beginLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if isRefreshOnTop {
            if isFirstRefresh {
                activityIndicatorView.isHidden = false
                activityIndicatorView.startAnimating()
                navigationItem.rightBarButtonItems = []
            } else {
                navigationItem.rightBarButtonItems = [activityBarButtonItem]
            }
            
        } else {
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
        }
    }
    
    private func endLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if isRefreshOnTop {
            if isFirstRefresh {
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
                isFirstRefresh = false
            }
            navigationItem.rightBarButtonItems = [refreshBarButtonItem]
            
        } else {
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
        }
    }
    
    // MARK: - BarButtonItem Tap Action
    @objc private func refreshBarButtonItemTapped(_ sender: UIBarButtonItem) {
        webView?.reload()
        //        webView?.reloadFromOrigin()
    }
}

// MARK: - WKNavigationDelegate
extension RYWebPage: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let _ = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        // catch key fields such as suffix, prefix, udid, ..., and then handle new url(reload ?)
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if urlString.hasPrefix("https://itunes.apple.com") || urlString.contains("//itunes.apple.com/") {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:]) { bool in
                            self.navigationController?.popViewController(animated: false)
                        }
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                    
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
        return
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        return
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        beginLoading()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        endLoading()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        debugPrint("2 - webView didCommit")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        endLoading()
        
        let infos: [String: Any] = ["idfa": RYDeviceInfoCollector.shared.identifierForAdvertising,
                                    "idfv": RYDeviceInfoCollector.shared.identifierForVerdor,
                                    "bundleId": RYDeviceInfoCollector.shared.bundleIdentifier,
                                    "version": RYDeviceInfoCollector.shared.appBuildVersion,
                                    "isApp": true,
                                    "jailBreak": RYDeviceInfoCollector.adapter(),
                                    "isWXInstalled": RYWechatManager.isWechatInstalled()]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: infos, options: JSONSerialization.WritingOptions.prettyPrinted)
        if let jsonData = jsonData {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                webView.evaluateJavaScript("getInitialInfo(\(jsonString))") { (result, error) in
                    debugPrint(result ?? "no result")
                    debugPrint(error ?? "no error")
                }
            }
        }
        
        // Prevents popping alertViewController when long press interactive content of webview.
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';", completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        endLoading()
    }
}

// MARK: - WKScriptMessageHandler
extension RYWebPage: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Constants.checkAppStatus {
            if let bodyString = message.body as? String,
                let url = URL(string: bodyString) {
                UIApplication.shared.open(url, options: [:]) { result in
                    // NOTE: `result` is Bool indicating whether the URL was opened successfully, is not optional, but sometimes its value is nil. It's the opposite of Develper Documentation. So we build a optional parameter to receive its value to preventing exceptions.
                    let logicResult: Bool? = result
                    if let logic = logicResult, logic {
                        self.webView?.evaluateJavaScript("saveAppStatus(\(true))", completionHandler: { (result, error) in
                            debugPrint(result ?? "no result")
                            debugPrint(error ?? "no error")
                        })
                    } else {
                        self.webView?.evaluateJavaScript("saveAppStatus(\(false))", completionHandler: { (result, error) in
                            debugPrint(result ?? "no result")
                            debugPrint(error ?? "no error")
                        })
                    }
                }
            }
        } else if message.name == Constants.isIdfaAvailable {
            if let bodyString = message.body as? String {
                debugPrint(bodyString)
            }
            
            DispatchQueue.main.async {
                var idfaString = RYDeviceInfoCollector.shared.identifierForAdvertising
                if idfaString.isEmpty || (idfaString.hasPrefix("0000") && (idfaString.hasSuffix("0000"))) {
                    idfaString = ""
                }
                
                self.webView?.evaluateJavaScript("updateIdfaStatus(`\(idfaString)`)", completionHandler: { (result, error) in
                    debugPrint(result ?? "no result")
                    debugPrint(error ?? "no error")
                })
            }
        } else if message.name == Constants.wechatShare {
            // access share data
            if let body = message.body as? [String: Any], body.count > 0 {
                
                if let shareScene = body["shareScene"] as? Int, let shareData = body["shareData"] as? [String: Any], shareScene >= 0, shareData.count > 0 {
                    RYWechatManager.shareToWechat(for: WXScene(UInt32(shareScene)), objectType: .webpage, objectData: shareData)
                }
            }
        } else if message.name == Constants.wechatLogin {
            // start wechat login
            RYWechatManager.wechatLogin()
        }
    }
}

// MARK: - WKScriptMessageHandler
extension RYWebPage: WKUIDelegate {
    // alert panel
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
        
        if RYUserDefaultCenter.isDebugMode() {
            let alertVC = UIAlertController(title: "提示", message: "\(message)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertVC.addAction(okAction)
            alertVC.addAction(cancelAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    // confirm panel
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        debugPrint("\(#function)")
    }
    
    // text input panel
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        debugPrint("\(#function)")
    }
}


// MARK: - Observers
extension RYWebPage {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, !keyPath.isEmpty else { return }
        guard let object = object as? WKWebView, object == webView else { return }
        
        if keyPath == Constants.observedKeyPath {
            DispatchQueue.main.async {
                self.navigationItem.title = object.title
            }
        }
    }
}


// MARK: - Public Interfaces
extension RYWebPage {
    
    static func showWebPage(_ urlString: String, webTitle title: String?, fromVC viewController: UIViewController) {
        
        if urlString.hasPrefix("https://itunes.apple.com") || urlString.contains("//itunes.apple.com/") {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                }
            }
        } else {
            let storyboard = UIStoryboard(name: "WebPage", bundle: nil)
            
            if let webPage = storyboard.instantiateViewController(withIdentifier: String(describing: RYWebPage.self)) as? RYWebPage {
                webPage.unencodedUrl = urlString
                if let vc = viewController as? UINavigationController {
                    vc.pushViewController(webPage, animated: true)
                    return
                } else if let vc = viewController.navigationController {
                    vc.pushViewController(webPage, animated: true)
                }
            }
        }
        // more effects: present ...
    }
    
    /// Invoked when wechat logined successfully.
    /// - Parameter notification: NSNotification instance that post from wechat successfully logined block.
    @objc private func wechatLogined(_ notification: NSNotification) {
        
        guard let data = notification.userInfo, data.count > 0 else { return }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
        if let jsonData = jsonData {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                self.webView?.evaluateJavaScript("wechatDidLogined(\(jsonString))") { (result, error) in
                    debugPrint(result ?? "no result")
                    debugPrint(error ?? "no error")
                }
            }
        }
    }
    
    /// Config custom user agent
    /// - note: Generally, developer call the function when app launched, such as `didFinishLaunchingWithOptions`.
    @objc static func configCustomUserAgent() {
        
        var webview: WKWebView? = WKWebView()
        
        webview?.evaluateJavaScript("navigator.userAgent") { (result, error) in
            guard let userAgent = result as? String else { return }
            
            let customUserAgent = userAgent + " " + RYDeviceInfoCollector.shared.bundleIdentifier + "/" + RYDeviceInfoCollector.shared.appBuildVersion
            RYUserDefaultCenter.assembleWebViewUserAgent(customUserAgent)
            
            webview = nil
        }
    }
}

// MARK: - Debug

extension RYWebPage {
    @objc private func longPressGestureAction(_ sender: UILongPressGestureRecognizer) {
        if alertViewController.isBeingPresented {
            return
        }
        
        alertViewController = UIAlertController(title: "Choose Channel", message: nil, preferredStyle: .actionSheet)
        
        let productAction = UIAlertAction(title: "Production", style: .default) {[weak self] action in
            guard let strongSelf = self, let _ = strongSelf.webView else { return }
            
            // set value
            if RYUserDefaultCenter.isDebugMode() {
                RYUserDefaultCenter.setDebugMode(false)
            }
            
            // show tips
            DispatchQueue.main.async {
                strongSelf.tips(for: "已切换为正式", duration: 1.2)
            }
        }
        
        let debugAction = UIAlertAction(title: "Debug", style: .default) {[weak self] action in
            guard let strongSelf = self, let _ = strongSelf.webView else { return }
            
            if !RYUserDefaultCenter.isDebugMode() {
                RYUserDefaultCenter.setDebugMode(true)
            }
            
            // show tips
            DispatchQueue.main.async {
                strongSelf.tips(for: "已切换为测试", duration: 1.2)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) {[weak self] action in
            guard let strongSelf = self else { return }
            strongSelf.alertViewController.dismiss(animated: true, completion: nil)
        }
        
        alertViewController.addAction(productAction)
        alertViewController.addAction(debugAction)
        alertViewController.addAction(cancelAction)
        
        present(alertViewController, animated: true, completion: nil)
    }
    
    private func tips(for text: String, duration: TimeInterval) {
        
        let tipLabel = tipsLabel(text)
        tipLabel.alpha = 0.0
        
        UIView.animate(withDuration: duration, animations: {
            tipLabel.isHidden = false
            tipLabel.alpha = 1.0
        }, completion: { _ in
            tipLabel.isHidden = true
            tipLabel.removeFromSuperview()
            self.alertViewController.dismiss(animated: true, completion: nil)
        })
    }
    
    private func tipsLabel(_ text: String) -> UILabel {
        if let label = view.viewWithTag(Constants.tagForTipsLabel) as? UILabel {
            label.isHidden = true
            return label
        } else {
            let tipLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 50))
            tipLabel.tag = Constants.tagForTipsLabel
            tipLabel.text = text
            tipLabel.backgroundColor = UIColor.groupTableViewBackground
            tipLabel.textColor = .black
            tipLabel.font = UIFont(name: "PingFangSC-Semibold", size: 20.0)
            tipLabel.textAlignment = .center
            tipLabel.layer.masksToBounds = true
            tipLabel.layer.cornerRadius = 5.0
            tipLabel.numberOfLines = 0
            
            tipLabel.isHidden = true
            view.addSubview(tipLabel)
            tipLabel.center = view.center
            view.bringSubviewToFront(tipLabel)
            
            return tipLabel
        }
    }
}
