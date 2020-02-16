//
//  RYSearchPanel.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/17.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

protocol RYSearchPanelDelegate: NSObjectProtocol {
    func tapCollectionView()
    func searchPanel(_ searchPanel: RYSearchPanel?, didSelectKeyword keyword: String)
}

class RYSearchPanel: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    weak var delegate: RYSearchPanelDelegate?
    
    private let hotSearchs = RYUserDefaultCenter.searchHotKeywords()
    private var historySearchs: [String]? {
        return RYUserDefaultCenter.searchHistoricalKeywords()
    }
    private var dishes: [RYDishModel] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 1. collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "RYHPHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "RYHPHeaderView")
        
        if let flowlayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowlayout.estimatedItemSize = CGSize(width: 60, height: 30)
        }
        
        // 2. add gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        tapGesture.cancelsTouchesInView = false // otherwise, blocking the cell selection
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    func update() {
        collectionView.reloadData()
    }
    
    @objc private func tableTapped() {
        delegate?.tapCollectionView()
    }
    
    deinit {
        collectionView?.delegate = nil
    }
}

extension RYSearchPanel: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let historySearchs = historySearchs, historySearchs.count > 0 {
            return 2 // history section + hot section
        }
        return 1 // only hot section
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return hotSearchs.count
        } else {
            if let historySearchs = historySearchs {
                return historySearchs.count
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RYHotCell", for: indexPath)
        if let cell = cell as? RYHotCell {
            cell.update(keyword(at: indexPath))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let res = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "RYHPHeaderView", for: indexPath)
        if let res = res as? RYHPHeaderView {
            var title = "热门搜索"
            if indexPath.section == 0 {
                res.enableClearButton(false)
            } else if indexPath.section == 1 {
                res.enableClearButton(true)
                res.delegate = self
                title = "历史搜索"
            }
            res.enableMoreButton(false)
            res.update(title)
        }
        return res
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // go to search with keyword selected.
        delegate?.searchPanel(self, didSelectKeyword: keyword(at: indexPath))
    }
    
    private func keyword(at indexPath: IndexPath) -> String {
        var keyword = ""
        if (indexPath.section == 0) && (indexPath.row < hotSearchs.count) {
            keyword = hotSearchs[indexPath.row]
        } else {
            if let historySearchs = historySearchs, historySearchs.count > 0, indexPath.row < historySearchs.count {
                keyword = historySearchs[indexPath.row]
            }
        }
        return keyword
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.tapCollectionView()
    }
}

extension RYSearchPanel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    /// use estimatedItemSize
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 30)
    }
    */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 15.0
        }
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 10.0
        }
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 5)
        }
}

extension RYSearchPanel: RYHPHeaderViewDelegate {
    func headerView(_ headerView: RYHPHeaderView, clearButtonTapped: UIButton) {
        RYUserDefaultCenter.clearHistoricalKeywords()
        collectionView.reloadData()
    }
}
