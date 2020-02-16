//
//  RYSkillDetailsPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/19.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit

class RYSkillDetailsPage: RYBaseViewController, RYNavigationStyleTransparent {
    
    var skillID: Int?
    
    @IBOutlet weak var tableView: UITableView!
    private var videoCell: RYSkillDetailsVideoCell?
    private var isLandscape = false
    
    @IBOutlet var leftBarButtonItem: UIBarButtonItem!
    private var dataManager = RYSkillDataManager(nil)
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYSkillDetailsPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYSkillDetailsPage()
    }
    
    func setup_RYSkillDetailsPage() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.backBarButtonItem = nil // Cancel the backBarButtonItem's content in the parent controller(RYBaseViewController)
//        leftBarButtonItem.image = UIImage(named: "back_nav_white")
//        self.navigationItem.leftBarButtonItems = [leftBarButtonItem]
        
        // tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        // API
        dataManager = RYSkillDataManager(self)
        dataManager.ryPerformDownloadData()
    }
    
    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        tableView.bounds = view.bounds
    }
    */
    
    deinit {
        videoCell?.invalidatePlayer()
        tableView?.delegate = nil // optional `?` for preventing crash
    }
    
    /*
    @IBAction func leftBarButtonItemTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    */
}


private let kRYHeightForSectionCookingSkill: CGFloat = 44
private let kRYHeightForSectionCookingShare: CGFloat = kRYHeightForSectionCookingSkill
private let kRYHeightForHeaderView: CGFloat = 44

extension RYSkillDetailsPage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard dataManager.hasValidData() else { return 0 }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dataManager.hasValidData() else { return 0 }
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard dataManager.hasValidData() else { return CGFloat.leastNormalMagnitude }
        return 180.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RYSkillDetailsVideoCell", for: indexPath)
        if let cell = cell as? RYSkillDetailsVideoCell, let skillDetailsModel = dataManager.skillDetailsModel {
            cell.update(skillDetailsModel)
            cell.delegate = self
            videoCell = cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
}

extension RYSkillDetailsPage: RYDataManagerDelegate {
    // MARK: - RYDataManagerDelegate
    func ryDataManagerAPI(_ dataManager: RYBaseDataManager) -> String? {
        guard let api = RYAPICenter.api_skillDetails(skillID).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ""
        }
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
            tableView.showFooterActivityIndicator(for: status, description: "网络好像出错了", handler: nil)
        }
    }
}

// MARK: - RYSkillDetailsVideoCellDelegate
extension RYSkillDetailsPage: RYSkillDetailsVideoCellDelegate {
    func fullScreenButtonTapped() {
        // update status
        isLandscape = !isLandscape
        
        // prepare width and height
        var tableWidth = view.bounds.width
        var tableHeight = view.bounds.height
        
        if isLandscape { // fullscreen
            navigationController?.navigationBar.isHidden = true
            tableWidth = view.bounds.height
            tableHeight = view.bounds.width
            
            if RYFormatter.isiPhoneXSeries() {
                let homeIndicatorHeight: CGFloat = 34
                tableWidth = tableWidth - RYFormatter.statusBarHeight() - homeIndicatorHeight
                tableHeight = tableWidth * 9.0 / 16.0
            }
            
            self.tableView.bounds = CGRect(x: 0, y: 0, width: tableWidth, height: tableHeight)
        } else { // portrait
            navigationController?.navigationBar.isHidden = false
            self.tableView.bounds = CGRect(x: 0, y: 0, width: tableWidth, height: tableHeight)
        }
        
        // transform tableview
        
        UIView.animate(withDuration: 0.5, animations: {
            if self.isLandscape {
                self.tableView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
            } else {
                self.tableView.transform = CGAffineTransform.identity
            }
        }) { isFinished in
            if RYFormatter.isiPhoneXSeries() {
                if self.isLandscape {
//                    self.videoCell?.updatePlayerLayerFrame()
                    self.tableView.setContentOffset(CGPoint(x: 0, y: 19), animated: false)
                } else {
                    self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
            }
            self.tableView.isScrollEnabled = !self.isLandscape
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
