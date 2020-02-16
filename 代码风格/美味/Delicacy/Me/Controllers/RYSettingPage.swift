//
//  RYSettingPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/7.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

private let kRYReviewLink = "https://itunes.apple.com/us/app/you-yu-mei-shi/id1436818171?l=zh&ls=1&mt=8"

class RYSettingPage: RYBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    private var diskCacheSize: Double?
    
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
        self.title = "设置"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = RYFormatter.bgLightGrayColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // calculate disk cache size
        RYDataManager.cacheDataSize { cacheSize in
            self.diskCacheSize = cacheSize
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    deinit {
        tableView?.delegate = nil
        self.view.hideAllToasts()
        self.view.clearToastQueue()
    }
    
}

private let kRYHeightForHeaderInSection: CGFloat = 16
private let kRYHeightForFooterInSection: CGFloat = 84

extension RYSettingPage: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kRYHeightForHeaderInSection
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return kRYHeightForFooterInSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RYSettingCell", for: indexPath)
        if let cell = cell as? RYSettingCell {
            if indexPath.row == 0 {
                if let diskCacheSize = diskCacheSize {
                    cell.update("清除缓存", detailsTitle:"\(diskCacheSize) M")
                } else {
                    cell.update("清除缓存", detailsTitle:"0.0 M")
                }
            } else if indexPath.row == 1 {
                cell.update("评价我们", detailsTitle:"")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard RYProfileCenter.me.isLogined else { return nil }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: kRYHeightForFooterInSection))
        view.backgroundColor = RYFormatter.bgLightGrayColor()
        
        let logoutButton = RYButton(type: .system)
        logoutButton.frame = CGRect(x: 20, y: 40, width: view.bounds.width - 20*2, height: 44)
        logoutButton.roundedCorner(nil, 5)
        logoutButton.setTitle("退出登录", for: .normal)
        logoutButton.setTitleColor(RYColors.black_333333, for: .normal)
        logoutButton.titleLabel?.font = RYFormatter.fontLarge(for: .regular)
        logoutButton.backgroundColor = RYColors.yellow_theme
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        view.addSubview(logoutButton)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == 0 {
            RYUITweaker.moreAlert("清除缓存", message: "将会清除视频、图片产生的缓存", okString: "确定", triggerOK: {
                // 1. toast loading
                DispatchQueue.main.async {
                    self.view.makeToastActivity(.center)
                }
                
                // 2. excute clear operation
                RYDataManager.clearDiskCacheData({
                    // 3. toast
                    DispatchQueue.main.async {
                        self.view.hideToastActivity()
                        self.view.makeToast("清除成功", duration: 1.7, position: .center)
                    }
                    
                    // 4. update UI
                    self.diskCacheSize = 0
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }, cancelString: "取消") {
            }
        } else if indexPath.row == 1 {
            if let url = URL(string: kRYReviewLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc private func logoutButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: RYAPICenter.api_logout()) else { return }
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        let dataRequest = Alamofire.request(request)
        
        // visible network indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            sender.showIndicatorView(true)
            sender.setTitle("", for: .normal)
        }
        
        dataRequest.responseData {[weak self] response in
            // 1. asynchronously handle indicators
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                sender.showIndicatorView(false)
            }
            
            // 2. guard
            guard let strongSelf = self else { return }
            
            switch response.result {
            case .success(let value):
                let dict = try? JSONSerialization.jsonObject(with: value, options: .allowFragments)
                
                if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
                    // 1. clear profile data
                    RYProfileCenter.me.logout()
                    
                    // 2. clear the archivered sessionid in cookie
                    RYUserDefaultCenter.clearArchiveredSessionID()
                    
                    // 3. reload UI
                    DispatchQueue.main.async {
                        sender.removeFromSuperview()
                        strongSelf.tableView.reloadData()
                    }
                    
                    // 4. pop
                    strongSelf.navigationController?.popViewController(animated: true)
                }
                
            case .failure:
                DispatchQueue.main.async {
                    strongSelf.view.makeToast("退出登录异常, 请稍后再试", duration: 2.0, position: .center)
                    sender.setTitle("退出登录", for: .normal)
                }
            }
        }
    }
}



