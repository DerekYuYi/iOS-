//
//  RYWebView.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/3.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import WebKit

let nRYNotificationForWechatLoginSuccessfully = "wechatLoginedSuccessfully"

protocol RYWebViewDelegate: NSObjectProtocol {
    // loading life cycle
    
    func webViewBeginLoading()
    func webViewEndLoading()
    
    // web page title.
    func titleForCurrentPageInWebView(_ title: String?)
    
    // Indicates whether is home page.
    func isHomePageInWebView(_ isHomePage: Bool)
    
    func canGoBackForCurrentPage(_ canGoBack: Bool)
    
    func urlForCurrentPage(_ urlString: String?)
    
    func homePageHeightDidUpdate(_ height: CGFloat)
}

extension RYWebViewDelegate {
    func webViewBeginLoading() {}
    func webViewEndLoading() {}
    func titleForCurrentPageInWebView(_ title: String?) {}
    func isHomePageInWebView(_ isHomePage: Bool) {}
    func canGoBackForCurrentPage(_ canGoBack: Bool) {}
    func urlForCurrentPage(_ urlString: String?) {}
    func homePageHeightDidUpdate(_ height: CGFloat) {}
}

/// A view contains a webview that manages all requests related webview and all interactive between JS and webview.
class RYWebView: UIView {
    
    // MARK: - Constants
    
    private struct Constants {
        // function names agreed by webview and JS
    
        static let checkAppStatus = "checkAppStatus"
        static let isIdfaAvailable = "isIdfaAvailable"
        static let thirdPartySharing = "thirdPartyShare"
        static let wechatLogin = "wechatLogin"
        static let rewardVideoPlay = "rewardVideoPlay"
        static let tokenAndWebHomeHeight = "sendTokenPageHeight"
        static let gotoNovelsModule = "gotoNovelsModule"
        static let gotoGamesModule = "gotoGamesModule"
        
        // KVO keys
        
        static let observedKeyPathForTitle = "title"
        static let observedKeyPathForCanGoback = "canGoBack"
        static let observedKeyPathForUrl = "URL"
        
        // digital contants
        
        static let minimumFontSizeOfWebView: CGFloat = 6
        
        static var isPresenting = false
    }
    
    weak var delegate: RYWebViewDelegate?
    
    /// Saving vc for adding colse button on navigation bar items, and operating action of close webpage.
    weak var hookingVC: UIViewController?
    
    /// A url string used for webview to load.
    var urlString: String? {
        didSet {
            if let urlString = urlString,
                let encodingUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !encodingUrlString.isEmpty {
                if let url = URL(string: urlString) {
                    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
                    webView.load(request)
                }
            }
        }
    }
    
    /// Key webView.
    private lazy var webView: WKWebView = {
        
        // 1. set webview preferences
        let preferences = WKPreferences()
        preferences.minimumFontSize = Constants.minimumFontSizeOfWebView
        
        // 2. set configuration
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
        
        // uses RYWKLeakAvoider to prevent retain cycle
        let leakAvoider = RYWKLeakAvoider(self)
        configuration.userContentController.add(leakAvoider, name: Constants.checkAppStatus)
        configuration.userContentController.add(leakAvoider, name: Constants.isIdfaAvailable)
        configuration.userContentController.add(leakAvoider, name: Constants.thirdPartySharing)
        configuration.userContentController.add(leakAvoider, name: Constants.wechatLogin)
        configuration.userContentController.add(leakAvoider, name: Constants.rewardVideoPlay)
        configuration.userContentController.add(leakAvoider, name: Constants.tokenAndWebHomeHeight)
        configuration.userContentController.add(leakAvoider, name: Constants.gotoNovelsModule)
        configuration.userContentController.add(leakAvoider, name: Constants.gotoGamesModule)
        
        // 3. setup webView
        let itemWebView = WKWebView(frame: bounds, configuration: configuration)
        
        itemWebView.customUserAgent = RYUserDefaultCenter.webViewCustomUserAgent()
        
        itemWebView.allowsLinkPreview = false
        itemWebView.navigationDelegate = self
        itemWebView.addObserver(self, forKeyPath: Constants.observedKeyPathForTitle, options: .new, context: nil)
        itemWebView.addObserver(self, forKeyPath: Constants.observedKeyPathForCanGoback, options: .new, context: nil)
        itemWebView.addObserver(self, forKeyPath: Constants.observedKeyPathForUrl, options: .new, context: nil)
    
        return itemWebView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        // add webview and load
        addSubview(webView)
        
        // layout
        webView.translatesAutoresizingMaskIntoConstraints = false

        let leadingConstraint = NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        // receive notification when wechat logined
        NotificationCenter.default.addObserver(self, selector: #selector(wechatLogined), name: NSNotification.Name(nRYNotificationForWechatLoginSuccessfully), object: nil)
    }
    
    /// Returns a navigationController that show bar button items.
    private func targetNavigationController() -> UINavigationController? {
        return hookingVC?.navigationController
    }
    
    /// Invoked when wechat logined successfully.
    /// - Parameter notification: NSNotification instance that post from wechat successfully logined block.
    @objc private func wechatLogined(_ notification: NSNotification) {
        
        guard let data = notification.userInfo, data.count > 0 else { return }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
        if let jsonData = jsonData {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                webView.evaluateJavaScript("wechatDidLogined(\(jsonString))") { (result, error) in
                    debugPrint(result ?? "no result")
                    debugPrint(error ?? "no error")
                }
            }
        }
    }
}


