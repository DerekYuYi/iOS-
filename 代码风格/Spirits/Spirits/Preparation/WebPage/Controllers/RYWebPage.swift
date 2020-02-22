//
//  RYWebPage.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/4.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import WebKit

/// A ViewController to displays web contents.
class RYWebPage: UIViewController {
    
    enum eRYWebPageSourceType: Int {
        case news = 1, novels, games
        
        /// Coverts int to string.
        func stringValue() -> String {
            return "\(self.rawValue)"
        }
    }
    
    private struct Constants {
        static let observerKeyPathForLoading = "loading"
        static let observerKeyPathForCanGoback = "canGoBack"
        static let observerKeyPathForProgress = "estimatedProgress"
        static let observerKeyPathForUrl = "URL"
        static let maximumSleepCount: Int = 8
    }
    
    /// Key webView.
    private var webView: WKWebView?
    
    /// Back bar button item.
    private lazy var backButton: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "back_gray"), style: .plain, target: self, action: #selector(backButtonTapped))
        return item
    }()
    
    /// Reload bar button item.
    private lazy var refreshBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(refreshBarButtonItemTapped))
        return barButtonItem
    }()
    
    /// Close bar button item.
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "close_newsDetails"), style: .plain, target: self, action: #selector(closeBarButtonItemTapped))
        return barButtonItem
    }()
    
    private lazy var cornerTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 220, height: 26))
        label.backgroundColor = RYColors.color(from: 0xE7E7E7).withAlphaComponent(0.39)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = RYColors.color(from: 0xA4A3A3)
        label.font = UIFont(name: "PingFangSC-Regular", size: 11)
        label.roundedCorner(nil, 13)
        return label
    }()
    
    private lazy var progress: UIProgressView = {
        let progressView = UIProgressView()
        progressView.backgroundColor = nil
        progressView.progressTintColor = RYColors.color(from: 0xF35C51)
        progressView.trackTintColor = .white
        return progressView
    }()
    
    var unencodedUrl: String = ""
    
    private var type: eRYWebPageSourceType = .news
    
    /// A boolean value indicates show navigation title with url domain string. Returns true when you want to display title with url domain.
    /// Default is false.
    private var isShowDomainSourceAsTitle = false
    
    /// A boolean value indicates that whether the count down operation can perform.
    private var canPerformCountDownOperation = true {
        didSet {
            if canPerformCountDownOperation {
                if let countDownView = self.countDownView, countDownView.isHidden == true { return }
                countDownView?.resumeAnimation()
            } else {
                if let countDownView = self.countDownView, countDownView.isHidden == true { return }
                countDownView?.pauseAnimation()
                invalidateTimer()
            }
        }
    }
    
    private var countDownView: RYCountDownView?
    
    private var listenTimer: Timer?
    
    private var sleepSeconds: Int = 0 {
        didSet {
            if sleepSeconds == Constants.maximumSleepCount {
                canPerformCountDownOperation = false
                invalidateTimer()
            }
        }
    }
    
    
    // Public Interfaces
    
    /// Display web content with specify url.
    /// - Parameters:
    ///   - urlString: the url will be open.
    ///   - title: navigation title. Default is nil.
    ///   - isShowDomainSourceAsTitle: Indicates the whether show domain source as natigation title.Default is nil.
    ///   - type: Source type.
    ///   - viewController: root view controller. Can not be nil.
    static func showWebPage(_ urlString: String,
                            webTitle title: String? = nil,
                            showDomainSourceAsTitle isShowDomainSourceAsTitle: Bool? = nil,
                            fromType type: eRYWebPageSourceType = .news,
                            fromVC viewController: UIViewController) {
        
        if urlString.hasPrefix("https://itunes.apple.com") || urlString.contains("//itunes.apple.com/") {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                }
            }
        } else {
            let webPage = RYWebPage()
            webPage.unencodedUrl = urlString
            webPage.type = type
            if let showDomainSourceAsTitle = isShowDomainSourceAsTitle {
                webPage.isShowDomainSourceAsTitle = showDomainSourceAsTitle
            }
            if let vc = viewController as? UINavigationController {
                vc.pushViewController(webPage, animated: true)
                return
            } else if let vc = viewController.navigationController {
                vc.pushViewController(webPage, animated: true)
            }
        }
        // more effects: present ...
    }
    
    
    // MARK: - Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYWebPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYWebPage()
    }
    
    private func setup_RYWebPage() {
        navigationItem.titleView = cornerTitleLabel
    }
    
    // MARK: - Deinit
    
    deinit {
        webView?.stopLoading()
        
        webView?.removeObserver(self, forKeyPath: Constants.observerKeyPathForCanGoback, context: nil)
        webView?.removeObserver(self, forKeyPath: Constants.observerKeyPathForProgress, context: nil)
        webView?.removeObserver(self, forKeyPath: Constants.observerKeyPathForUrl, context: nil)
        
        webView?.navigationDelegate = nil
        webView?.scrollView.delegate = nil
        
        countDownView?.resetCountInfos()
        countDownView?.delegate = nil
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 1. light mode
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        // 2. left bar button item
        navigationItem.leftBarButtonItems = [backButton]
        
        // 3. setup webView
        setupWebView()
        layoutWebview()
        
        setupProgressView()
        
        // 4. configuration
        if #available(iOS 11.0, *) {
            webView?.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isShowDomainSourceAsTitle else { return }
        DispatchQueue.global(qos: .background).async {
            if let domain = self.unencodedUrl.between("//", "/") {
                DispatchQueue.main.async {
                    self.cornerTitleLabel.text = "来自 " + domain
                }
            }
        }
    }
    
    func layoutWebview() {
        guard let webView = webView else { return }
        webView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        view.addConstraints([topConstraint, leadingConstraint, bottomConstraint, trailingConstraint])
    }
    
    private func setupWebView() {
        
        let configuration = WKWebViewConfiguration()
        
        let webViewFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        webView = WKWebView(frame: webViewFrame, configuration: configuration)
        if let webView = webView,
            let urlString = unencodedUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !urlString.isEmpty {
            
            view.insertSubview(webView, at: 0)
            
            webView.allowsLinkPreview = false
            webView.navigationDelegate = self
            webView.scrollView.delegate = self
            
            webView.addObserver(self, forKeyPath: Constants.observerKeyPathForCanGoback, options: .new, context: nil)
            webView.addObserver(self, forKeyPath: Constants.observerKeyPathForProgress, options: .new, context: nil)
            webView.addObserver(self, forKeyPath: Constants.observerKeyPathForUrl, options: .new, context: nil)
            
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
                webView.load(request)
            }
        }
    }
    
    private func setupProgressView() {
        guard let webView = webView else { return }
        webView.addSubview(progress)
        
        progress.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: progress, attribute: .width, relatedBy: .equal, toItem: webView, attribute: .width, multiplier: 1.0, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: progress, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2)
        let topConstraint = NSLayoutConstraint(item: progress, attribute: .top, relatedBy: .equal, toItem: webView, attribute: .top, multiplier: 1.0, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: progress, attribute: .leading, relatedBy: .equal, toItem: webView, attribute: .leading, multiplier: 1.0, constant: 0)
        
        webView.addConstraints([widthConstraint, heightConstraint, topConstraint, leadingConstraint])
    }
    
    // MARK: - Observers
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, !keyPath.isEmpty else { return }
        guard let object = object as? WKWebView, object == webView else { return }
        
        if keyPath == Constants.observerKeyPathForUrl {
        }
        
        if keyPath == Constants.observerKeyPathForCanGoback {
            navigationItem.leftBarButtonItems = object.canGoBack ? [backButton, closeBarButtonItem] : [backButton]
        }
        
        if keyPath == Constants.observerKeyPathForProgress {
            let progressValue = Float(object.estimatedProgress)
            
            DispatchQueue.main.async {
                if progressValue == 1.0 {
                    self.progress.isHidden = true
                    self.progress.setProgress(0, animated: false)
                } else {
                    self.progress.isHidden = false
                    self.progress.setProgress(progressValue, animated: true)
                }
            }
        }
    }
    
    // MARK: - BarButtonItem Actions
    
    @objc private func backButtonTapped(_ item: UIBarButtonItem) {
        guard let webView = webView else { return }
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func refreshBarButtonItemTapped(_ sender: UIBarButtonItem) {
        webView?.reload()
    }
    
    @objc private func closeBarButtonItemTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Loading
    
    func startLoading() {
        progress.isHidden = false
    }
    
    func endLoading() {
        navigationItem.rightBarButtonItems = [refreshBarButtonItem]
    }
}

