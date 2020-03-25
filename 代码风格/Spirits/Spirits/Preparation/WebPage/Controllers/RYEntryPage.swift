//
//  RYEntryPage.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/9/2.
//  Copyright © 2019 RuiYu. All rights reserved.
//

/*
   Abstracts: The entrance combine WebView part and Native part.
 */

import UIKit
import MDAd

/// Manages webView part and native news part.
class RYEntryPage: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollToTopButton: UIButton!
    
    // MARK: - Enums
    
    private enum RYEntryPageSectionType {
        case webpage, newsNotice, news
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let identifierForNewsTitleCell = String(describing: RYNewsTitleCell.self)
        static let identifierForRYWebViewCell = String(describing: RYWebViewCell.self)
        static let identifierForNewsNoPicCell = String(describing: RYNewsNoPicCell.self)
        static let identifierForNewsSinglePicCell = String(describing: RYNewsSinglePicCell.self)
        static let identifierForNewsThreePicsCell = String(describing: RYNewsThreePicsCell.self)
        static let identifierForNewsVideoCell = String(describing: RYNewsVideoCell.self)
//        static let identifierForNewsHeaderFooterView = String(describing: RYFlagsView.self)
        static let heightForHeaderInNewsSection: CGFloat = 44.0
        static let heightForTableViewFooterView: CGFloat = 64.0 * 2.0 / 3.0
        static let positionHeightWhenScrollToTopButtonDisplays: CGFloat = UIScreen.main.bounds.height * 3.0
    }
    
    // MARK: - Properties
    
    /// Key url string.
    var entryUrlString: String?
    
    /// A boolean value indicates there are two positions for show UIActivityIndicatorView: rightBarButtonItem and center of self.view.
    var isRefreshOnTop = false
    
    /// A boolean value Indicates whether loading webpage for the first time. return false if has already loaded webpage.
    private var isFirstRefresh = true
    
    /// A boolean value Indicates whether the current web page is home page and preventing invoke repeatly. YES displays the home page. Default is false.
    private var isHomeInWebView = false
    
    /// TableView sections. Default is [.webpage].
    private var sections: [RYEntryPageSectionType] = [.webpage]
    
    private var heightForWebViewCell: CGFloat = 768.0
    private var originHeightFromHomePage: CGFloat = UIScreen.main.bounds.height
    
    /// An instance of RYWebViewCell class.
    private weak var webViewCell: RYWebViewCell?
    
    /// A view model that manages all debug informations.
    private var debugCase: RYDebugCase?
    
    private var adsLoader: RYAdsLoader?
    
    // News related
    
    private let dataManager = RYNewsRequester()
    private var action = "refresh"
    private var theme: String = "推荐"
    
