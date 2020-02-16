//
//  RYDishPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/19.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

@objc protocol RYDishPageDelegate: NSObjectProtocol {
    @objc optional func tapTableView()
//    func dishPage(_ dishPage: RYDishPage?, didSelectDishAt dishID: Int)
}

enum ERYTableViewStatus {
    case loading
    case success([RYDishModel])
    case fail(Error?)
    case none
    
    func update(for tableView: UITableView, data: Any? = nil) {
        switch self {
        case .loading:
            tableView.reloadData()
            
        case .fail:
            tableView.reloadData()
            
        case .success:
            tableView.reloadData()
            
        case .none:
            tableView.isHidden = true
        }
    }
}

class RYDishPage: RYBaseViewController {
    private struct Constants {
        static let kRYScrollToRefreshLength: CGFloat = 10
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var isFromSearchPage = false
    weak var delegate: RYDishPageDelegate?
    var searchKeywords: String?
    var showLargeTitle = false
    var isFavoritesList: Bool = false
    
    private var tableViewStatus: ERYTableViewStatus = .none
    private var dishes: [RYDishModel] = []
    
    private var dataManager = RYDishListDataManager(nil)
    private var pageIndex: Int = 1 // for paging
    
//    lazy var customTransitionDelegate = RYViewContrllerTransitioningDelegate()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "RYDishItemCell", bundle: nil), forCellReuseIdentifier: "RYDishItemCell")
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = showLargeTitle
        }
        
        // add gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        tapGesture.cancelsTouchesInView = false // otherwise, blocking the cell selection
        tableView.addGestureRecognizer(tapGesture)
        
        // API
        dataManager = RYDishListDataManager(self)
        
        // request api
        performDownloadData()
    }
    
    func performDownloadData() {
        dataManager.ryPerformDownloadData()
    }
    
    @objc private func tableTapped() {
        delegate?.tapTableView?()
    }
    
    deinit {
        tableView?.delegate = nil
    }

}

extension RYDishPage: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard dataManager.hasValidData() else {
            return 0
        }
        return dataManager.dishList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard dataManager.hasValidData() else {
            return CGFloat.leastNormalMagnitude
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dataManager.hasValidData() else {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard dataManager.hasValidData() else {
            return CGFloat.leastNormalMagnitude
        }
        return 130
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 120
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard dataManager.hasValidData() else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RYDishItemCell", for: indexPath)
        if let cell = cell as? RYDishItemCell, indexPath.section < dataManager.dishList.count {
            cell.update(dataManager.dishList[indexPath.section])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// perform protocol method
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section >= dataManager.dishList.count { return }
        let didSelectDish = dataManager.dishList[indexPath.section]
        
        if let dishDetailsPage = UIStoryboard.dishStoryboard_dishDetailsPage(), let dishId = didSelectDish.id {
            dishDetailsPage.dishID = dishId
            dishDetailsPage.isFromSearchResultList = isFromSearchPage
            if title == "我的收藏" {
                dishDetailsPage.isFromFavoriteList = true
            }
            
            if isFromSearchPage {
                // record historical page
                if let title = didSelectDish.title {
                    RYUserDefaultCenter.saveHistoricalKeyword(title)
                }
                
                // go to details page
                /*
                 dishDetailsPage.transitioningDelegate = customTransitionDelegate
                 //            dishDetailsPage.modalPresentationStyle = .custom
                 
                 dishDetailsPage.dishID = dishId
                 dishDetailsPage.isFromSearchResultList = true
                 present(dishDetailsPage, animated: true, completion: nil)
                 */
                
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = .fade
                transition.subtype = .fromRight
                transition.timingFunction = CAMediaTimingFunction(name: .default)
                if let window = self.view.window {
                    window.layer.add(transition, forKey: kCATransition)
                }
                let nav = RYNavigationController(rootViewController: dishDetailsPage)
                //            dishDetailsPage.isFromSearchResultList = true
                self.present(nav, animated: false, completion: nil)
                
            } else { // from category module
                navigationController?.pushViewController(dishDetailsPage, animated: true)
            }
        }
    }
}


// MARK: - RYDataManagerDelegate
extension RYDishPage: RYDataManagerDelegate {
    func ryDataManagerAPI(_ dataManager: RYBaseDataManager) -> String? {
        if isFavoritesList {
            guard let api = RYAPICenter.api_userCollectionList(pageIndex).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !api.isEmpty else { return nil }
            return api
        }
        
        guard let keyword = searchKeywords, !keyword.isEmpty else {
            return nil
        }
        guard let api = RYAPICenter.api_search(keyword, pageIndex).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !api.isEmpty else { return nil }
        return api
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, success: Any?, itemRetrived: Any?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, failure: Error?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, status: eRYDataListLoadingType) {
        // handle loading status
        switch status {
        case .none: // success
            tableView.showFooterActivityIndicator(for: status)
            
        case .loading:
            tableView.showFooterActivityIndicator(for: status)
            
        case .zeroData, .notReachable, .error:
            tableView.showFooterActivityIndicator(for: status, description: "暂时没有搜索到结果") {[weak self] in
                // reload
                self?.performDownloadData()
            }
        }
    }
}


extension RYDishPage: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.tapTableView?()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // two ways to load next page - 2st: pull to refresh
        let distance = scrollView.contentSize.height - scrollView.bounds.height
        if distance > 0 && scrollView.contentOffset.y > distance + Constants.kRYScrollToRefreshLength {
            // TODO: request api for dish list
            pageIndex += 1
            performDownloadData()
        }
    }
}

