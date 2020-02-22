//
//  RYCardsPool.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/3/26.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

class RYCardsPool: RYBasedViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var leftShadowView: RYShadowView!
    @IBOutlet weak var centerShadowView: RYShadowView!
    @IBOutlet weak var rightShadowView: RYShadowView!
    
    @IBOutlet weak var likeButton: RYLevelButton!
    @IBOutlet weak var publishButton: RYLevelButton!
    @IBOutlet weak var dislikeButton: RYLevelButton!
    @IBOutlet weak var reloadButton: UIButton!
    
    // MARK: - Properties
    
    /// Indicates type item that come in
    var typeDataItem: TypeDataItem?
    
    /// Show core swipe animations
    private var swipeViewBuffer = RYSwipeViewBuffer(nil)
    
    /// Manages data source request from service
    private var requestManager = RYTypeListRequestManager(nil)
    
    /// page number for paging when request list
    private var pageNumber: Int = 1
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 1. init UI
        title = typeDataItem?.title.name
        switch typeDataItem?.title.id {
        case 1:
            publishButton.setImage(UIImage(named: "airplane_red"), for: .normal)
            
        case 2:
            publishButton.setImage(UIImage(named: "airplane_green"), for: .normal)
            
        case 3:
            publishButton.setImage(UIImage(named: "airplane_blue"), for: .normal)
            
        case 4:
            publishButton.setImage(UIImage(named: "airplane_orange"), for: .normal)
        
        default:
            publishButton.setImage(UIImage(named: "airplane_orange"), for: .normal)
        }
        
        // 1.1. button setting
        reloadButton.roundedCorner()
        hiddenReloadButtons(true)
        hiddenBottomButtons(true)
        
        // 2. init swipeviewBuffer
        swipeViewBuffer = RYSwipeViewBuffer(self.view)
        swipeViewBuffer.delegate = self
        
        // 3. init request manager
        requestManager = RYTypeListRequestManager(self)
        
        // 4. start request
        requestTypeListAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // corners
        
        dislikeButton.roundedCorner(nil, dislikeButton.bounds.height / 2.0)
        publishButton.roundedCorner(nil, publishButton.bounds.height / 2.0)
        likeButton.roundedCorner(nil, likeButton.bounds.height / 2.0)
        
        // shadows
        
        leftShadowView.shadowColor = UIColor.black.withAlphaComponent(0.1)
        leftShadowView.cornerRadius = leftShadowView.bounds.height / 2.0
        leftShadowView.setupShadow(in: leftShadowView.bounds)
        
        centerShadowView.shadowColor = UIColor.black.withAlphaComponent(0.1)
        centerShadowView.cornerRadius = centerShadowView.bounds.height / 2.0
        centerShadowView.setupShadow(in: centerShadowView.bounds)
        
        rightShadowView.shadowColor = UIColor.black.withAlphaComponent(0.1)
        rightShadowView.cornerRadius = rightShadowView.bounds.height / 2.0
        rightShadowView.setupShadow(in: rightShadowView.bounds)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if traitCollection.userInterfaceStyle == .light {
                    leftShadowView.shadowColor = UIColor.black.withAlphaComponent(0.1)
                    centerShadowView.shadowColor = UIColor.black.withAlphaComponent(0.1)
                    rightShadowView.shadowColor = UIColor.black.withAlphaComponent(0.1)
                } else {
                    leftShadowView.shadowColor = UIColor.white
                    centerShadowView.shadowColor = UIColor.white
                    rightShadowView.shadowColor = UIColor.white
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // guide: publishButton
        if !RYUserDefaultCenter.hasShownCoachMarks(for: .publishButton) {
            DispatchQueue.main.async {
                _ = RYCoachManager.showGuide(for: [self.publishButton], hints: ["点击这里发布小妙招"], completion: { view in
                    // record shown for .publishButton
                    RYUserDefaultCenter.showCoachMarks(for: .publishButton)
                })
            }
            /*
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6, execute: {
                _ = RYCoachManager.showGuide(for: [self.publishButton], hints: ["点击这里发布小妙招"], completion: { view in
                    // record shown for .publishButton
                    RYUserDefaultCenter.showCoachMarks(for: .publishButton)
                })
            })
            */
        }
    }
    
    // MARK: - Actions
    
    @IBAction func dislikeButtonTapped(_ sender: RYLevelButton) {
        // left swipe action
        swipeViewBuffer.swipe(from: .left)
    }
    
    @IBAction func publishButtonTapped(_ sender: RYLevelButton) {
        let publishPage: RYPublishPage = UIStoryboard(storyboard: .Main).instantiateViewController()
        navigationController?.pushViewController(publishPage, animated: true)
    }
    
    @IBAction func likeButtonTapped(_ sender: RYLevelButton) {
        // right swipe action
        swipeViewBuffer.swipe(from: .right)
    }
    
    @IBAction func reloadButtonTapped(_ sender: UIButton) {
        hiddenReloadButtons(true)
        if requestManager.pagingEnabled(for: pageNumber+1) {
            pageNumber += 1
            requestTypeListAPI()
        } else {
            self.view.makeToast("该列表没有新的发布, 去别的列表看看", duration: 1.4, position: .center, title: "没有新的发布", completion: { _ in
                self.hiddenReloadButtons(false)
            })
        }
    }
    
    // MARK: - Request
    private func requestTypeListAPI() {
        guard let type = typeDataItem?.title.id else { return }
        
        // start loading animation when starts to requesting
        self.showLoadingView(true)
        
        // clean data before request
        requestManager.clearData()
        
        // request new data
        requestManager.performRequest(RYAPICenter.api_typesList(for: type, pageNumber: pageNumber), isNeedAuthorization: false)
    }
    
    // MARK: - Update SwipeBuffer
    private func updateSwipeBuffer() {
        self.swipeViewBuffer.update(requestManager.typeList, typeDataItem: typeDataItem)
    }
    
    // Hides bottom buttons except publish button.
    private func hiddenBottomButtons(_ isHidden: Bool) {
        likeButton.isHidden = isHidden
        rightShadowView.isHidden = likeButton.isHidden
        dislikeButton.isHidden = isHidden
        leftShadowView.isHidden = dislikeButton.isHidden
    }
    
    private func hiddenReloadButtons(_ isHidden: Bool) {
        reloadButton.isHidden = isHidden
    }
}