//    private var cellHeightMap: [IndexPath: CGFloat] = [:]
    
    // Lazy properties
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .gray)
        activityView.isHidden = true
        view.addSubview(activityView)
        
        activityView.center = CGPoint(x: view.center.x, y: view.center.y - RYFormatter.navigationBarPlusStatusBarHeight(for: self) / 2)
        return activityView
    }()
    
    private lazy var refreshBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(refreshBarButtonItemTapped))
        return barButtonItem
    }()
    
    lazy var activityBarButtonItem: UIBarButtonItem = {
        let activityView = UIActivityIndicatorView(style: .gray)
        let barButtonItem = UIBarButtonItem(customView: activityView)
        activityView.startAnimating()
        return barButtonItem
    }()
    
    // MARK: - Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYEntryPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYEntryPage()
    }
    
    private func setup_RYEntryPage() {}
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // always set light mode
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        activityIndicatorView.isHidden = isRefreshOnTop
        scrollToTopButton.isHidden = true
        
        // config tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 210
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.register(UINib(nibName: Constants.identifierForNewsTitleCell, bundle: nil), forCellReuseIdentifier: Constants.identifierForNewsTitleCell)
        tableView.register(UINib(nibName: Constants.identifierForRYWebViewCell, bundle: nil), forCellReuseIdentifier: Constants.identifierForRYWebViewCell)
        tableView.register(UINib(nibName: Constants.identifierForNewsNoPicCell, bundle: nil), forCellReuseIdentifier: Constants.identifierForNewsNoPicCell)
        tableView.register(UINib(nibName: Constants.identifierForNewsSinglePicCell, bundle: nil), forCellReuseIdentifier: Constants.identifierForNewsSinglePicCell)
        tableView.register(UINib(nibName: Constants.identifierForNewsThreePicsCell, bundle: nil), forCellReuseIdentifier: Constants.identifierForNewsThreePicsCell)
        tableView.register(UINib(nibName: Constants.identifierForNewsVideoCell, bundle: nil), forCellReuseIdentifier: Constants.identifierForNewsVideoCell)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        
        // request news
        requestNews()
        
        // setup viewmodels
        debugCase = RYDebugCase(self)
        adsLoader = RYAdsLoader(self)
        adsLoader?.delegate = self
        adsLoader?.requestTopTextBottomImageAd()
        adsLoader?.requestTripleImageAd()
        adsLoader?.requestBuoyAd()
        
        // register
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminateNotification), name: UIApplication.willTerminateNotification, object: nil)
        
        DispatchQueue.global(qos: .background).async {
            if !Calendar.current.isDateInToday(RYUserDefaultCenter.dateWhenApplicationTerminated()) {
                RYUserDefaultCenter.finishAwardTask(for: .novels, false)
                RYUserDefaultCenter.finishAwardTask(for: .news, false)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstRefresh {
           heightForWebViewCell = view.bounds.height
        }
    }
    
    private func requestNews() {
        // clean datamanager's data
        dataManager.cleanData()
        
        // request data
        dataManager.channel = theme
        dataManager.action = action
        dataManager.delegate = self
        dataManager.requestNews()
    }
    
    deinit {
        webViewCell?.dispose()
        tableView?.delegate = nil
    }
    
    // MARK: - Bar Button Item Tap Actions
    
    @objc private func refreshBarButtonItemTapped(_ sender: UIBarButtonItem) {
        webViewCell?.reload()
    }
    
    @objc private func applicationWillTerminateNotification() {
        RYUserDefaultCenter.updateDateWhenApplicationWillTerminate(Date())
    }
    
    @IBAction func scrollToTopButtonTapped(_ sender: UIButton) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource

extension RYEntryPage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section] {
        case .news:
            return Constants.heightForHeaderInNewsSection
            
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch sections[section] {
            
        case .webpage, .newsNotice:
            return 1
            
        case .news:
            return dataManager.newsList.count
        }
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let height = cellHeightMap[indexPath] { return height }
//        return 210.0
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
            
        case .webpage:
            return heightForWebViewCell
            
        case .newsNotice:
            return 51.0
            
