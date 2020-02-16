//
//  RYHomePage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/8.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit

enum eRYHPSectionType {
    case topAds, banner, cookingSkill, cookingExperience, hot, lastest, bottomAds
}

class RYHomePage: RYBaseViewController, RYSearchViewBulterDelegate {
    
    private struct Constants {
        static let kRYHeightForSectionCookingSkill: CGFloat = 44
        static let kRYHeightForSectionCookingShare: CGFloat = kRYHeightForSectionCookingSkill
        static let kRYHeightForHeaderView: CGFloat = 44
        static let topAdsRatio: CGFloat = 640.0 / 60.0
        static let bottomAdsRatio: CGFloat = 700.0 / 280.0
        
        static let kRYTitleForCookingSkill = "烹饪技巧"
        static let kRYTitleForCookingExperience = "厨艺分享"
        static let kRYTitleForHot = "热门菜谱"
        static let kRYTitleForLastest = "最新菜谱"
        
        static let identifierForAdsCell = String(describing: RYAdsCell.self)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var titleBarButtonItem: UIBarButtonItem!
    
    // MARK: - Properties
    private let searchVC = UISearchController(searchResultsController: nil)
    private var searchViewBulter: RYSearchViewBulter?
    
    // Hold banner cell for starting scroll banners when pop from other pages and stopping scroll banners when banner cell is not visible cell.
    private var bannerCell: RYHPBannerCell?
    
    private var sectionList: [eRYHPSectionType] = []
    private var dataManager = RYHPDataManager(nil)
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYHomePage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYHomePage()
    }
    
    func setup_RYHomePage() {
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Authorization notification
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let _ = RYLocalNotificationManager(appDelegate)
        }
        
        // tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.register(UINib(nibName: "RYDishItemCell", bundle: nil), forCellReuseIdentifier: "RYDishItemCell")
        tableView.register(UINib(nibName: Constants.identifierForAdsCell, bundle: nil), forCellReuseIdentifier: Constants.identifierForAdsCell)
        
        // search bulter view
        searchViewBulter = RYSearchViewBulter(self, searchController: searchVC)
        searchViewBulter?.delegate = self
    
        // API
        dataManager = RYHPDataManager(self)
        performDownloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let bannerCell = self.bannerCell else { return }
        bannerCell.startShowBannersAlternately()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    private func performDownloadData() {
        sectionList = []
        dataManager.cleanData()
        dataManager.ryPerformDownloadData()
    }
    
    deinit {
        tableView?.delegate = nil // optional `?` for preventing crash
    }
    
    // MARK: - RYSearchViewBulterDelegate
    func viewBulter(_ viewBulter: RYSearchViewBulter?, selectedResultItem at: Any) {
        
    }
}

