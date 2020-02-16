//
//  RYSearchViewBulter.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/15.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit
import Alamofire

protocol RYSearchViewBulterDelegate: NSObjectProtocol { // Object for refrence type.
    /// declare required methods
}

extension RYSearchViewBulterDelegate {
    /// declare optional methods
    func viewBulter(_ viewBulter: RYSearchViewBulter?, selectedResultItem at: Any){
        // You can add default implementation here.
    }
}

class RYSearchViewBulter: NSObject {
    
    // MARK: - Properties
    private weak var hookVC: UIViewController?
    private weak var searchVC: UISearchController?
    
    private var searchBarTextField: UITextField?
    
    private var searchPanel: RYSearchPanel?
    private var searchDishList: RYDishPage?
    
    weak var delegate: RYSearchViewBulterDelegate?
    
    // MARK: - Public interface
    /// go to dish list page from categories.
    func presentSearchController(_ text: String?) {
        guard let searchVC = searchVC else { return }
        if !searchVC.searchBar.isFirstResponder {
            searchVC.searchBar.text = text
            searchVC.searchBar.becomeFirstResponder()
            if let text = text {
               showSearchResult(text)
               dismissKeyboard()
            }
        }
    }
    
    func fixSearchBarUI() {
        setupNavigationBarButtonItem()
    }
    
    // MARK: - Init
    init(_ hookViewController: UIViewController, searchController: UISearchController) {
        super.init()
        hookVC = hookViewController
        searchVC = searchController
        
        // setup
        setupNavigationBarButtonItem()
        setupSearchController()
    }

    private func setupNavigationBarButtonItem() {
        guard let hookVC = hookVC, let searchVC = searchVC else { return }
        if let helperVC = hookVC as? RYHomePage {
            helperVC.titleBarButtonItem.leftCustomizeView("首页", backgroundColor: nil)
            helperVC.navigationItem.leftBarButtonItems = [helperVC.titleBarButtonItem]
            helperVC.navigationItem.hidesBackButton = true
            helperVC.navigationItem.titleView = searchVC.searchBar
        } else if let helperVC = hookVC as? RYCategoryPage {
            helperVC.titleBarButtonItem.leftCustomizeView("类别", backgroundColor: nil)
            helperVC.navigationItem.leftBarButtonItems = [helperVC.titleBarButtonItem]
            helperVC.navigationItem.hidesBackButton = true
            helperVC.navigationItem.titleView = searchVC.searchBar
        }
    }
    
    private func setupSearchController() {
        // 1. config view controller
        searchVC?.delegate = self
        searchVC?.searchResultsUpdater = self
        
        searchVC?.dimsBackgroundDuringPresentation = false
        searchVC?.definesPresentationContext = true
        searchVC?.hidesNavigationBarDuringPresentation = false
        
        // 2. config search bar style
        searchVC?.searchBar.delegate = self
        searchVC?.searchBar.searchBarStyle = .minimal // no background. almostly used by Calendar, Notes and Music.
        searchVC?.searchBar.setImage(UIImage(named: "search"), for: .search, state: .normal)
        searchVC?.searchBar.tintColor = RYFormatter.shallowYellowColor()
        searchVC?.searchBar.barTintColor = RYFormatter.color(from: 0xF2F2F2)
        // 3. config text field in search bar
        if let textField = searchVC?.searchBar.value(forKey: "_searchField") as? UITextField {
            textField.textColor = .black
            /*
            textField.setValue(RYFormatter.textDarkColor(), forKeyPath: "_placeholderLabel.textColor")
            textField.setValue(RYFormatter.font(for: .regular, fontSize: 18.0), forKeyPath: "_placeholderLabel.font")
             */
            textField.attributedPlaceholder = NSAttributedString(string: "搜索菜谱", attributes: [.foregroundColor: RYFormatter.textDarkColor(), .font: RYFormatter.font(for: .regular, fontSize: 15.0)])
            if let _ = searchVC?.searchBar {
                if #available(iOS 11, *) {
                    textField.roundedCorner(nil, 20)
                } else {
                    textField.roundedCorner(nil, 14)
                }
            }
            
            textField.textAlignment = .left
            textField.backgroundColor = RYFormatter.color(from: 0xF2F2F2)
            searchBarTextField = textField
            searchBarTextField?.rightViewMode = .whileEditing
        }
        
