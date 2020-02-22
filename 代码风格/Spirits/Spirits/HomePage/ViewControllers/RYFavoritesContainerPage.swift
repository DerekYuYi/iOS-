//
//  RYFavoritesContainerPage.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/11.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYFavoritesContainerPage: RYBasedViewController {
    
    private struct Constants {
        static let types = [RYTypeItem(id: 1, name: "妙招"),
                            RYTypeItem(id: 2, name: "生活"),
                            RYTypeItem(id: 3, name: "健康"),
                            RYTypeItem(id: 4, name: "饮食")]
        static let navTitle = "收藏夹"
        static let typeCollectionCellIdentifier = String(describing: RYFavoritesTopTypeCell.self)
        static let widthForTopTypeCell: CGFloat = 66
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    // MARK: - Properties
    private var selectedIndex: Int = 0 // default selected index is 0.
    
    /// Record if child pages has initial and loaded.
    private var indexRecoder = RYIndexRecorder()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Constants.navTitle
        
        setupCollectionView()
        setupScrollView()
        
        DispatchQueue.main.async {
            self.loadItemPage(at: 0)
        }
        
        // Do any additional setup after loading the view.
    }
    
}

// MARK: - Setup

extension RYFavoritesContainerPage {
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(UINib(nibName: Constants.typeCollectionCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Constants.typeCollectionCellIdentifier)
    }
    
    private func setupScrollView() {
        
        contentScrollView.delegate = self
        contentScrollView.isPagingEnabled = true
        if #available(iOS 11.0, *) {
            contentScrollView.backgroundColor = UIColor(named: "Color_f1f8f9")
        } else {
            contentScrollView.backgroundColor = RYColors.color(from: 0xF1F8F9)
        }
        
        contentScrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(Constants.types.count), height: 1) // 1 for scrollview can only scroll horizontally.
    }
    
}


// MARK: - Load sub pages

extension RYFavoritesContainerPage {
    
    /// Specify index and load index page
    private func loadItemPage(at index: Int) {
        guard index < Constants.types.count else { return }
        
        // 0. Update current selected index value
        selectedIndex = index
        
        // 1. Check to see if the page at index exists. Creates a new item firstly if there is not exist.
        if !hasExistPage(at: index) {
            produceItemPage(at: index)
        }
        
        // 2. Scroll to index area
        let point = CGPoint(x: contentScrollView.bounds.width * CGFloat(index), y: 0)
        contentScrollView.scrollRectToVisible(CGRect(x: point.x, y: point.y, width: contentScrollView.bounds.width, height: contentScrollView.bounds.height), animated: false)
        //        containerScrollview.setContentOffset(point, animated: true) // method 2 for scroll to next page
        
        // 3. Reload flag title in flag collection view
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    /// New a item page and add it's view to scrollView
    private func produceItemPage(at index: Int) {
        guard index < Constants.types.count else { return }
        
        let mainStoryboard = UIStoryboard(storyboard: .Main)
        let itemPage: RYFavoritesPage = mainStoryboard.instantiateViewController()
        
        if index < Constants.types.count {
            itemPage.typeItem = Constants.types[index]
        }
        
        self.addChild(itemPage)
        itemPage.didMove(toParent: self)
        contentScrollView.addSubview(itemPage.view)
        itemPage.view.frame = CGRect(x: contentScrollView.bounds.width * CGFloat(index), y: 0, width: contentScrollView.bounds.width, height: contentScrollView.bounds.height)
        
        // record
        indexRecoder.recordIndex(at: index)
    }
    
    /// Makes a adjustment whether has existed page that will show
    private func hasExistPage(at index: Int) -> Bool {
        return indexRecoder.isContainedIndex(at: index)
    }
}

// MARK: - UICollectionViewDelegate && UICollectionViewDataSource

extension RYFavoritesContainerPage: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard Constants.types.count > 0 else { return 0 }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard Constants.types.count > 0 else { return 0 }
        return Constants.types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.typeCollectionCellIdentifier, for: indexPath)
        if let cell = cell as? RYFavoritesTopTypeCell, indexPath.row < Constants.types.count {
            cell.update(Constants.types[indexPath.row].name, isSelected: indexPath.row == selectedIndex)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        DispatchQueue.main.async {
            self.loadItemPage(at: indexPath.item)
        }
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RYFavoritesContainerPage: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard Constants.types.count > 0 else {
            return CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude)
        }
//        let width = collectionView.bounds.width / CGFloat(Constants.types.count)
        let width = Constants.widthForTopTypeCell
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}


// MARK: - UIScrollViewDelegate

extension RYFavoritesContainerPage: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == contentScrollView else {
            return
        }
        // step1
        if !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating {
            scrollviewDidEndScroll(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == contentScrollView else {
            return
        }
        // step2
        if !decelerate {
            scrollviewDidEndScroll(scrollView)
        }
    }
    
    private func scrollviewDidEndScroll(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        DispatchQueue.main.async {
            self.loadItemPage(at: index)
        }
        
    }
}