// MARK: - UITableViewDelegate
extension RYHomePage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard sectionList.count > 0, section < sectionList.count else {
            return CGFloat.leastNormalMagnitude
        }
        
        let sectionType = sectionList[section]
        switch sectionType {
        case .banner, .topAds, .bottomAds:
            return CGFloat.leastNormalMagnitude
        
        case .cookingSkill, .cookingExperience, .hot, .lastest:
            return Constants.kRYHeightForHeaderView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dataManager.hasValidData() else { return 0 }
        
        let sectionType = sectionList[section]
        switch sectionType {
        case .banner, .cookingSkill, .cookingExperience, .topAds, .bottomAds:
            return 1
            
        case .hot:
            guard let hotRecipes = dataManager.hotRecipes, hotRecipes.count > 0 else {
                return 0
            }
            return hotRecipes.count
            
        case .lastest:
            guard let lastestRecipes = dataManager.lastestRecipes, lastestRecipes.count > 0 else {
                return 0
            }
            return lastestRecipes.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard sectionList.count > 0, indexPath.section < sectionList.count else {
            return CGFloat.leastNormalMagnitude
        }
        
        let sectionType = sectionList[indexPath.section]
        switch sectionType {
        case .banner:
            return UIScreen.main.bounds.width / 2
            
        case .cookingSkill:
            return 264.0
            
        case .cookingExperience:
            return 546.0
            
        case .hot:
            return 130
            
        case .lastest:
            return 130
            
        case .topAds:
            return tableView.bounds.width / Constants.topAdsRatio
         
        case .bottomAds:
            return tableView.bounds.width / Constants.bottomAdsRatio
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard sectionList.count > 0, indexPath.section < sectionList.count else {
            return UITableViewCell() // TODO: - Need to be refactor!!!
        }
        let sectionType = sectionList[indexPath.section]
        switch sectionType {
        case .banner:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYHPBannerCell", for: indexPath)
            if let cell = cell as? RYHPBannerCell, let banners = dataManager.banners {
                cell.update(banners)
                cell.delegate = self
                
                bannerCell = cell
            }
            return cell
            
        case .cookingSkill:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYHPSkillCell", for: indexPath)
            if let cell = cell as? RYHPSkillCell, let skills = dataManager.skills {
                cell.update(skills)
                cell.delegate = self
            }
            return cell
            
        case .cookingExperience:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYHPExperienceCell", for: indexPath)
            if let cell = cell as? RYHPExperienceCell, let experiences = dataManager.experiences {
                cell.update(experiences)
                cell.delegate = self
            }
            return cell
            
        case .hot, .lastest:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYDishItemCell", for: indexPath)
            if let cell = cell as? RYDishItemCell {
                if let dishes = sectionType == .hot ? dataManager.hotRecipes : dataManager.lastestRecipes, dishes.count > 0, indexPath.row < dishes.count {
                    cell.update(dishes[indexPath.row])
                }
            }
            return cell
            
        case .topAds:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifierForAdsCell, for: indexPath)
            if let cell = cell as? RYAdsCell {
                cell.hiddenAdsDescription = true
                cell.delegate = self
                
                let data: [String: Any] = ["id": 10,
                            "description": "test ads",
                            "name": "问了么广告",
                            "click_url": "https://itunes.apple.com/us/app/you-yu-mei-shi/id1436818171?l=zh&ls=1&mt=8",
                            "origin": "大公司",
                            "resource": ["http://k.zol-img.com.cn/sjbbs/7692/a7691515_s.jpg"]]
                let item = RYAdvertisement(data)
                cell.update([item], type: .bannerTop)
            }
            return cell
            
        case .bottomAds:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifierForAdsCell, for: indexPath)
            if let cell = cell as? RYAdsCell {
                cell.delegate = self
                let data: [String: Any] = ["id": 10,
                                           "description": "test ads",
                                           "name": "问了么广告",
                                           "click_url": "https://itunes.apple.com/us/app/you-yu-mei-shi/id1436818171?l=zh&ls=1&mt=8",
                                           "origin": "大公司",
                                           "resource": ["http://k.zol-img.com.cn/sjbbs/7692/a7691515_s.jpg"]]
                let item = RYAdvertisement(data)
                cell.update([item], type: .bannerTop)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard sectionList.count > 0, indexPath.section < sectionList.count else { return }
        
        let sectionType = sectionList[indexPath.section]
        guard sectionType == .banner else { return }
        
        if let bannerCell = self.bannerCell {
            bannerCell.endShowBannersAlternately()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard sectionList.count > 0, section < sectionList.count else {
            return nil
        }
        
        let sectionType = sectionList[section]
        switch sectionType {
        case .banner, .topAds, .bottomAds:
            return nil
            
        case .cookingSkill, .cookingExperience, .hot, .lastest:
            // TODO: - Need to be refactor!!!
            if let views = Bundle.main.loadNibNamed("RYHPHeaderView", owner: nil, options: nil),
                let headerView = views.first as? RYHPHeaderView {
                headerView.backgroundColor = nil
                var title = Constants.kRYTitleForCookingSkill
                headerView.enableMoreButton(false)
                
                if sectionType == .cookingExperience {
                    title = Constants.kRYTitleForCookingExperience
                    headerView.delegate = self
                    headerView.enableMoreButton(true)
                    
                } else if sectionType == .hot {
                    title = Constants.kRYTitleForHot
                    headerView.delegate = self
                    headerView.enableMoreButton(true)
                    if !RYUserDefaultCenter.hasShownHotReceiptBadge() {
                        headerView.showBadgeView(true)
                    }
                    
                } else if sectionType == .lastest {
                    title = Constants.kRYTitleForLastest
                    headerView.delegate = self
                    headerView.enableMoreButton(true)
                    if !RYUserDefaultCenter.hasShownLastestReceiptBadge() {
                        headerView.showBadgeView(true)
                    }
                }
                
                headerView.enableClearButton(false)
                headerView.update(title)
                headerView.sectionType = sectionType
                
                return headerView
            }
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard sectionList.count > 0, indexPath.section < sectionList.count else {
            return
        }
        
        let sectionType = sectionList[indexPath.section]
        guard sectionType == .hot || sectionType == .lastest else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        // go to dishDetailsPage
        if let dishes = sectionType == .hot ? dataManager.hotRecipes : dataManager.lastestRecipes, dishes.count > 0, indexPath.row < dishes.count {
            if let dishID = dishes[indexPath.row].id {
                 gotoDishDetailsPage(dishID)
            }
        }
    }
}

// MARK: - CellDelegates
extension RYHomePage: RYHPBannerCellDelegate, RYHPSkillCellDelegate, RYHPExperienceCellDelegate {
    
    func bannerCell(_ cell: RYHPBannerCell?, didSelectItemAt bannerID: Int) {
        gotoDishDetailsPage(bannerID)
    }
    
    func skillCell(_ cell: RYHPSkillCell?, didSelectItemAt skillID: Int) {
        if let skillDetailsPage = UIStoryboard.skillStoryboard_skillDetailsPage() {
            skillDetailsPage.skillID = skillID
            skillDetailsPage.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(skillDetailsPage, animated: true)
        }
    }
    
    func experienceCell(_ cell: RYHPExperienceCell?, didSelectItemAt dishID: Int) {
        gotoDishDetailsPage(dishID)
    }
    
    private func gotoDishDetailsPage(_ dishID: Int) {
        if let dishDetailsPage = UIStoryboard.dishStoryboard_dishDetailsPage() {
            dishDetailsPage.dishID = dishID
            dishDetailsPage.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(dishDetailsPage, animated: true)
        }
    }
}

// MARK: - RYAdsViewDelegate

extension RYHomePage: RYAdsCellDelegate {
    
    func closeAds(for type: eRYAdsType) {
        
    }
    
    func didSelectAd(at advertiment: RYAdvertisement) {
        
    }
}

// MARK: - HeaderViewDelegate
extension RYHomePage: RYHPHeaderViewDelegate {
    func headerView(_ headerView: RYHPHeaderView, moreButtonTapped: UIButton) {
        guard let sectionType = headerView.sectionType else { return }
        switch sectionType {
        case .cookingExperience:
            gotoSquarePage()
            
        case .hot:
            gotoDishList(by: "家常菜", listTitle: "热门菜谱")
            if !RYUserDefaultCenter.hasShownHotReceiptBadge() {
                RYUserDefaultCenter.hotReceiptBadgeShown()
                headerView.showBadgeView(false)
            }
            
        case .lastest:
            gotoDishList(by: "早餐", listTitle: "最新菜谱")
            if !RYUserDefaultCenter.hasShownLastestReceiptBadge() {
                RYUserDefaultCenter.lastestReceiptBadgeShown()
                headerView.showBadgeView(false)
            }
            
        default:
            break
        }
    }
    
    private func gotoSquarePage() {
        if let squarePage = UIStoryboard.squareStoryboard_squarePage() {
            squarePage.navTitle = "厨艺分享"
            squarePage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(squarePage, animated: true)
        }
    }
    
    private func gotoDishList(by keyword: String, listTitle title: String) {
        if let dishPage = UIStoryboard.dishStoryboard_dishPage() {
            // assign values for dishpage's setup
            dishPage.searchKeywords = keyword
            dishPage.title = title
            dishPage.showLargeTitle = true
            dishPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(dishPage, animated: true)
        }
    }
    
}

// MARK: - RYDataManagerDelegate
extension RYHomePage: RYDataManagerDelegate {
    func ryDataManagerAPI(_ dataManager: RYBaseDataManager) -> String? {
        guard let api = RYAPICenter.api_homePage().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ""
        }
        return api
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, success: Any?, itemRetrived: Any?) {
        DispatchQueue.main.async {
            
            // add top ads
            if RYAdsDataCenter.sharedInstance.isExistAds(for: .bannerTop) {
                self.sectionList.append(.topAds)
            }
            
            // TODO: - ************ Need Delete **************//
            self.sectionList.append(.topAds)
            
            // add content sections
            if let banners = self.dataManager.banners, banners.count > 0 {
                self.sectionList.append(.banner)
            }
            if let skills = self.dataManager.skills, skills.count > 0 {
                self.sectionList.append(.cookingSkill)
            }
            if let experiences = self.dataManager.experiences, experiences.count > 0 {
                self.sectionList.append(.cookingExperience)
            }
            if let hotRecipes = self.dataManager.hotRecipes, hotRecipes.count > 0 {
                self.sectionList.append(.hot)
            }
            if let lastestRecipes = self.dataManager.lastestRecipes, lastestRecipes.count > 0 {
                self.sectionList.append(.lastest)
            }
            
            // add bottom ads
            if RYAdsDataCenter.sharedInstance.isExistAds(for: .bannerBottom) {
                self.sectionList.append(.bottomAds)
            }
            self.sectionList.append(.bottomAds)
            
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
            tableView.showFooterActivityIndicator(for: status, description: "网络好像出错了") {[weak self] in
                self?.performDownloadData()
            }
        }
    }
}

