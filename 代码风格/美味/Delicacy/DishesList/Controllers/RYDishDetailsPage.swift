//
//  RYDishDetailsPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/10/19.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire

private enum eRYDishDetailsSectionType {
    case brief, ingredient, step
}

class RYDishDetailsPage: RYBaseViewController, RYNavigationStyleShadow {
    
    // MARK: - Outlets
    @IBOutlet var shareBarButtonItem: UIBarButtonItem!
    @IBOutlet var deSelectedBarButtonItem: UIBarButtonItem!
    @IBOutlet var selectedBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var dishID: Int?
    var isFromSearchResultList = false
    var isFromFavoriteList = false
    
    private var headerImageView: UIImageView? = nil
    private var dataManager = RYDishDetailsDataManager(nil)
    private var sectionList: [eRYDishDetailsSectionType] = []
    private var isPresentTitle = false
    
    lazy var heightForNavBarPlusStatusBar: CGFloat = {
        return RYFormatter.navigationBarPlusStatusBarHeight(for: self)
    }()
    
    private var originCollectionValue: Bool?
    
    private var isCollection: Bool = false {
        didSet {
            if isFromFavoriteList {
                self.navigationItem.rightBarButtonItems = [self.shareBarButtonItem]
            } else {
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItems = self.isCollection ? [self.shareBarButtonItem, self.selectedBarButtonItem] : [self.shareBarButtonItem, self.deSelectedBarButtonItem]
                }
            }
            
        }
    }
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYDishDetailsPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYDishDetailsPage()
    }
    
    private func setup_RYDishDetailsPage() {
        sectionList = [.brief, .ingredient, .step]
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedBarButtonItem.image = UIImage(named: "collect_orange")?.withRenderingMode(.alwaysOriginal)
        self.deSelectedBarButtonItem.image = UIImage(named: "collect_gray")?.withRenderingMode(.alwaysOriginal)
        
        // Do any additional setup after loading the view.
        // setup tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        setupHeaderViewForTableView()
        setupScaleImageView()
        
        // setup bar button items
        if isFromSearchResultList {
            let popBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav_white"), style: .plain, target: self, action: #selector(popBarButtonItemTapped))
            popBarButtonItem.tintColor = .white
            navigationItem.leftBarButtonItems = [popBarButtonItem]
        }
        
        // request data
        dataManager = RYDishDetailsDataManager(self)
        performDownloadData()
    }
    
    private func setupHeaderViewForTableView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20))
        view.backgroundColor = nil
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        path.addClip()
        
        let layer = CAShapeLayer()
        
        layer.frame = view.bounds
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        layer.strokeColor = UIColor.white.cgColor
        
        view.layer.addSublayer(layer)
        
        tableView.tableHeaderView = view
    }
    
    private func setupScaleImageView() {
        let height = tableView.bounds.width / kRYHeaderImageViewRatio
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        imageView.backgroundColor = RYColors.gray_imageViewBg
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: -height, width: tableView.bounds.width, height: height+10) // NOTE: 10 is for showing the header view of 1st section in tableview.
        
        tableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        
        tableView.addSubview(imageView)
        tableView.insertSubview(imageView, at: 0)
        self.headerImageView = imageView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    
        guard let headerImageView = self.headerImageView else { return }
        let height = tableView.bounds.width / kRYHeaderImageViewRatio
        /*
        headerImageView.snp.makeConstraints { maker in
            maker.width.equalTo(self.tableView.bounds.width)
            maker.height.equalTo(height+10)
            maker.bottom.equalTo(self.tableView).offset(10)
            maker.left.equalTo(self.tableView)
        }
        */
        headerImageView.frame = CGRect(x: 0, y: -height, width: tableView.bounds.width, height: height+10)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // record favorite recipe if possible
        updateFavoriteRecipesList(dishID)
    }
    
    private func performDownloadData() {
        dataManager.cleanData()
        dataManager.ryPerformDownloadData()
    }
    
    deinit {
        tableView?.delegate = nil
    }
    
    // MARK: - StatusBarStyle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func setNeedsStatusBarAppearanceUpdate() {
        super.setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Touch events
    @objc func popBarButtonItemTapped() {
        if isFromSearchResultList {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .fade
            transition.subtype = .fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: .default)
            if let window = view.window {
                window.layer.add(transition, forKey: kCATransition)
            }
            dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func shareBarButtonItemTapped(_ sender: UIBarButtonItem) {
        // show bottom share board
        let shareBoardPresenter = RYPresenter()
        if let headerImageView = headerImageView, let headerImage = headerImageView.image {
            shareBoardPresenter.willBeSharedImage = headerImage
        }
        shareBoardPresenter.modalPresentationStyle = .overCurrentContext
        shareBoardPresenter.modalTransitionStyle = .crossDissolve
        present(shareBoardPresenter, animated: true)
    }
    
    @IBAction func deSelectedBarButtonItemTapped(_ sender: UIBarButtonItem) {
        guard RYProfileCenter.me.isLogined else {
//            view.makeToast("您尚未登录, 只有先登录才能使用收藏功能呐", duration: 2.0, position: .center, style:  ToastManager.shared.style, completion: nil)
            RYUITweaker.simpleAlert("温馨提示", message: "您尚未登录, 只有先登录才能使用收藏功能呐")
            return
        }
        
        isCollection = !isCollection
    }
    
    @IBAction func selectedBarButtonItem(_ sender: UIBarButtonItem) {
        isCollection = !isCollection
    }
    
}

private let kRYHeightForHeaderInSection: CGFloat = 44.0
private let kRYHeaderImageViewRatio: CGFloat = 4.0/3.0

