//
//  RYWebViewCell.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/2.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

protocol RYWebViewCellDelegate: NSObjectProtocol {
    func webViewStartLoading()
    func webViewEndedLoading()
    func titleForCurrentWebPage(_ title: String?)
    func webViewCanGoBack(_ canGoBack: Bool)
    func webViewCurrentUrlString(_ urlString: String?)
    func homePageHeightDidUpdate(_ height: CGFloat)
}

extension RYWebViewCellDelegate {
    func webViewStartLoading() {}
    func webViewEndedLoading() {}
    func titleForCurrentWebPage(_ title: String?) {}
    func webViewCanGoBack(_ canGoBack: Bool) {}
    func webViewCurrentUrlString(_ urlString: String?) {}
    func homePageHeightDidUpdate(_ height: CGFloat) {}
}

class RYWebViewCell: UITableViewCell {
    
    var hasLoadedWebView = false
    weak var delegate: RYWebViewCellDelegate?
    
    let webView = RYWebView(frame: .zero)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addSubview(webView)
        webView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = contentView.bounds
    }
    
    func update(_ urlString: String) {
        webView.urlString = urlString
        hasLoadedWebView = true
    }
    
    func configRootViewController(_ viewController: UIViewController) {
        webView.hookingVC = viewController
    }
    
    func reload() {
        webView.reload()
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func canGoBack() -> Bool {
        return webView.canGoBack()
    }
    
    func enabledWebViewScroll(_ isEnabled: Bool) {
        webView.enabledWebViewScroll(isEnabled)
    }
    
    func rewardVideoDidClose(_ isPlaySucceed: Bool) {
        webView.rewardVideoDidClose(isPlaySucceed)
    }
    
    func dispose() {
        delegate = nil
        webView.dispose()
    }
}

// MARK: - RYWebViewDelegate

extension RYWebViewCell: RYWebViewDelegate {
    
    func webViewBeginLoading() {
        delegate?.webViewStartLoading()
    }
    
    func webViewEndLoading() {
        delegate?.webViewEndedLoading()
    }
    
    func titleForCurrentPageInWebView(_ title: String?) {
        delegate?.titleForCurrentWebPage(title)
    }
    
    func canGoBackForCurrentPage(_ canGoBack: Bool) {
        delegate?.webViewCanGoBack(canGoBack)
    }
    
    func urlForCurrentPage(_ urlString: String?) {
        delegate?.webViewCurrentUrlString(urlString)
    }
    
    func homePageHeightDidUpdate(_ height: CGFloat) {
        delegate?.homePageHeightDidUpdate(height)
    }
}
