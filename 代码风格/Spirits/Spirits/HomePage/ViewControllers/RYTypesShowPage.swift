//
//  RYTypesShowPage.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/8.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import Toast_Swift

typealias TypeDataItem = (imageName: String, title: RYTypeItem, startColor: UIColor, endColor: UIColor, shadowColor: UIColor)

class RYTypesShowPage: RYBasedViewController {
    
    fileprivate struct Constants {
        static let horizontalGap: CGFloat = 16
        static let verticalGap: CGFloat = 20
        static let ratio: CGFloat = 4.0 / 3.0
        static let topAdsRatio: CGFloat = 640.0 / 60.0
        static let bottomAdsRatio: CGFloat = 700.0 / 280.0
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var profileBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var filterBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewTopConstant: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstant: NSLayoutConstraint!
    
    // MARK: - Properties

    var dataSources: [TypeDataItem] {
        var data: [TypeDataItem] = []
        
        if let indexes = RYUserDefaultCenter.hasRecordedIndex(), indexes.count > 0 {
            
            // NOTE: Enum is more clear way to show types.
            if indexes.contains(0) {
                data.append(("light",
                             RYTypeItem(id: 1, name: "妙招"),
                             RYColors.color(from: 0xFF5E6D),
                             RYColors.color(from: 0xFF98D3),
                             RYColors.color(from: 0xFF5E6D)))
            }
            
            if indexes.contains(1) {
                data.append(("seedling",
                             RYTypeItem(id: 2, name: "生活"),
                             RYColors.color(from: 0x11998E),
                             RYColors.color(from: 0x38EF7D),
                             RYColors.color(from: 0x2BD183)))
            }
            
            if indexes.contains(2) {
                data.append(("heart",
                             RYTypeItem(id: 3, name: "健康"),
                             RYColors.color(from: 0x2F80ED),
                             RYColors.color(from: 0x56CCF2),
                             RYColors.color(from: 0x3183ED)))
            }
            
            if indexes.contains(3) {
                data.append(("bowls",
                             RYTypeItem(id: 4, name: "饮食"),
                             RYColors.color(from: 0xFC4A1A),
                             RYColors.color(from: 0xF7B733),
                             RYColors.color(from: 0xFB501B)))
            }
            
        } else {
            // There is a type `妙招` if user has no selected type.
            data.append(("light",
                         RYTypeItem(id: 1, name: "妙招"),
                         RYColors.color(from: 0xFF5E6D),
                         RYColors.color(from: 0xFF98D3),
                         RYColors.color(from: 0xFF5E6D)))
        }
        return data
    }
    
    // ad's views
    
    private var topAdsView: RYAdsView?
    private var bottomAdsView: RYAdsView?
    
    /// Hold an instance of RYTypeCell class to show guide when user open the current page for the first time.
    private var guideCell: RYTypeCell?
    
    fileprivate var maskWindow: UIWindow?
    
    /// - note: filterbutton is for guide. Because of 'RYCoachMarksView' only guides the instances of UIView, so i supply customview for right bar button item and guides the customView.
    fileprivate lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "filter")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // config toast style. because of this is the home page, so `configToastStyle()` will invoked once when application is active.
        configToastStyle()
        
        // config barbuttonitems
        profileBarButtonItem.image = UIImage(named: "person")?.withRenderingMode(.alwaysOriginal)
        filterBarButtonItem.customView = filterButton
        
