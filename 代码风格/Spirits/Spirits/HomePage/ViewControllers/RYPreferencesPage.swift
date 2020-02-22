//
//  RYPreferencesPage.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/3/26.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

typealias PersonItemData = (imageName: String, title: String)

enum eRYPageType {
    case Preference, Filter
}

class RYPreferencesPage: RYBasedViewController {
    
    private struct Constants {
        static let reviewLink = "https://itunes.apple.com/us/app/miao-zhao-zhu-shou/id1457655044?l=zh&ls=1&mt=8"
    }
    
    // MARK: - Pubilc properties
    
    var pageType: eRYPageType = .Preference
    var navTitle: String?
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private properties
    
    private var items: [PersonItemData] {
        if pageType == .Filter {
            return [PersonItemData(RYIndexPathRecorder.isContainedIndex(at: 0) ? "choose" : "", "妙招"),
                    PersonItemData(RYIndexPathRecorder.isContainedIndex(at: 1) ? "choose" : "", "生活"),
                    PersonItemData(RYIndexPathRecorder.isContainedIndex(at: 2) ? "choose" : "", "健康"),
                    PersonItemData(RYIndexPathRecorder.isContainedIndex(at: 3) ? "choose" : "", "饮食")]
            
        } else {
            return [PersonItemData("person", RYProfileCenter.me.nickName ?? "编辑你的名字"),
                    PersonItemData("collect", "收藏夹"),
                    PersonItemData("evaluate", "给我们评价")]
        }
    }

    private var footerView: RYPreferencesFooterView?

    // MARK: - Life  Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
        }
        
        if let title = navTitle {
            self.title = title
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 11.0, *) {
            tableView.backgroundColor = UIColor(named: "Color_f1f8f9")
        } else {
            tableView.backgroundColor = RYColors.color(from: 0xf1f8f9)
        }
    }
}

// MARK: - UITableViewDataSource && UITableViewDelegate

extension RYPreferencesPage: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard pageType == .Preference && RYProfileCenter.me.isLogined else { return CGFloat.leastNormalMagnitude }
        
        if section == items.count - 1 && section > 1 {
            return 120
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RYProfileCell.self), for: indexPath)
        
        if let cell = cell as? RYProfileCell, indexPath.section < items.count {
            cell.update(items[indexPath.section])
            if pageType == .Filter { cell.hiddenRightArrow() }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard pageType == .Preference && RYProfileCenter.me.isLogined else { return nil }
        
        /// add login/loginout button
        if section == items.count - 1 && section > 1 {
            if let views = Bundle.main.loadNibNamed(String(describing: RYPreferencesFooterView.self), owner: nil, options: nil),
                let preferencesFooterView = views.first as? RYPreferencesFooterView {
                
                let size = preferencesFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                footerView?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: size.height)
                
                footerView = preferencesFooterView
                
                preferencesFooterView.delegate = self
                return preferencesFooterView
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if pageType == .Filter {
            if RYIndexPathRecorder.isContainedIndex(at: indexPath.section) {
                RYIndexPathRecorder.clearIndex(at: indexPath.section)
            } else {
                RYIndexPathRecorder.recordIndex(at: indexPath.section)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
            }
            
            return
        }
        
        switch indexPath.section {
        case 0: // go to edit name
            
            // check if has logined
            if !RYProfileCenter.me.isLogined {
                // go to login pannel
                RYLoginPannel.presentLoginPannel(from: self) { name in
                    self.tableView.reloadData()
                }
                return
            }
            
            let alert = UIAlertController(title: "请输入你的姓名", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            
            let okAction = UIAlertAction(title: "确定", style: .default) { action in
                if let textfields = alert.textFields,
                    let nameTextField = textfields.first,
                    let text = nameTextField.text, !text.isEmpty {
                    
                    // TODO: - Need login
                    RYProfileCenter.me.nickName = text
                    
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                }
            }
            alert.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { action in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
        case 1: // go to favorite list
            
            // check if has logined
            if !RYProfileCenter.me.isLogined {
                RYLoginPannel.presentLoginPannel(from: self)
                return
            }
            
            let favoriteList: RYFavoritesContainerPage = UIStoryboard(storyboard: .Main).instantiateViewController()
            navigationController?.pushViewController(favoriteList, animated: true)

        case 2: // go to evaluate
            if let url = URL(string: Constants.reviewLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        default:
            break
        }
    }
    
}

extension RYPreferencesPage: RYPreferencesFooterViewDelegate {
    func contentButtonTapped() {
        // loginout
        if RYProfileCenter.me.isLogined {
            
            RYProfileCenter.me.logout()
            
            // show toast
            view.makeToast("已退出登录", duration: 1.4, position: .center)
            
            // reload tableview
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
                self.tableView.reloadData()
            }
        }
    }
}