        case .news:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch sections[indexPath.section] {
        
        case .webpage:
            
//            if indexPath.row > 1 {
//                let lastCellHeight = tableView.rectForRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section)).size.height
//                tableView.estimatedRowHeight = lastCellHeight
//            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: Constants.identifierForRYWebViewCell), for: indexPath)
            if let cell = cell as? RYWebViewCell {
                if let urlString = entryUrlString, !urlString.isEmpty, !cell.hasLoadedWebView {
                    cell.update(urlString)
                    webViewCell = cell
                    cell.delegate = self
                    cell.configRootViewController(self)
                }
            }
            return cell
            
        case .newsNotice:
            return tableView.dequeueReusableCell(withIdentifier: String(describing: Constants.identifierForNewsTitleCell), for: indexPath)
            
        case .news:
        
            if indexPath.row < dataManager.newsList.count {
                let newsItem = dataManager.newsList[indexPath.row]
                if let dtype = newsItem.dtype {
                    
                    switch dtype {
                    case .singlePicture, .mdadTopTextBottomImage:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifierForNewsSinglePicCell, for: indexPath)
                        if let cell = cell as? RYNewsSinglePicCell {
                            cell.update(newsItem)
                        }
                        
                        if dtype == .mdadTopTextBottomImage {
                            if let order = newsItem.order,
                                let adsLoader = self.adsLoader, order < adsLoader.topTextBottomImageCustomAds().count {
                                let customAd = adsLoader.topTextBottomImageCustomAds()[order]
                                customAd.recordImpression()
                            }
                        }
                        
                        return cell
                        
                    case .threePicture, .mdadTripleImages:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifierForNewsThreePicsCell, for: indexPath)
                        if let cell = cell as? RYNewsThreePicsCell {
                            cell.update(newsItem)
                        }
                        
                        if dtype == .mdadTripleImages {
                            if let order = newsItem.order,
                                let adsLoader = self.adsLoader, order < adsLoader.tripleImageCustomAds().count {
                                let customAd = adsLoader.tripleImageCustomAds()[order]
                                customAd.recordImpression()
                            }
                        }
                        
                        return cell
                            
                    case .bigPicture:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifierForNewsVideoCell, for: indexPath)
                        if let cell = cell as? RYNewsVideoCell {
                            cell.update(newsItem)
                        }
                        return cell
                    
                    case .noPicture:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifierForNewsNoPicCell, for: indexPath)
                        if let cell = cell as? RYNewsNoPicCell {
                            cell.update(newsItem)
                        }
                        return cell
                        
                    case .bytedanceTripleImages:
                        break
                    }
                }
            }
        }
        return tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cellHeightMap.updateValue(cell.bounds.size.height, forKey: indexPath)
//    }
    
    // TODO: - Need use UITableViewHeaderFooterView to improve.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch sections[section] {
        case .news:
            if let flagView = RYFlagsView.loadFromNib() {
                flagView.delegate = self
                flagView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.heightForHeaderInNewsSection)
                return flagView
            }
            return nil
            
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard sections[indexPath.section] == .news else { return }
        
        if indexPath.row < dataManager.newsList.count {
            
            let newsItem = dataManager.newsList[indexPath.row]
            switch newsItem.dtype {
                
            case .mdadTopTextBottomImage:
                
                if let order = newsItem.order,
                    let adsLoader = self.adsLoader, order < adsLoader.topTextBottomImageCustomAds().count {
                    let customAd = adsLoader.topTextBottomImageCustomAds()[order]
                    customAd.openAdLink()
                    customAd.recordClick()
                }
                
            case .mdadTripleImages:
                if let order = newsItem.order,
                    let adsLoader = self.adsLoader, order < adsLoader.tripleImageCustomAds().count {
                    let customAd = adsLoader.tripleImageCustomAds()[order]
                    customAd.openAdLink()
                    customAd.recordClick()
                }
            
            case .bytedanceTripleImages:
                break
                
            default:
                if let url = newsItem.detailsUrl {
                    RYWebPage.showWebPage(url, showDomainSourceAsTitle: true, fromType: .news, fromVC: self)
                }
            }
        }
    }
}

// MARK: - RYWebViewCellDelegate

extension RYEntryPage: RYWebViewCellDelegate {