extension RYDishDetailsPage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = dataManager.dishDetails else {
            return 0
        }
        
        return sectionList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let _ = dataManager.dishDetails else {
            return 0
        }
        
        guard sectionList.count > 0, section < sectionList.count else { return CGFloat.leastNormalMagnitude }
        let sectionType = sectionList[section]
        switch sectionType {
        case .ingredient, .step:
            return kRYHeightForHeaderInSection
            
        case .brief:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dishDetails = dataManager.dishDetails else {
            return 0
        }
        
        guard sectionList.count > 0, section < sectionList.count else { return 0 }
        switch sectionList[section] {
        case .brief:
            return 1
        
        case .ingredient:
            if let ingredients = dishDetails.ingredients {
                return ingredients.count
            }
            return 0

        case .step:
            if let steps = dishDetails.steps {
                return steps.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dishDetails = dataManager.dishDetails else {
            return UITableViewCell()
        }
        
        guard sectionList.count > 0, indexPath.section < sectionList.count else { return UITableViewCell() }
        switch sectionList[indexPath.section] {
            
        case .brief:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYDishDetailsBriefCell", for: indexPath)
            if let cell = cell as? RYDishDetailsBriefCell {
                cell.update(dishDetails)
            }
            
            return cell
        
        case .ingredient:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYDishDetailsIngredientCell", for: indexPath)
            if let cell = cell as? RYDishDetailsIngredientCell,
                let ingredients = dishDetails.ingredients, ingredients.count > indexPath.row {
                cell.update(ingredients[indexPath.row])
            }
            return cell
            
        case .step:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYDishDetailsStepCell", for: indexPath)
            if let cell = cell as? RYDishDetailsStepCell, let steps = dishDetails.steps, steps.count > indexPath.row {
                cell.update(steps[indexPath.row], totalStep: steps.count)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let _ = dataManager.dishDetails else {
            return nil
        }
        
        guard sectionList.count > 0, section < sectionList.count else { return nil }
        let sectionType = sectionList[section]
        switch sectionType {
        case .brief:
            return nil
            
        case .ingredient, .step:
            if let views = Bundle.main.loadNibNamed("RYHPHeaderView", owner: nil, options: nil),
                let headerView = views.first as? RYHPHeaderView {
                let title = sectionType == .ingredient ? "需要食材" : "烹饪步骤"
                headerView.enableMoreButton(false)
                headerView.enableClearButton(false)
                headerView.update(title)

                return headerView
            }
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

extension RYDishDetailsPage: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffsetY = scrollView.contentOffset.y
//        debugPrint(contentOffsetY)
        let height = tableView.bounds.width / kRYHeaderImageViewRatio
        // set nav title
        let navHeight = heightForNavBarPlusStatusBar
        if !isPresentTitle {
            if contentOffsetY >= -navHeight { // half height of the header imageview
                isPresentTitle = true
                self.title = dataManager.dishDetails?.title
            }
        } else {
            if contentOffsetY < -navHeight {
                isPresentTitle = false
                self.title = ""
            }
        }
        
        // set headerimageview
        if let headerImageView = headerImageView {
            let offsetY = scrollView.contentOffset.y
            let radius = -offsetY/height
            if (-offsetY > height) {
                headerImageView.transform = CGAffineTransform(scaleX: radius, y: radius)
                var frame = headerImageView.frame
                frame.origin.y = offsetY
                headerImageView.frame = frame
            }
        }
    }
}

// MARK: - RYDataManagerDelegate
extension RYDishDetailsPage: RYDataManagerDelegate {
    func ryDataManagerAPI(_ dataManager: RYBaseDataManager) -> String? {
        guard let dishID = dishID,
            let api = RYAPICenter.api_dishesDetails(String(dishID)).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !api.isEmpty else { return nil }
        return api
    }
    
    func ryDataManager(_ dataManager: RYBaseDataManager, success: Any?, itemRetrived: Any?) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            if let dishDetails = self.dataManager.dishDetails, let urlString = dishDetails.albums, let url = URL(string: urlString) {
                self.headerImageView?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0)), .fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
            }
            
            // config right bar button items
            if let isCollection = self.dataManager.dishDetails?.isCollection {
                self.originCollectionValue = isCollection
                self.isCollection = isCollection
            }
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
                // reload
                self?.performDownloadData()
            }
        }
    }
}


// MARK: - Update favorite list for use

extension RYDishDetailsPage {
    private func updateFavoriteRecipesList(_ recipeId: Int?) {
        guard let recipeID = recipeId else { return }
        
        guard RYProfileCenter.me.isLogined else { return }
        
        guard let originValue = originCollectionValue, !originValue else { return }
        
        guard isCollection else { return }
        
        // guard and prapare url
        guard let url = URL(string: RYAPICenter.api_userCollecotRecipe(at: recipeID)) else { return }
        
        // add cookie(login-sessionid)
        RYDataManager.constructLoginCookie(for: url)
        
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        request.httpMethod = "POST"
        let dict = ["recipes_id": recipeID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        let dataRequest = Alamofire.request(request)
        
        dataRequest.responseData { response in
        
            switch response.result {
            case .success(let value):
                let dict = try? JSONSerialization.jsonObject(with: value, options: .allowFragments)
                if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
                    debugPrint("upload successfully for recipe \(recipeID)")
                } else {
                    debugPrint("upload failed for recipe \(recipeID)")
                }
            case .failure:
                debugPrint("upload failed for recipe \(recipeID)")
            }
        }
    }
}
