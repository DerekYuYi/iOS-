//
//  RYSquarePage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/2/22.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

enum eRYSquareSectionType {
    case banner, cookingExperience
}

class RYSquarePage: RYBaseViewController {
    
    private struct Constants {
        static let kRYEdgeInset_horizontal: CGFloat = 10
        static let kRYEdgeInset_vertical: CGFloat = 5
        static let kRYHeightForItem: CGFloat = 500
        static let kRYScrollToRefreshLength: CGFloat = 10
    }
    
    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var sectionList: [eRYSquareSectionType] = []
    private var dataManager = RYSquareDataManager(nil)
    
    private var pageIndex: Int = 1
    var navTitle: String = "广场"
    
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup_RYSquarePage() {
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = navTitle
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // config collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "RYSquareCell", bundle: nil), forCellWithReuseIdentifier: "RYSquareCell")
        
        // request
        dataManager = RYSquareDataManager(self)
        performDownloadData()
    }
    
    private func performDownloadData() {
        sectionList = []
        dataManager.ryPerformDownloadData()
    }
}


extension RYSquarePage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard dataManager.shareList.count > 0 else {
            return 0
        }
        return dataManager.shareList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard dataManager.shareList.count > 0 else {
            return UICollectionViewCell()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RYSquareCell", for: indexPath)
        if let cell = cell as? RYSquareCell, indexPath.row < dataManager.shareList.count {
            cell.update(dataManager.shareList[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard dataManager.shareList.count > 0 else { return }
        guard indexPath.row < dataManager.shareList.count else { return }
    
        // go to the dishDetailsPage
        if let dishDetailsPage = UIStoryboard.dishStoryboard_dishDetailsPage() {
            dishDetailsPage.dishID = dataManager.shareList[indexPath.item].iD
            dishDetailsPage.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(dishDetailsPage, animated: true)
        }
    }
    
    // MARK: - Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width-Constants.kRYEdgeInset_horizontal*3) / 2, height: (Constants.kRYHeightForItem - Constants.kRYEdgeInset_vertical*2 - Constants.kRYEdgeInset_horizontal)/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: Constants.kRYEdgeInset_vertical, left: Constants.kRYEdgeInset_horizontal, bottom: Constants.kRYEdgeInset_vertical, right: Constants.kRYEdgeInset_horizontal)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.kRYEdgeInset_horizontal
    }
    
    
}

extension RYSquarePage: RYDataManagerDelegate {
    // MARK: - RYDataManagerDelegate
    func ryDataManagerAPI(_ dataManager: RYBaseDataManager) -> String? {
        guard let api = RYAPICenter.api_squareShare(pageIndex).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ""
        }
        return api
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, success: Any?, itemRetrived: Any?) {
        DispatchQueue.main.async {
            if self.dataManager.shareList.count > 0 {
                self.sectionList.removeAll()
                self.sectionList.append(.cookingExperience)
            }
            self.collectionView.reloadData()
        }
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, failure: Error?) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, status: eRYDataListLoadingType) {
        // handle loading status
        switch status {
        case .none: // success
            collectionView.showFooterActivityIndicator(for: status)
            
        case .loading:
            collectionView.showFooterActivityIndicator(for: status)
            
        case .zeroData, .notReachable, .error:
            collectionView.showFooterActivityIndicator(for: status, description: "网络好像出错了") {[weak self] in
                self?.performDownloadData()
            }
        }
    }
}


extension RYSquarePage: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // two ways to load next page - 2st: pull to refresh
        let distance = scrollView.contentSize.height - scrollView.bounds.height
        if distance > 0 && scrollView.contentOffset.y > distance + Constants.kRYScrollToRefreshLength {
            // TODO: request api for dish list
            pageIndex += 1
            performDownloadData()
        }
    }
}