    func webViewStartLoading() {
        
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
    
    func webViewEndedLoading() {
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
    
    func titleForCurrentWebPage(_ title: String?) {
        navigationItem.title = title
    }
    
    func webViewCurrentUrlString(_ urlString: String?) {
        guard let webViewCell = webViewCell else { return }
        
        var isHome = false
        
        if RYUserDefaultCenter.isDebugMode() {
            if let urlString = urlString, urlString == "http://120.79.177.179:6606/home" {
                isHome = true
            }
        } else {
            if let urlString = urlString, urlString == "https://wap.zhuanyuapp.com/home" {
                isHome = true
            }
        }
        
        if isHome { // home page
            
            adsLoader?.showBuoyAd(true)
            webViewCell.enabledWebViewScroll(false)
            if isHomeInWebView { return }
            
            // 1. update tableview sections before insert sections.
            sections = [.webpage, .newsNotice, .news]
            
            // 2. update height
            heightForWebViewCell = originHeightFromHomePage
            
            // 3. insert
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.insertSections(IndexSet(arrayLiteral: 1, 2), with: .none)
                self.tableView.endUpdates()
            }
            
            // 4. scroll setting related
            tableView.isScrollEnabled = true
            webViewCell.enabledWebViewScroll(false)
            tableView.showsVerticalScrollIndicator = true
            
            // 5. update flag
            isHomeInWebView = isHome
            
        } else { // other pages
            adsLoader?.showBuoyAd(false)
            
            if !isHomeInWebView { return }
            if !sections.contains(.news) { return }
            
            // 1. update tableview sections before delete sections.
            sections = [.webpage]
            
            // 2. update height
            heightForWebViewCell = tableView.bounds.height
            
            // 3. delete
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.deleteSections(IndexSet(arrayLiteral: 1, 2), with: .none)
                self.tableView.endUpdates()
            }
            
            // 4. scroll setting related
            tableView.isScrollEnabled = false
            webViewCell.enabledWebViewScroll(true)
            tableView.showsVerticalScrollIndicator = false
            
            showFooterView(false)
            
            // 5. update flag
            isHomeInWebView = isHome
        }
    }
    
