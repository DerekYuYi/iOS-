//
//  ViewController.swift
//  WKWebviewJSDemo
//
//  Created by DerekYuYi on 2018/12/4.
//  Copyright © 2018 Wenlemon. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

class ViewController: UIViewController {
    
    // MARK: - Properties
    lazy var webView: WKWebView = {
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.minimumFontSize = 18
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
        
        // 给 webView 与 Swift 交互注册一个脚本消息处理器名字: ”AppModel“
        // 添加 JS 事件: 这里 JS 调用 messageHandler 的 AppModel 消息, 给原生发送消息
        let leakAvoider = LeakAvoider(self)
        configuration.userContentController.add(leakAvoider, name: "AppModel")
        configuration.userContentController.add(leakAvoider, name: "showMobile")
        configuration.userContentController.add(leakAvoider, name: "showName")
        configuration.userContentController.add(leakAvoider, name: "showSendMsg")
        
        let frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 300)
        var tempWebView = WKWebView(frame: frame, configuration: configuration)
        tempWebView.scrollView.bounces = true
        tempWebView.scrollView.alwaysBounceVertical = true
        tempWebView.allowsBackForwardNavigationGestures = true
        tempWebView.navigationDelegate = self
        tempWebView.uiDelegate = self
        
//        tempWebView.goBack() // 前进
//        tempWebView.goForward() // 后退
        
        // observer loading, progress, and title
        tempWebView.addObserver(self, forKeyPath: "isLoading", options: NSKeyValueObservingOptions.new, context: nil)
        tempWebView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        tempWebView.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.new, context: nil)
        
        return tempWebView
    }()
    
    lazy var testButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: webView.frame.maxY + 10, width: 120, height: 60)
        button.setTitle("调用 JS", for: .normal)
        button.backgroundColor = .orange
        button.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let contextDemo = JSContextDemo()
        contextDemo.test()
        
        title = "WebView与JS交互"
        view.backgroundColor = .white
        view.addSubview(webView)
        view.addSubview(testButton)
        
        if let path = Bundle.main.path(forResource: "test", ofType: "html") {
            let html = try? String(contentsOfFile: path, encoding: .utf8)
            if let html = html {
                webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
            }
        }
    }
    
    deinit {
        
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "AppModel")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "showMobile")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "showName")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "showSendMsg")
        
        webView.removeObserver(self, forKeyPath: "isLoading")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    /// Native invokes js when button tapped
    @objc func testButtonTapped(_ sender: UIButton) {
        guard !webView.isLoading else {
            return
        }
        
        // `alertMobile` is js function name
        
//        webView.evaluateJavaScript("alertMobile()") { (result, error) in
//            debugPrint(result ?? "no result when call function alertMobile")
//            debugPrint(error ?? "no error when call function alertMobile")
//        }

        /*
        webView.evaluateJavaScript("alertSendMsg('18870707070','周末爬山真是件愉快的事情')") { (result, error) in
            debugPrint(result ?? "no result when call function alertSendMsg")
            debugPrint(error ?? "no error when call function alertSendMsg")
        }
        */
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keypath = keyPath else { return }
        if keypath == "isLoading"  { // "Loading"
            
        }
        
        if keypath == "estimatedProgress" {
            debugPrint(webView.estimatedProgress)
        }
        
        if keypath == "title" {
            debugPrint(webView.title ?? "no title")
        }
    }
}

// 跟踪网页加载的进度并作出决策
extension ViewController: WKNavigationDelegate {
    //  在发送请求之前, 决定是否跳转, 可以截获发送的请求
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
        
        if let url = navigationAction.request.url?.absoluteString,
            let _ = url.range(of: "wenlemon.com://") {
            let selector = #selector(openCamera)
            perform(selector)
        }
        
        
        return
    }
    
    @objc func openCamera() {
    }
    
    // 在收到 response 后决定是否允许导航
    // 从本地加载 JS 不会调用
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        return
    }
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    // 这里在 webView 加载完成后, 向 webView 发送消息, 当然我们也可以在其他时机(比如点击按钮)来向 webView 发送消息
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.evaluateJavaScript("sayHello('原生给 JS 传值: WebView 你好!')") { (result, error) in
//            debugPrint(result ?? "no result")
//            debugPrint(error ?? "no error")
//        }
        
//        alertSendMsg
//        webView.evaluateJavaScript("alertSendMsg('电话号码', '消息')") { (result, error) in
//            debugPrint(result ?? "no result")
//            debugPrint(error ?? "no error")
//        }
        
        // 传递值是一个字符串, 字符串里是一个 object
        
        let dict = ["key1": "余意1",
                    "key2": "余意2",
                    "key3": "余意3",
                    "key4": "余意4"]
        
//        webView.evaluateJavaScript("alertInfos('\(dict)')") { (result, error) in
//            debugPrint(result ?? "no result")
//            debugPrint(error ?? "no error")
//        }
        
        // method 1
        // can't access jsContext in wkwebview
//        if let jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext")
//        {
//            if let jsValue = jsContext.evaluateScript("alertInfos") {
//                jsValue.call(withArguments: [dict])
//            }
//
        
        // method 2: 传递 字典给 JS 时, 先转化为 JsonString. 传递数组也是一样. 到 JS 端拿到的类型就行 Object 或者 Array.
        
            let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        if let jsonData = jsonData {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                let js = String(format: "alertInfos(%@)", jsonString)
                let js = "alertInfos(\(jsonString))"
                webView.evaluateJavaScript(js) { (result, error) in
                    debugPrint(result ?? "no result")
                    debugPrint(error ?? "no error")
                }
            }
        }
        
        
        // method 3
//        let string = "{'key1': '余意1', 'key2': '余意2'}"
//        let js = String(format: "alertInfos(%@)", string)
//
//        webView.evaluateJavaScript(js) { (result, error) in
//            debugPrint(result ?? "no result")
//            debugPrint(error ?? "no error")
//        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
}

extension ViewController: WKScriptMessageHandler {
    // js 调用原生, 在该协议中接受消息体
    // WKScrioptMessage: 每个该对象包含着从 WebView 发来的消息详情
    // 我们会在一开始注册 scriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint(message.name) // messageHandler name
        debugPrint(message.body)

        if message.name == "AppModel" {
        
        } else if message.name == "showMobile" {
            debugPrint("JS 中 按钮1 被点击了")
            openUrl("https://www.baidu.com")

        } else if message.name == "showName" {
            debugPrint("JS 中 按钮2 被点击了")
            openUrl("https://www.google.com")
            
        } else if message.name == "showSendMsg" {
            debugPrint("JS 中 按钮3 被点击了")
            openUrl("https://itunes.apple.com/us/app/miao-zhao-zhu-shou/id1457655044?l=zh&ls=1&mt=8")
        }
    }
    
    private func openUrl(_ urlString: String?) {
        guard let urlString = urlString,
            let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// 在 WKWebview 中, js 的 alert 是不会出现任何内容的, 我们必须重写 WKUIDelegate 委托的 runJavaScriptAlertPanelWithMessage 方法, 自己处理 alert. 类似的 Confirm, prompt 也是同理
extension ViewController: WKUIDelegate {
    // alert panel
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
        let alertVC = UIAlertController(title: "iOS-alert", message: "\(message)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    // confirm panel
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
    }
    
    // text input panel
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
    }
}