        title = "助手库"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never
        }
        
        // config collectionview
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        // config ads
        loadAdsView()
        
        // prepare for guides
        prepareForGuides()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // show top/bottom ads
        DispatchQueue.main.async {
            self.showAds(at: .bannerTop, isShow: true)
            self.showAds(at: .bannerBottom, isShow: true)
        }
    }
    
    // MARK: - Guides
    
    private func prepareForGuides() {
        guard !RYUserDefaultCenter.hasShownCoachMarks(for: .typeCell) else { return }
        
        // There are guides above mainwindow and notification alert view when first open the app
        let maskWindow = UIWindow(frame: UIScreen.main.bounds)
        maskWindow.backgroundColor = .clear
        self.maskWindow = maskWindow
        let maskView = UIView(frame: maskWindow.bounds)
        maskView.backgroundColor = .clear
        maskWindow.addSubview(maskView)
        maskWindow.windowLevel = UIWindow.Level.alert
        maskWindow.makeKeyAndVisible()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(maskViewTapped))
        maskView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func maskViewTapped(_ tap: UITapGestureRecognizer) {
        if let view = tap.view {
            view.removeFromSuperview()
            maskWindow?.resignKey()
            maskWindow = nil
        }
        fireGuides()
    }
    
    private func fireGuides() {
        // guide 1: guidecell
        if !RYUserDefaultCenter.hasShownCoachMarks(for: .typeCell) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                if let guideCell = self.guideCell {
                    _ = RYCoachManager.showGuide(for: [guideCell], hints: ["这是“妙招”分类"]) { view in
                        
                        // record shown for .typeCell
                        RYUserDefaultCenter.showCoachMarks(for: .typeCell)
                        
                        // guide 2: filter button
                        if !RYUserDefaultCenter.hasShownCoachMarks(for: .filterButton) {
                            if let imageView = self.filterButton.imageView {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                                    _ = RYCoachManager.showGuide(for: [imageView], hints: ["点击发现更多模块"], completion: { view in
                                        // record shown for .filterButton
                                        RYUserDefaultCenter.showCoachMarks(for: .filterButton)
                                    })
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func profileBarButtonItemTapped(_ sender: UIBarButtonItem) {
        let peferencesPage: RYPreferencesPage = UIStoryboard(storyboard: .Main).instantiateViewController()
        peferencesPage.pageType = .Preference
        peferencesPage.navTitle = "个人中心"
        navigationController?.pushViewController(peferencesPage, animated: true)
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        let peferencesPage: RYPreferencesPage = UIStoryboard(storyboard: .Main).instantiateViewController()
        peferencesPage.pageType = .Filter
        peferencesPage.navTitle = "模块筛选"
        navigationController?.pushViewController(peferencesPage, animated: true)
    }
    
    // MARK: - Refresh ads view
    func loadAdsView() {
        DispatchQueue.main.async {
            self.updateAdsView(at: .bannerTop)
            self.updateAdsView(at: .bannerBottom)
        }
    }
    
    /// Update ads views when add or delete ads by user.
    private func updateAdsView(at type: eRYAdsType) {
        guard RYAdsDataCenter.sharedInstance.isExistAds(for: type) else { return }
        guard let data = RYAdsDataCenter.sharedInstance.adsDict[type.covertString()], data.count > 0 else { return }
        
        switch type {
            
        case .bannerTop:
            
            if let topAdsView = topAdsView {
                topAdsView.update(data, type: .bannerTop)
            } else {
                if let topAdsView = RYAdsView.loadFromNib() {
                    topAdsView.frame = .zero
                    view.addSubview(topAdsView)
                    topAdsView.hiddenAdsDescription = true
                    topAdsView.delegate = self
                    self.topAdsView = topAdsView
                    topAdsView.update(data, type: .bannerTop)
                }
            }
            
        case .bannerBottom:
            
            if let bottomAdsView = bottomAdsView {
                bottomAdsView.update(data, type: .bannerBottom)
            } else {
                if let bottomAdsView = RYAdsView.loadFromNib() {
                    bottomAdsView.frame = .zero
                    view.addSubview(bottomAdsView)
                    bottomAdsView.delegate = self
                    self.bottomAdsView = bottomAdsView
                    bottomAdsView.update(data, type: .bannerBottom)
                }
            }
            
        default:
            break
        }
    }
    
    /// show top ads and bottom ads
    private func showAds(at type: eRYAdsType, isShow: Bool) {
        
        let width = view.bounds.width
        let height = view.bounds.height
        
        switch type {
        case .bannerTop:
            guard let topAdsView = self.topAdsView else { return }
            
            let topAdsHeight = width / Constants.topAdsRatio
            
            if isShow {
                
                topAdsView.frame = CGRect(x: 0, y: RYFormatter.navigationBarPlusStatusBarHeight(for: self), width: width, height: 0)
                
                UIView.animate(withDuration: 1.0, animations: {
                    topAdsView.frame = topAdsView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -topAdsHeight, right: 0))
                    self.collectionViewTopConstant.constant = topAdsHeight
                    self.collectionView.layoutIfNeeded()
                })
                
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    topAdsView.frame = CGRect(x: 0, y: RYFormatter.navigationBarPlusStatusBarHeight(for: self), width: width, height: 0)
                    
                }) { _ in
                    
                    self.collectionViewTopConstant.constant = 0
                    self.collectionView.layoutIfNeeded()
                    
                    self.topAdsView?.removeFromSuperview()
                    self.topAdsView?.delegate = nil
                    self.topAdsView = nil
                }
            }
            
        case .bannerBottom:
            
            guard let bottomAdsView = self.bottomAdsView else { return }
            
            let bottomAdHeight = width / Constants.bottomAdsRatio
            
            if isShow {
                
                bottomAdsView.frame = CGRect(x: 0, y: height - bottomAdHeight, width: width, height: 0)
                UIView.animate(withDuration: 0.5, animations: {
                    bottomAdsView.frame = CGRect(x: 0, y: height - bottomAdHeight, width: width, height: bottomAdHeight)
                    self.collectionViewBottomConstant.constant = bottomAdHeight
                    self.collectionView.layoutIfNeeded()
                })
                
            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    bottomAdsView.frame = CGRect(x: 0, y: height, width: 0, height: 0)
                    
                }) { _ in
                    
                    self.collectionViewBottomConstant.constant = 0
                    self.collectionView.layoutIfNeeded()
                    
                    self.bottomAdsView?.removeFromSuperview()
                    self.bottomAdsView?.delegate = nil
                    self.bottomAdsView = nil
                }
            }

        default:
            break
        }
    }
    
}


