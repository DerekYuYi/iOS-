//
//  RYFavoritesListPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/4/4.
//  Copyright © 2019 RuiYu. All rights reserved.
//


/// NOTE: No Use. Replaced with `RYDishPage` class.

import UIKit

class RYFavoritesListPage: RYBaseViewController {

    @IBOutlet weak var tableView: UITableView!

    private var dataManager = RYFavoritesDataManager(nil)
    private var pageIndex: Int = 1 // for paging
    
    
    // MARK: - Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYSettingPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYSettingPage()
    }
    
    private func setup_RYSettingPage() {
        self.title = "收藏列表"
    }
    
    deinit {
        tableView?.delegate = nil
    }
    
    // MARK: - Cycle life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "RYDishItemCell", bundle: nil), forCellReuseIdentifier: "RYDishItemCell")
        
        // API
//        dataManager = RYDishListDataManager(self)
        
        // request api
        performDownloadData()
    }
    
    func performDownloadData() {
        dataManager.ryPerformDownloadData()
    }
}


extension RYFavoritesListPage: UITableViewDelegate, UITableViewDataSource {
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
        return UITableView.automaticDimension
    }
    
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
        
        // go to favorite center
        if indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            if let favoritePage = UIStoryboard.profileStoryboard_FavoritesPage() {
                navigationController?.pushViewController(favoritePage, animated: true)
            }
        }
    }
}