// MARK: - WKNavigationDelegate

extension RYWebPage: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let _ = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
        return
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        return
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        startLoading()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        endLoading()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {}
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // end loading
        endLoading()
        
        // Do nothing when has finished award tasks.
        if RYUserDefaultCenter.awardTaskIsFinished(type) { return }
        
        // Do nothing when countDown operation is performing.
        if let _ = countDownView { return }
        
        // initial count down view and start count down.
        showCountDownView()
        startCountDown()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        endLoading()
    }
}

// MARK: - UIScrollViewDelegate

extension RYWebPage: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        canPerformCountDownOperation = true
        invalidateTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScroll()
        }
    }
    
    fileprivate func scrollViewDidEndScroll() {
        setupTimer()
    }
    
    fileprivate func setupTimer() {
        if let _ = listenTimer { return }
        let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(timeCount), userInfo: nil, repeats: true)
        self.listenTimer = timer
        RunLoop.current.add(timer, forMode: .common)
    }
    
    fileprivate func invalidateTimer() {
        guard let timer = listenTimer else { return }
        timer.invalidate()
        self.listenTimer = nil
        sleepSeconds = 0
    }
    
    @objc private func timeCount() {
        sleepSeconds += 1
    }
    
}

// MARK: - RYCountDownViewDelegate

