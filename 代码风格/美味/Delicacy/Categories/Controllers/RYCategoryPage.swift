//
//  RYCategoryPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/9.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

class RYCategoryPage: RYBaseViewController, RYSearchViewBulterDelegate, RYDataManagerDelegate {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subTableView: UITableView!
    
    @IBOutlet var titleBarButtonItem: UIBarButtonItem!
    
    private let searchVC: UISearchController = UISearchController(searchResultsController: nil)
    private var searchViewBulter: RYSearchViewBulter?
    
    private var dataManager = RYCategoryDataManager(nil)
    private var selectedIndexPath = IndexPath(row: 0, section: 0) // selected first row by default.
    private var cacheHelper = RYCategorySubCellHeightCache()
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYCategoryPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYCategoryPage()
    }
    
    private func setup_RYCategoryPage() {
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = RYColors.gray_mid
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        
        subTableView.delegate = self
        subTableView.dataSource = self
        subTableView.backgroundColor = RYColors.gray_mid
        subTableView.register(UINib(nibName: "RYCategoryHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "RYCategoryHeaderView")
        
        searchViewBulter = RYSearchViewBulter(self, searchController: searchVC)
        searchViewBulter?.delegate = self
        
        dataManager = RYCategoryDataManager(self)
        dataManager.ryPerformDownloadData()
    }
    
    private func performDownloadData() {
        cacheHelper = RYCategorySubCellHeightCache()
        selectedIndexPath = IndexPath(row: 0, section: 0)
        dataManager.cleanData()
        dataManager.ryPerformDownloadData()
    }
    
    deinit {
        tableView?.delegate = nil // optional `?` for preventing crash
        subTableView?.delegate = nil
    }
    
    // MARK: - RYSearchViewBulterDelegate
    func viewBulter(_ viewBulter: RYSearchViewBulter?, selectedResultItem at: Any) {
        
    }
    
    // MARK: - RYDataManagerDelegate
    func ryDataManagerAPI(_ dataManager: RYBaseDataManager) -> String? {
        guard let api = RYAPICenter.api_category().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ""
        }
        return api
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, success: Any?, itemRetrived: Any?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.subTableView.reloadData()
        }
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, failure: Error?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.subTableView.reloadData()
        }
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, status: eRYDataListLoadingType) {
        // handle loading status
        switch status {
        case .none: // success
            subTableView.showFooterActivityIndicator(for: status)
            
        case .loading:
            subTableView.showFooterActivityIndicator(for: status)
            
        case .zeroData, .notReachable, .error:
            subTableView.showFooterActivityIndicator(for: status, description: "网络好像出错了") {[weak self] in
                // reload
                self?.performDownloadData()
            }
        }
    }
    
}


// MARK: - UITableViewDelegate
private let kRYHeightForSubTableViewCell: CGFloat = 223

extension RYCategoryPage: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = dataManager.categories.count
        guard count > 0 else {
            return 0
        }
        if tableView === subTableView {
            return count
        } else { // self.tableView
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard dataManager.categories.count > 0 else {
            return CGFloat.leastNormalMagnitude
        }
        if tableView === subTableView {
            return 55.0
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dataManager.categories.count > 0 else {
            return 0
        }
        if tableView === subTableView {
            return 1 // return one custom subview: collectionView
        } else {
            return dataManager.categories.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === subTableView {
            // use cached height if has cached height at indexpath
            if cacheHelper.isCachedHeight(for: indexPath) {
                return cacheHelper.cachedHeight(for: indexPath)
            } else {
                // calculate and cache
                if let subCategories = dataManager.categories[indexPath.section].subCategories, subCategories.count > 0 {
                    let height = cacheHelper.calculateCellHeight(subCategories.count, width: subTableView.bounds.width)
                    cacheHelper.cacheHeight(for: indexPath, willCacheHeight: height)
                    return height
                }
                return kRYHeightForSubTableViewCell // default height
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === subTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYCategorySubCell", for: indexPath)
            if let cell = cell as? RYCategorySubCell {
                // update with children category
            if let subCategories = dataManager.categories[indexPath.section].subCategories, subCategories.count > 0, indexPath.row < subCategories.count {
                    cell.update(subCategories)
                    cell.delegate = self
                }
            }
            return cell
            
        } else { // self.tableView
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYCategoryMainCell", for: indexPath)
            if let cell = cell as? RYCategoryMainCell, indexPath.row < dataManager.categories.count {
                cell.update(dataManager.categories[indexPath.row].name)
                if indexPath == selectedIndexPath {
                    cell.showState(isSelected: true)
                } else {
                    cell.showState(isSelected: false)
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard dataManager.categories.count > 0 else {
            return nil
        }
        if tableView === subTableView {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "RYCategoryHeaderView")
            if let headerView = headerView as? RYCategoryHeaderView, section < dataManager.categories.count {
                headerView.update(dataManager.categories[section].name)
            }
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        DispatchQueue.main.async {
            // 1. reload tableview UI
            self.didSelectTableViewRow(at: indexPath)
            
            // 2. scroll sub tableview section
            let deadlineTime = DispatchTime.now() + 0.2
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                self.subTableView.scrollToRow(at: IndexPath(row: 0, section: indexPath.row), at: .middle, animated: true)
            })
        }
    }
    
    private func didSelectTableViewRow(at indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.tableView.reloadData()
    }
}

// MARK: - UIScrollViewDelegate
extension RYCategoryPage: UIScrollViewDelegate {
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === subTableView else {
            return
        }
        
        // 1. judge sub scrollview contentoffset.y
        // or 1. duration section
        if let indexPath = subTableView.indexPathForRow(at: scrollView.contentOffset) {
            // 2. scroll tableview to indexpath
            DispatchQueue.main.async {
                self.didSelectTableViewRow(at: IndexPath(row: indexPath.section, section: 0))
            }
        }
    }
    */
 
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // isTracking + isDragging + isDecelerating
        let scrollToStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToStop {
            scrollViewDidEndScroll(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScroll(scrollView)
        }
    }
    
    /// 主表视图的点击动作状态 和 副表视图的点击动作状态 不能互相影响, 只可以单向影响
    /// 这里需要把两个状态分开
    private func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
//            self.didSelectTableViewRow(at: IndexPath(row: indexPath.section, section: 0))
//            self.tableView.selectRow(at: IndexPath(row: indexPath.section, section: 0), animated: true, scrollPosition: .middle)
        }
    }
}


// MARK: - RYCategorySubCellDelegate
extension RYCategoryPage: RYCategorySubCellDelegate {
    
    func subCategoryCell(_ cell: RYCategorySubCell, didSelectedCategory categoryName: String) {
        // go to search list about `categoryName`.
        searchViewBulter?.presentSearchController(categoryName)
    }
}