// MARK: - WKNavigationDelegate

extension RYWebView: WKNavigationDelegate {
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
                            self.targetNavigationController()?.popViewController(animated: false)
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
        delegate?.webViewBeginLoading()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delegate?.webViewEndLoading()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webViewEndLoading()
        
        let infos: [String: Any] = ["idfa": RYEncryptHelper.encryptRSA(for: RYDeviceInfoCollector.shared.identifierForAdvertising),
                                    "idfv": RYEncryptHelper.encryptRSA(for: RYDeviceInfoCollector.shared.identifierForVerdor),
                                    "originalIDFA": RYDeviceInfoCollector.shared.identifierForAdvertising,
                                    "originalUDID": RYDeviceInfoCollector.shared.identifierForVerdor,
                                    "mobileModel": UIDevice.productType,
                                    "sysVer": RYDeviceInfoCollector.shared.systemVersion,
                                    "bundleId": RYDeviceInfoCollector.shared.bundleIdentifier,
                                    "version": RYDeviceInfoCollector.shared.appVersion,
                                    "isApp": true,
                                    "jailBreak": RYDeviceInfoCollector.adapter(),
                                    "isWXInstalled": RYThirdPartiesShareManager.isWechatInstalled(),
                                    "isQQInstalled": RYThirdPartiesShareManager.isQQInstalled(),
                                    "isWeiboInstalled": RYThirdPartiesShareManager.isWeiboInstalled()]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: infos, options: JSONSerialization.WritingOptions.prettyPrinted)
        if let jsonData = jsonData {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                webView.evaluateJavaScript("getInitialInfo(\(jsonString))") { (result, error) in
                    debugPrint(result ?? "no result")
                    debugPrint(error ?? "no error")
                }
            }
        }
        
        // note: - Prevents popping alertViewController when long press interactive content of webview.
        
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
        
        // note: - Uncomment for copying contents with JS.
        //        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';", completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.webViewEndLoading()
    }
}


// MARK: - WKScriptMessageHandler