    func homePageHeightDidUpdate(_ height: CGFloat) {
        guard originHeightFromHomePage != height else { return }
        
        heightForWebViewCell = height
        originHeightFromHomePage = height
        DispatchQueue.main.async {
//            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
}

// MARK: - RYFlagsViewDelegate

extension RYEntryPage: RYFlagsViewDelegate {
    
    func flagsViewDidSelectChannel(at channel: String) {
        // refresh news list with specify `channel`
        
        theme = channel
        action = "refresh"
//        DispatchQueue.main.async {
//            self.dataManager.newsList.removeAll()
//            if let index = self.sectionIndex(at: .news) {
//                UIView.performWithoutAnimation {
//                    self.tableView.beginUpdates()
//                    self.tableView.reloadSections(IndexSet(integer: index), with: .none)
//                    self.tableView.endUpdates()
//                }
//            }
//        }
        
        requestNews()
    }
}

// MARK: - RYNewsRequesterDelegate

extension RYEntryPage: RYNewsRequesterDelegate {
    
    func dataManagerSuccessful(_ success: Any?) {
        guard let newsIndex = sectionIndex(at: .news) else { return }
        
        if action == "page_down" {
            if let success = success as? [Int], success.count > 0 {
                var indexPaths: [IndexPath] = []
                for item in success {
                    indexPaths.append(IndexPath(row: item, section: newsIndex))
                }
                
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        if self.sections.contains(.news) {
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: indexPaths, with: .none)
                            self.tableView.endUpdates()
                        }
                    }
                }
            }
        } else { // "refresh"
            DispatchQueue.main.async {
                self.reloadNewsSection()
            }
        }
    }
    
    func dataManagerFailed(_ failure: Error?) {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                if let index = self.sectionIndex(at: .news) {
                    self.tableView.reloadSections(IndexSet(integer: index), with: .none)
                }
            }
        }
    }
    
    func dataManager(_ status: eRYDataManagerStatus) {
        // Return if tableview don't contains news section.
        guard let _ = sectionIndex(at: .news) else { return }
        
        DispatchQueue.main.async {
            
            switch status {
            case .loading:
                self.showFooterView(true)
                
            case .empty:
                if self.action == "refresh" { // empty list
                    self.showFooterViewTips(false, "暂时没有更新")
                } else { // next page is empty
                    self.showFooterViewTips(true, "已经到底了哦^^")
                }
            
            case .error:
                
                if self.action == "refresh" { // not paging yet
                    
                } else {
                    self.showFooterViewTips(true, "网络开小差啦")
                }
                
            case .none:
                self.showFooterView(false)
                if self.action == "refresh" {
                    
                } else {
                    self.tableView.setContentOffset(CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y + Constants.heightForTableViewFooterView), animated: false)
                }
            }
        }
    }
    
    func topTextBottomImageAdsData() -> [RYNewsItem] {
        return adsLoader?.topTextBottomImageAdArray() ?? []
    }
    
    func tripleImageAdsData() -> [RYNewsItem] {
        return adsLoader?.tripleImageAdArray() ?? []
    }
    
    func bytedanceTripleImageAdsData() -> [RYNewsItem] {
        return adsLoader?.bytedanceTripleImageAdArray() ?? []
    }
    
    private func showFooterViewTips(_ isPaging: Bool, _ tips: String) {
        if isPaging {
            self.showFooterView(true, detailsText: tips)
            self.tableView.setContentOffset(CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y + Constants.heightForTableViewFooterView), animated: false)
            UIView.animate(withDuration: 0.5, delay: 0.35, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.tableView.setContentOffset(CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y - Constants.heightForTableViewFooterView), animated: false)
            }, completion: { _ in
                self.showFooterView(false)
            })
        } else {
            self.showFooterView(true, detailsText: tips)
            self.tableView.setContentOffset(CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y + Constants.heightForTableViewFooterView), animated: false)
        }
    }
    
    // TODO: Need to be refactor as Protocol!
    private func showFooterView(_ isShow: Bool, detailsText text: String? = nil) {
        
        if isShow {
            if let text = text, !text.isEmpty {
                tableView.tableFooterView = nil
                let footerContentView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.heightForTableViewFooterView))
                let label = UILabel(frame: footerContentView.bounds)
                footerContentView.addSubview(label)
                label.text = text
                label.textAlignment = .center
                label.textColor = UIColor.gray
                label.font = UIFont(name: "PingFangSC-Regular", size: 15)
                tableView.tableFooterView = footerContentView
                
            } else {
                tableView.tableFooterView = nil
                let footerContentView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.heightForTableViewFooterView))
                let indicatorView = UIActivityIndicatorView(style: .gray)
                footerContentView.addSubview(indicatorView)
                indicatorView.center = footerContentView.center
                indicatorView.color = UIColor.black.withAlphaComponent(0.7)
                indicatorView.startAnimating()
                tableView.tableFooterView = footerContentView
            }
            
        } else {
            tableView.tableFooterView = nil
        }
    }
    
    private func sectionIndex(at type: RYEntryPageSectionType) -> Int? {
        guard sections.count > 0 else { return nil }
        return sections.firstIndex(of: type)
    }
    
    private func reloadNewsSection() {
        UIView.performWithoutAnimation {
            if let index = self.sectionIndex(at: .news) {
                self.tableView.reloadSections(IndexSet(integer: index), with: .none)
//                self.tableView.beginUpdates()
//                self.tableView.reloadSections(IndexSet(integer: index), with: .none)
//                self.tableView.endUpdates()
            }
        }
    }
}


// MARK: - ScrollView Delegate

extension RYEntryPage: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == tableView else { return }
        if scrollView.contentOffset.y > Constants.positionHeightWhenScrollToTopButtonDisplays {
            if scrollToTopButton.isHidden { scrollToTopButton.isHidden = false }
        } else {
            if !scrollToTopButton.isHidden { scrollToTopButton.isHidden = true }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == tableView else { return }
        // enable paging when displays news section
        guard sections.contains(.news) else { return }
        // enable paging when current news count is larger than 0
        guard dataManager.newsList.count > 0 else { return }
        
        scrollViewDidEndScroll(scrollView)
    }
    
    private func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        let distance = scrollView.contentSize.height - scrollView.bounds.height
        if distance > 0 && scrollView.contentOffset.y > distance + 25 {
            action = "page_down"
            requestNews()
        }
    }
}


extension RYEntryPage: RYAdsLoaderDelegate {
    
    func rewardVideoWillClose(_ isPlaySucceed: Bool) {
        webViewCell?.rewardVideoDidClose(isPlaySucceed)
    }
    
    // Not RYAdsLoaderDelegate method. Public method.
    func playRewardVideo() {
        adsLoader?.requestRewardVideoAds()
    }
}