extension RYWebPage: RYCountDownViewDelegate {
    
    func countDownDidEnd() {
        /// upload and wait result to determine whether to show award view
        
        UIView.animate(withDuration: 0.5, animations: {
            self.countDownView?.alpha = 0.0
        }) { _ in
            self.countDownView?.isHidden = true
            self.countDownView?.resetCountInfos()
        }
        
        DispatchQueue.global(qos: .background).async {
            self.uploadAwardInfo(self.type)
        }
    }
}

// MARK: - Award related logics

extension RYWebPage {
    
    /// Upload award info.
    /// - Parameter type: Indicates award type. "1" indicates news, "2" indicates novels.
    fileprivate func uploadAwardInfo(_ type: eRYWebPageSourceType) {
        guard type.rawValue >= 0 else { return }
        
        let domain: String
        if RYUserDefaultCenter.isDebugMode() {
            domain = "http://47.106.217.160:9003/"
        } else {
            domain = "https://wapapi.zhuanyuapp.com:8081/"
        }
        let awardApi = domain + "api/h5/gold_task/reward/?types=\(type.rawValue)"
        
        RYLaunchHelper.request(awardApi,
                               method: .get,
                               headers: ["Authorization": RYUserDefaultCenter.webViewUserToken()],
                               successHandler: { dict in
                                if let data = dict["data"] as? [String: Any],
                                    let goldNum = data["gold_num"] as? Int {
                                    if goldNum == -2 {
                                        RYUserDefaultCenter.finishAwardTask(for: type, true)
                                        return
                                    } else if goldNum > 0 {
                                        DispatchQueue.main.async {
                                            self.showAwardView(goldNum)
                                        }
                                    }
                                }
        }) { error in
            debugPrint(error ?? "no error")
        }
    }
    
    fileprivate func showCountDownView() {
        let countDownViewHeight: CGFloat = 52.0
        let countDownView = RYCountDownView(frame: CGRect(x: view.bounds.width - countDownViewHeight, y: view.bounds.height - 130.0, width: countDownViewHeight, height: countDownViewHeight))
        countDownView.delegate = self
        countDownView.backgroundColor = .white
        view.addSubview(countDownView)
        self.countDownView = countDownView
        self.countDownView?.isHidden = false
        countDownView.addShadow(RYColors.color(from: 0x000000), cornerRadius: countDownViewHeight/2.0)
    }
    
    fileprivate func showAwardView(_ awardCount: Int) {
        if let awardToastView = RYAwardToastView.loadFromNib() {
            awardToastView.frame = CGRect(x: 0, y: 0, width: 174, height: 64)
            awardToastView.isHidden = true
            awardToastView.alpha = 0.2
            view.addSubview(awardToastView)
            awardToastView.center = view.center
            awardToastView.updateCount(awardCount)
            
            UIView.animate(withDuration: 0.5, animations: {
                awardToastView.isHidden = false
                awardToastView.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: 1.2, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    awardToastView.alpha = 0.0
                }, completion: { _ in
                    awardToastView.isHidden = true
                    awardToastView.removeFromSuperview()
                    
                    // show count down again
                    self.startCountDown()
                })
            }
        }
    }
    
    fileprivate func startCountDown() {
        
        countDownView?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.countDownView?.alpha = 1.0
        }) { _ in
            
            // start listen timer
            self.invalidateTimer()
            DispatchQueue.main.async {
                self.setupTimer()
            }
            
            // start coutnt down 
            self.countDownView?.startCountDown()
        }
    }
}


// TODO: - Need to be refactor to extension or protocol!

extension String {
    // Returns sub string between a range and another range.
    func between(_ left: String, _ right: String) -> String? {
        guard
            let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
            , leftRange.upperBound <= rightRange.lowerBound
            else { return nil }
        
        let sub = self[leftRange.upperBound...]
        if let closestToLeftRange = sub.range(of: right) {
            return String(sub[..<closestToLeftRange.lowerBound])
        }
        return ""
    }
}

