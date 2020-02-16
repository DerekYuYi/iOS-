//
//  RYBaseViewController.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/26.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

class RYBaseViewController: UIViewController, RefreshProtocol {
    
    var refreshControl: UIRefreshControl?
    /*
    var leftTitleBarButtonItem: UIBarButtonItem {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.leftCustomizeView(<#T##title: String##String#>)
        return barButtonItem
    }
    */
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYBaseViewController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYBaseViewController()
    }
    
    private func setup_RYBaseViewController() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    // MARK: - RefreshProtocol
    func setupRefreshing() {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
        }
        if let refreshControl = self.refreshControl {
            refreshControl.attributedTitle = refreshText()
            refreshControl.tintColor = .red
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            
            if let scrollView = refreshScrollView() {
                scrollView.alwaysBounceVertical = true
                scrollView.insertSubview(refreshControl, at: 0)
            }
        }
    }
    
    func refreshScrollView() -> UIScrollView? {
        return nil
    }
    
//    func refreshText() -> NSAttributedString? {
//
//    }
    
    func endRefreshing() {
        guard let refreshControl = self.refreshControl else { return }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            refreshControl.endRefreshing()
            refreshControl.attributedTitle = self.refreshText()
        }
        
        if let scrollView = refreshScrollView() {
            DispatchQueue.main.async {
                scrollView.sendSubviewToBack(refreshControl)
            }
            
            DispatchQueue.main.async {
                if scrollView.contentOffset.y < 0 {
                    scrollView.contentOffset = CGPoint(x: 0, y: 0)
                }
            }
        }
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        if let refreshControl = self.refreshControl {
            refreshControl.attributedTitle = refreshText()
            
            if let scrollView = refreshScrollView() {
                scrollView.sendSubviewToBack(refreshControl)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}