extension RYWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case Constants.checkAppStatus:
            if let bodyString = message.body as? String,
                let url = URL(string: bodyString) {
                UIApplication.shared.open(url, options: [:]) { result in
                    // NOTE: `result` is Bool indicating whether the URL was opened successfully, is not optional, but sometimes its value is nil. It's the opposite of Developer Documentation's reference. So we build a optional parameter to receive its value to preventing exceptions.
                    let logicResult: Bool? = result
                    if let logic = logicResult, logic {
                        self.webView.evaluateJavaScript("saveAppStatus(\(true))", completionHandler: { (result, error) in
                            debugPrint(result ?? "no result")
                            debugPrint(error ?? "no error")
                        })
                    } else {
                        self.webView.evaluateJavaScript("saveAppStatus(\(false))", completionHandler: { (result, error) in
                            debugPrint(result ?? "no result")
                            debugPrint(error ?? "no error")
                        })
                    }
                }
            }
            
        case Constants.isIdfaAvailable:
            if let bodyString = message.body as? String {
                debugPrint(bodyString)
            }
            
            DispatchQueue.main.async {
                var idfaString = RYDeviceInfoCollector.shared.identifierForAdvertising
                if idfaString.isEmpty || (idfaString.hasPrefix("0000") && (idfaString.hasSuffix("0000"))) {
                    idfaString = ""
                }
                
                self.webView.evaluateJavaScript("updateIdfaStatus(`\(idfaString)`)", completionHandler: { (result, error) in
                    debugPrint(result ?? "no result")
                    debugPrint(error ?? "no error")
                })
            }
            
        case Constants.thirdPartySharing:
            // access share data
            if let body = message.body as? [String: Any], body.count > 0 {
                
                if let shareScene = body["shareScene"] as? Int, let shareData = body["shareData"] as? [String: Any], shareScene >= 0, shareData.count > 0 {
                    if let platform = eRYSharePlatform(rawValue: shareScene) {
                        RYThirdPartiesShareManager.share(for: platform,
                                                         objectType: .webpage,
                                                         objectData: shareData)
                    }
                }
            }
            
        case Constants.wechatLogin:
            // start wechat login
            RYThirdPartiesShareManager.wechatLogin()
        
        case Constants.rewardVideoPlay:
            // play reward video
            if let hookingVC = self.hookingVC as? RYEntryPage {
                hookingVC.playRewardVideo()
            }
        
        case Constants.tokenAndWebHomeHeight:
            if let body = message.body as? [String: Any] {
                if let height = body["pageHeight"] as? CGFloat {
                    delegate?.homePageHeightDidUpdate(height)
                }
                
                if let userToken = body["userToken"] as? String, !userToken.isEmpty {
                    RYUserDefaultCenter.updateWebViewUserToken(userToken)
                }
            }
            
        case Constants.gotoNovelsModule:
            if let bodyString = message.body as? String {
                if let hookingVc = hookingVC {
                    RYWebPage.showWebPage(bodyString,
                                          showDomainSourceAsTitle: true,
                                          fromType: .novels,
                                          fromVC: hookingVc)
                }
            }
            
        case Constants.gotoGamesModule:
            if let bodyString = message.body as? String {
                if let url = URL(string: bodyString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        
        default:
            break
        }
    }
    
    /// Invoked when reward video view controller did close.
    /// - Parameter isPlayedSucceed: A boolean indicates that whether the reward video is played successfully.
    func rewardVideoDidClose(_ isPlayedSucceed: Bool) {
        webView.evaluateJavaScript("rewardVideoDidClose(\(isPlayedSucceed))", completionHandler: { (result, error) in
            debugPrint(result ?? "no result")
            debugPrint(error ?? "no error")
        })
    }
}


// MARK: - Observers

extension RYWebView {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, !keyPath.isEmpty else { return }
        guard let object = object as? WKWebView, object == webView else { return }
        
        if keyPath == Constants.observedKeyPathForTitle {
            delegate?.titleForCurrentPageInWebView(object.title)
        }
        
        if keyPath == Constants.observedKeyPathForCanGoback {
            delegate?.canGoBackForCurrentPage(object.canGoBack)
        }
        
        if keyPath == Constants.observedKeyPathForUrl {
            delegate?.urlForCurrentPage(object.url?.absoluteString)
        }
    }
}


// MARK: - Public Interfaces

extension RYWebView {

    /// Releases all observers, message handlers and webview's delegates.
    func dispose() {
        webView.stopLoading()
        webView.navigationDelegate = nil
        delegate = nil
        webView.removeObserver(self, forKeyPath: Constants.observedKeyPathForTitle)
        webView.removeObserver(self, forKeyPath: Constants.observedKeyPathForCanGoback)
        webView.removeObserver(self, forKeyPath: Constants.observedKeyPathForUrl)
        webView.removeObserver(self, forKeyPath: nRYNotificationForWechatLoginSuccessfully)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.checkAppStatus)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.isIdfaAvailable)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.thirdPartySharing)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.wechatLogin)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.rewardVideoPlay)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.tokenAndWebHomeHeight)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.gotoNovelsModule)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.gotoGamesModule)
    }
    
    /// Reloads the current page.
    func reload() {
        webView.reload()
    }
    
    /// Navigates to the back item in the back-forward list.
    func goBack() {
        guard webView.canGoBack else { return }
        webView.goBack()
    }
    
    func canGoBack() -> Bool {
        return webView.canGoBack
    }
    
    func enabledWebViewScroll(_ isEnabled: Bool) {
        webView.scrollView.isScrollEnabled = isEnabled
        webView.scrollView.showsVerticalScrollIndicator = isEnabled
    }
    
    /// Configs custom user agent.
    /// - note: Generally, developer calls the function when app launched, such as `didFinishLaunchingWithOptions`.
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


/*
// MARK: - WKUIDelegate

extension RYWebView: WKUIDelegate {
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
    // alert panel
}
*/