// MARK: - RYTypeListRequestManagerDelegate

extension RYCardsPool: RYTypeListRequestManagerDelegate {
    func requestStatus(_ requestManager: RYTypeListRequestManager, _ status: eRYRequestStatus) {
        
        DispatchQueue.main.async {
            switch status {
            case .success:
                // stop loading
                self.showLoadingView(false)
                
                // update cards
                self.updateSwipeBuffer()
                
                // show bottom buttons
                if requestManager.typeList.count > 0 {
                    self.hiddenBottomButtons(false)
                    self.hiddenReloadButtons(true)
                } else {
                    self.hiddenBottomButtons(true)
                    self.view.makeToast("该列表没有新的发布, 去别的列表看看", duration: 1.4, position: .center, title: "没有新的发布", completion: { _ in
                        self.hiddenReloadButtons(false)
                    })
                }
                
            case .failed:
                self.showLoadingView(false)
                self.hiddenReloadButtons(false)
                
            case .loading:
                self.showLoadingView(true)
            }
        }
    }
}

// MARK: - RYSwipeViewBufferDelegate

extension RYCardsPool: RYSwipeViewBufferDelegate {
    func swipedCard(_ cardId: Int, from direction: eRYSwipeDirection) {
        
        // direction guard
        guard direction == .right else { return }
        
        // request favorite api
        RYFavoritesRequester.requestFavoritesAPI(cardId)
    }
    
    func swipeCardEmptied() {
        hiddenBottomButtons(true)
        hiddenReloadButtons(false)
    }
    
    func enabledSwipe() -> Bool {
        view.hideAllToasts()
        // login guard
        guard RYProfileCenter.me.isLogined else {
            
            // go to login page
            view.makeToast("请先登录, 登录后收藏更多小妙招", duration: 1.2, position: .top) { _ in
                RYLoginPannel.presentLoginPannel(from: self)
            }
            
            return false
        }
        
        return true
    }
}