// MARK: - UICollectionViewDataSource

extension RYTypesShowPage: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RYTypeCell.self), for: indexPath)
        
        if let cell = cell as? RYTypeCell, indexPath.item < dataSources.count {
            let data = dataSources[indexPath.item]
            cell.updateData(data)
            if data.title.id == 1 { // Guide '妙招' item
                guideCell = cell
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension RYTypesShowPage: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let cardPoolPage: RYCardsPool = UIStoryboard(storyboard: .Main).instantiateViewController()
        if indexPath.item < dataSources.count {
            cardPoolPage.typeDataItem = dataSources[indexPath.item]
        }
        navigationController?.pushViewController(cardPoolPage, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RYTypesShowPage: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.bounds.width - Constants.horizontalGap * 3) / 2
        let height: CGFloat = width * Constants.ratio
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: Constants.verticalGap, left: Constants.horizontalGap, bottom: Constants.verticalGap, right: Constants.horizontalGap)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.horizontalGap
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.verticalGap
    }
}

// MARK: - RYAdsViewDelegate

extension RYTypesShowPage: RYAdsViewDelegate {
    
    func closeAds(for type: eRYAdsType) {
        switch type {
        case .bannerTop:
            showAds(at: .bannerTop, isShow: false)
            
        case .bannerBottom:
            showAds(at: .bannerBottom, isShow: false)
            
        default:
            break
        }
    }
    
    func didSelectAd(at advertiment: RYAdvertisement) {
        if let clickUrlString = advertiment.click_url {
            RYWebPage.showWebPage(clickUrlString, webTitle: "", fromVC: self)
        }
    }

}


// MARK: - Toast configs

extension RYTypesShowPage {
    
    fileprivate func configToastStyle() {
        ToastManager.shared.style.cornerRadius = 5.0
        if let font = UIFont(name: "PingFangSC-Semibold", size: 16.0) {
            ToastManager.shared.style.titleFont = font
        }
        
        ToastManager.shared.style.messageColor = .black
        ToastManager.shared.style.titleAlignment = .center
        ToastManager.shared.style.messageAlignment = .center
        ToastManager.shared.style.activityBackgroundColor = UIColor.black.withAlphaComponent(0.25)
        
        configForUserInterfaceStyle()
    }
    
    fileprivate func configForUserInterfaceStyle() {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                ToastManager.shared.style.backgroundColor = .groupTableViewBackground
                ToastManager.shared.style.titleColor = .black
                ToastManager.shared.style.messageColor = .black
            } else {
                ToastManager.shared.style.backgroundColor = .lightGray
                ToastManager.shared.style.titleColor = .white
                ToastManager.shared.style.messageColor = .white
            }
        } else {
            ToastManager.shared.style.backgroundColor = .groupTableViewBackground
            ToastManager.shared.style.titleColor = .black
            ToastManager.shared.style.messageColor = .black
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                configForUserInterfaceStyle()
            }
        }
    }
}

