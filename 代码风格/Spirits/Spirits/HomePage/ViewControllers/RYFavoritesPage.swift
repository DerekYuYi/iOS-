//
//  RYFavoritesPage.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/3/26.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

typealias DoubleStringItem = (first: String, second: String)

class RYFavoritesPage: RYBasedViewController {
    
    private struct Constants {
        static let contentCellIdentifier = String(describing: RYFavoritesContentCell.self)
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var typeItem: RYTypeItem?
    
    private var pageNumber: Int = 1
    private var requestManager = RYTypeListRequestManager(nil)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if #available(iOS 11.0, *) {
            tableView.backgroundColor = UIColor(named: "Color_f1f8f9")
        } else {
            tableView.backgroundColor = RYColors.color(from: 0xF1F8F9)
        }
        tableView.allowsSelection = false // cancel select
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.contentCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.contentCellIdentifier)
        
        // request manager
        requestManager = RYTypeListRequestManager(self)
        requestFavoritesListAPI()
    }
    
    /// API request
    private func requestFavoritesListAPI() {
        guard RYProfileCenter.me.isLogined else { return }
        guard let type = typeItem?.id else { return }
        
//        self.showLoadingView(true)
        self.showLoadingView(true, offset: .top(-80))
        
        // asyncafter 1 second for show loading
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.requestManager.performRequest(RYAPICenter.api_favoritesList(for: type, pageNumber: self.pageNumber), isNeedAuthorization: true)
        }
    }
}


// MARK: - UITableViewDataSource && UITableViewDelegate

extension RYFavoritesPage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard requestManager.typeList.count > 0 else { return 0 }
        return requestManager.typeList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard requestManager.typeList.count > 0 else { return CGFloat.leastNormalMagnitude }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard requestManager.typeList.count > 0 else { return 0 }
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard requestManager.typeList.count > 0 else { return 0 }
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.contentCellIdentifier, for: indexPath)
        if let cell = cell as? RYFavoritesContentCell, indexPath.section < requestManager.typeList.count {
            // update cell data
            cell.update(requestManager.typeList[indexPath.section], indexPath: indexPath)
            
            // config delegate
            cell.delegate = self
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "delete") { (action, indexPath) in
            debugPrint("Did tapped action.")
        }
        return [deleteAction]
    }
    */
}


// MARK: - RYFavoritesContentCellDelegate

extension RYFavoritesPage: RYFavoritesContentCellDelegate {
    
    func cancelCollection(at indexPath: IndexPath) {
        
        // condition guard
        guard indexPath.section < requestManager.typeList.count else { return }
        guard let type = requestManager.typeList[indexPath.section].id else { return }
        
        // request api to dislike
        RYFavoritesRequester.requestCancelFavoritesAPI(type)
        
        // update tableview data
        requestManager.typeList.remove(at: indexPath.section)
        
        // reload tableview
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            self.tableView.endUpdates()
            
            self.tableView.reloadData()
        }
        
    }
}


// MARK: - RYTypeListRequestManagerDelegate

extension RYFavoritesPage: RYTypeListRequestManagerDelegate {
    
    func requestStatus(_ requestManager: RYTypeListRequestManager, _ status: eRYRequestStatus) {
        
        DispatchQueue.main.async {
            switch status {
            case .success(let isFull):
                if !isFull {
                    self.showLoadingView(false)
                    if requestManager.typeList.count > 0 {
                        // no more
                        self.view.makeToast("我也是有底线的", duration: 1.0, position: .bottom)
                    } else {
                        self.view.makeToast("貌似该列表下没有收藏, 去别的列表看看", duration: 1.4, position: .center, title: "收藏为空")
                    }
                    
                } else {
                    self.showLoadingView(false)
                    self.tableView.reloadData()
                }
                
            case .failed:
                self.showLoadingView(false)
                self.view.makeToast("获取列表失败, 请稍后重试", duration: 1.4, position: .center, title: "网络不佳")
                
            case .loading:
                self.showLoadingView(true, offset: .top(-80))
            }
        }
    }
}


extension RYFavoritesPage: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let distance = scrollView.contentSize.height - scrollView.bounds.height
        if distance > 0 && scrollView.contentOffset.y > distance + 10 {
            // TODO: request api for dish list
            
            if requestManager.pagingEnabled(for: pageNumber+1) {
                pageNumber += 1
                requestFavoritesListAPI()
            } else {
                self.view.makeToast("我也是有底线的", duration: 1.0, position: .bottom)
            }
        }
    }
}