        // 4. config search result panel
        if let searchVC = searchVC, let searchPanel = UIStoryboard.searchStoryboard_searchPage() {
            searchVC.addChild(searchPanel)
            searchVC.view.addSubview(searchPanel.view)
            
            let bounds = searchVC.view.bounds
            let height = RYFormatter.navigationBarPlusStatusBarHeight(for: hookVC)
            if #available(iOS 11, *) {
                searchPanel.view.frame = CGRect(x: 0, y: height + 10, width: bounds.width, height: bounds.height) // Special number:Why not is 64px?   // is available above on ios11
            } else {
               searchPanel.view.frame = CGRect(x: 0, y: height, width: bounds.width, height: bounds.height - height) // is available below ios11
            }
            searchPanel.delegate = self
            self.searchPanel = searchPanel
        }
    }
    // nav -> nav.rootcontro
    private func setupDishesList(_ keywords: String?) {
        guard searchDishList == nil else {
            return
        }
        
        if let searchVC = searchVC,
            let dishPage = UIStoryboard.dishStoryboard_dishPage() {
            // assign values for dishpage's setup
            dishPage.delegate = self
            dishPage.isFromSearchPage = true
            dishPage.searchKeywords = keywords
            
            // add dishpage as searchvc's view subview
            searchVC.addChild(dishPage)
            searchVC.view.addSubview(dishPage.view)
            let bounds = searchVC.view.bounds
            let height = RYFormatter.navigationBarPlusStatusBarHeight(for: hookVC)
            dishPage.view.frame = CGRect(x: 0, y: height, width: bounds.width, height: bounds.height - height) // Special number:Why not is 64px?
            searchVC.view.bringSubviewToFront(dishPage.view)
            
            // save dishpage instance
            self.searchDishList = dishPage
        }
    }
    
    private func removeDishesList() {
        if let dishList = searchDishList {
            dishList.view.removeFromSuperview()
            dishList.removeFromParent()
            searchDishList = nil
        }
    }
    
    private func startIndicatorView() {
        guard let textField = searchBarTextField else {
            return
        }
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.color = RYFormatter.shallowYellowColor()
        textField.rightView = indicator
        textField.rightViewMode = .always
        indicator.startAnimating()
        indicator.tag = 1001
    }
    
    private func stopIndicatorView() {
        if let textField = searchBarTextField,
            let indicator = textField.viewWithTag(1001) as? UIActivityIndicatorView {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
}

// MARK: - UISearchControllerDelegate
extension RYSearchViewBulter: UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        
        hookVC?.navigationItem.leftBarButtonItems = []
        hookVC?.tabBarController?.tabBar.isHidden = true
        searchController.searchBar.showsCancelButton = true
        if let cancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitle("取消", for: .normal)
            cancelButton.setTitleColor(RYFormatter.textNavDarkColor(), for: .normal)
            cancelButton.titleLabel?.font = RYFormatter.font(for: .regular, fontSize: 17.0)
        }
        
        // reload searchPanel's content
        searchPanel?.update()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        if let hookVC = hookVC as? RYHomePage {
            hookVC.navigationItem.leftBarButtonItems = [hookVC.titleBarButtonItem]
            hookVC.tabBarController?.tabBar.isHidden = false
        } else if let hookVC = hookVC as? RYCategoryPage {
            hookVC.navigationItem.leftBarButtonItems = [hookVC.titleBarButtonItem]
            hookVC.tabBarController?.tabBar.isHidden = false
        }
        searchVC?.searchBar.showsCancelButton = false
    }
}

// MARK: - UISearchResultsUpdating
extension RYSearchViewBulter: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            stopIndicatorView()
            removeDishesList()
            return
        }
        
//        startIndicatorView()
        let trimmedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // show result: dishlist page
        showSearchResult(trimmedText)
    }
    
    /// NOTE: Because of there is not keywords auto-complete api, I need migrate search api to class `RYDishPage`.
    /// Show dish page and request data, present data... in it.
    private func showSearchResult(_ keywords: String?) {
        guard let searchDishList = searchDishList else {
            setupDishesList(keywords)
            return
        }
        searchDishList.searchKeywords = keywords
        searchDishList.performDownloadData()
    }
}

// MARK: - UISearchBarDelegate
extension RYSearchViewBulter: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.isFirstResponder {
            searchBar.becomeFirstResponder()
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !(trimmedText == searchText) {
            searchBar.text = trimmedText
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        let trimmedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // show dish page and request data, present data... in it.
        showSearchResult(trimmedText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // reload historical keywords
        searchPanel?.collectionView.reloadData()
    }
}

// MARK: - RYSearchPanelDelegate
extension RYSearchViewBulter: RYSearchPanelDelegate {
    func tapCollectionView() {
        dismissKeyboard()
    }
    
    func searchPanel(_ searchPanel: RYSearchPanel?, didSelectKeyword keyword: String) {
        searchBarTextField?.text = keyword
        showSearchResult(keyword)
    }
    
    private func dismissKeyboard() {
        if let searchVC = searchVC {
            if searchVC.searchBar.isFirstResponder { searchVC.searchBar.resignFirstResponder() }
        }
    }
}

// MARK: - RYDishPageDelegate
extension RYSearchViewBulter: RYDishPageDelegate {
    func tapTableView() {
        dismissKeyboard()
    }
    
    func dishPage(_ dishPage: RYDishPage?, didSelectDishAt dishID: Int) {
        // go to dish details page
        if let dishDetailsPage = UIStoryboard.dishStoryboard_dishDetailsPage() {
            dishDetailsPage.dishID = dishID
            
            let transition = CATransition()
            transition.duration = 0.32
            transition.type = .push
            transition.subtype = .fromRight
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            if let window = searchVC?.view.window {
                window.layer.add(transition, forKey: kCATransition)
            }
            let nav = RYNavigationController(rootViewController: dishDetailsPage)
            dishDetailsPage.isFromSearchResultList = true
            searchVC?.present(nav, animated: false, completion: nil)
        }
        
    }
    
}


