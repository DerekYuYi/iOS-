//
//  RYProfilePage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/9.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

private let kRYHeightForFloatProfileView: CGFloat = 80.0
private let kRYTopGapForFloatProfileView: CGFloat = 20.0

class RYProfilePage: RYBaseViewController, RYNavigationStyleTransparent {
    
    @IBOutlet var titleBarButtonItem: UIBarButtonItem!
    @IBOutlet var settingBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loginButton: UIButton!
    
    private var profileCardView: RYFloatProfileView? = nil
    private let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    private var navBarPlusStatusBarHeight: CGFloat = 0
    
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYProfilePage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYProfilePage()
    }
    
    private func setup_RYProfilePage() {
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            title = "我的"
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            titleBarButtonItem.leftCustomizeView("我的", backgroundColor: RYColors.yellow_theme)
            self.navigationItem.leftBarButtonItems = [titleBarButtonItem]
        }
        
        settingBarButtonItem.image = UIImage(named: "setting")
        settingBarButtonItem.tintColor = .black
        self.navigationItem.rightBarButtonItems = [settingBarButtonItem]
        // 2. setup floatcardView
        if let views = Bundle.main.loadNibNamed("RYFloatProfileView", owner: nil, options: nil),
            let floatProfileView = views.first as? RYFloatProfileView {
            view.addSubview(floatProfileView)
            view.bringSubviewToFront(floatProfileView)
            floatProfileView.layer.zPosition = 1001
            
            profileCardView?.update()
            profileCardView = floatProfileView
            
            profileCardView?.tapClosure = {
                if let perferencePage = UIStoryboard.preferenceStoryboard_PreferencePage() {
                    perferencePage.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(perferencePage, animated: true)
                }
            }
        }
        
        // 3. setup tableview related
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 170)
        tableHeaderView.backgroundColor = RYColors.yellow_theme
        tableView.tableHeaderView = tableHeaderView
        
        // 4. register a empty cell for adapt UI
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmptyCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let floatProfileView = profileCardView else { return }
        navBarPlusStatusBarHeight = RYFormatter.navigationBarPlusStatusBarHeight(for: self)
        let size = floatProfileView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        floatProfileView.frame = CGRect(x: 15.0, y: navBarPlusStatusBarHeight + kRYTopGapForFloatProfileView, width: view.bounds.width - 15.0 * 2, height: size.height)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // login button
        if RYProfileCenter.me.isLogined {
            loginButton.setTitle("退出登录", for: .normal)
            loginButton.isEnabled = false
            loginButton.isHidden = true
        } else {
            loginButton.setTitle("登录", for: .normal)
            loginButton.isEnabled = true
            loginButton.isHidden = false
        }
        loginButton.roundedCorner(nil, 5)
        
        // update profile
        profileCardView?.update()
    }
    
    deinit {
        tableView?.delegate = nil // optional `?` for preventing crash
    }
    
    // MARK: - Touch events
    @IBAction func settingBarButtonItemTapped(_ sender: UIBarButtonItem) {
        // go to setting page
        if let settingPage = UIStoryboard.settingStoryboard_SettingPage() {
            settingPage.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingPage, animated: true)
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if RYProfileCenter.me.isLogined {
            // show indicator and login out
        } else {
            // go to login page
            if let loginBoardPage = UIStoryboard.loginStoryboard_loginBoardPage() {
                self.present(loginBoardPage, animated: true, completion: nil)
            }
        }
    }
}

extension RYProfilePage: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return RYFormatter.isiPhoneXSeries() ? 120 : 90
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
            cell.contentView.backgroundColor = .white
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYProfileFavoritesCell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? RYProfileFavoritesCell else { return }
        cell.shakeContentView()
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
            guard RYProfileCenter.me.isLogined else {
                RYUITweaker.simpleAlert("尚未登录", message: "请先登录")
                return
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            if let dishesPage = UIStoryboard.dishStoryboard_dishPage() {
                dishesPage.isFavoritesList = true
                dishesPage.showLargeTitle = true
                dishesPage.hidesBottomBarWhenPushed = true
                dishesPage.title = "我的收藏"
                navigationController?.pushViewController(dishesPage, animated: true)
            }
        }
    }
}


extension RYProfilePage: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        
        // 1. handle profilecardview
        let off: CGFloat = kRYTopGapForFloatProfileView
        if contentOffsetY <= off && contentOffsetY >= 0 {
            if let profileCardView = self.profileCardView {
                let point = CGPoint(x: profileCardView.frame.origin.x, y: navBarPlusStatusBarHeight + off - contentOffsetY)
                let size = profileCardView.frame.size
                profileCardView.frame = CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
            }
        }
        
//        // 2. handle tableheaderView  // Note: Can't work normally
//        let originWidth = tableView.bounds.width
//        let height: CGFloat = 170
//
//        if contentOffsetY < 0 {
//            DispatchQueue.main.async {
////                self.tableHeaderView.frame = CGRect(x: 0, y: pow(contentOffsetY, 0.52), width: originWidth, height: height)
//                let currentHeight = height - contentOffsetY
////                let scale = currentHeight / height
//                let x: CGFloat = 0.0
//                let y = contentOffsetY
//                self.tableHeaderView.frame = CGRect(x: x, y: y, width: originWidth, height: currentHeight)
//            }
//        }
    }
}
