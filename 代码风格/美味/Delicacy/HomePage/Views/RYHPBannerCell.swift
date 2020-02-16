//
//  RYHPBannerCell.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/10.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

/*
   Abstract:
     If origin data structure is: [element0, element1, element2, element3],
     then the shown data structure is: [element3, element0, element1, element2, element3, element0]
 */

import UIKit

protocol RYHPBannerCellDelegate: NSObjectProtocol {
    func bannerCell(_ cell: RYHPBannerCell?, didSelectItemAt bannerID: Int)
}

class RYHPBannerCell: UITableViewCell {
    
    private struct Constants {
        static let gap: CGFloat = 10
        static let scrollDurationTimeInterval: TimeInterval = 5.0
    }
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Properties
    weak var delegate: RYHPBannerCellDelegate?
    
    // related indexs when scroll
    private var lastIndex: Int = 0
    private var currentIndex: Int = 0 {
        didSet {
            guard let banners = banners else {
                return
            }
            if currentIndex == 0 { // go to the last count
                pageControl.currentPage = banners.count - 2
            } else if currentIndex == banners.count - 1 {
                pageControl.currentPage = 0
            } else { // go to the first count
                pageControl.currentPage = currentIndex - 1
            }
        }
    }
    
    private var isAwakeFromNib = true // Indicates that whether the cell is awake from nib or reuse from identifier.
    
    private var isScrollAlternately = false
    
    var banners: [RYBanner]? {
        didSet {
            DispatchQueue.main.async {
                // reload collectionView
                self.collectionView.reloadData()
                
                // start scroll banners
                self.startShowBannersAlternately()
                
                // scroll banner to index 1, but only once after awake from nib.
                if self.isAwakeFromNib {
                    // scroll to index 1 position
                    self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
                    self.lastIndex = 1
                    self.isAwakeFromNib = false
                }
            }
        }
    }
    
    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.backgroundColor = nil
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = RYColors.yellow_theme
    }
    
    /// Update DataSource
    func update(_ data: [RYBanner]) {
        
        // Enabled scroll automaticallly when count of banner more than two. Otherwise, disenabled it.
        if data.count >= 2 {
            var helperArray: [RYBanner] = []
            helperArray.append(data[data.count-1]) // the last element
            helperArray.append(contentsOf: data)
            helperArray.append(data[0]) // the first element
            banners = helperArray
            
        } else {
            banners = data
        }
        
        pageControl.numberOfPages = data.count
    }
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        // go to selected indexpage
    }
}


extension RYHPBannerCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Delegate && Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let banners = banners, banners.count > 0 else {
            return 0
        }
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RYBannerCollectionCell", for: indexPath)
        if let cell = cell as? RYBannerCollectionCell, let banners = banners, indexPath.row < banners.count {
            cell.update(banners[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let banners = banners, indexPath.row < banners.count else { return }
        if let bannerID = banners[indexPath.row].iD {
            collectionView.deselectItem(at: indexPath, animated: true)
            delegate?.bannerCell(self, didSelectItemAt: bannerID)
        }
        
        // end scrolling item
        endShowBannersAlternately()
    }
    
    // MARK: - Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - Constants.gap * 2, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: Constants.gap, bottom: 0, right: Constants.gap)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.gap * 2
    }
}

// MARK: - UIScrollViewDelegate
extension RYHPBannerCell: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // end auto-scroll when users will begin scroll manually
        endShowBannersAlternately()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScroll(scrollView)
        }
    }
 
    // Handle manual-scroll Logic here
    private func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        guard let banners = banners else { return }
        
        defer {
            // start auto-scroll when did end scroll manually
            startShowBannersAlternately()
        }
        
        currentIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        // exit when not scroll to new index
        if currentIndex == lastIndex {
            return
        }
        
        // scroll to new index
        if currentIndex > lastIndex { // direction is right
            DispatchQueue.main.async {
                if self.currentIndex == banners.count - 1  {
                    // scroll to the first item in origin data (index is 1)
                    self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
                    
                    self.lastIndex = 1
                } else {
                    self.lastIndex = self.currentIndex
                }
            }
            
        } else { // direction is left
            DispatchQueue.main.async {
                if self.currentIndex == 0 {
                    // scroll to the last item in origin data (index is banners.count - 2)
                    self.collectionView.scrollToItem(at: IndexPath(item: banners.count - 2, section: 0), at: .centeredHorizontally, animated: false)
                    self.lastIndex = banners.count - 2
                } else {
                    self.lastIndex = self.currentIndex
                }
            }
        }
        return
    }
    
    /// Handle auto-scroll logic here
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let banners = banners else { return }
        
        DispatchQueue.main.async {
            if self.currentIndex == banners.count - 1  {
                // scroll to the first item in origin data (index is 1)
                self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
                self.currentIndex = 1
                self.lastIndex = 1
            } else {
                self.lastIndex = self.currentIndex
            }
        }
    }
}


// MARK: - Scroll Items Alternately
extension RYHPBannerCell {
    @objc private func scrollBannersAlternately() {
        guard let banners = banners, banners.count > 1 else { return }
        guard isScrollAlternately else { return }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(scrollBannersAlternately), object: nil)
        
        // update index
        if (currentIndex + 1) < banners.count {
            currentIndex += 1
        } else {
            currentIndex = 1
        }
        
        // exit when not scroll to new index
//        if currentIndex == lastIndex { return }
        
        // scroll to new index
        self.collectionView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: true)
 
        // perform alternately
        self.perform(#selector(scrollBannersAlternately), with: nil, afterDelay: Constants.scrollDurationTimeInterval)
    }
    
    func startShowBannersAlternately() {
        guard !isScrollAlternately else { return }
        isScrollAlternately = true
        self.perform(#selector(scrollBannersAlternately), with: nil, afterDelay: Constants.scrollDurationTimeInterval)
    }
    
    func endShowBannersAlternately() {
        guard isScrollAlternately else { return }
        isScrollAlternately = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(scrollBannersAlternately), object: nil)
    }
}

