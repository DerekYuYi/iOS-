//
//  RYPublishPage.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/10.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire

class RYPublishPage: RYBasedViewController {
    
    private struct Constants {
        static let defaultCellReuseIdentifier = "UITableViewCell"
        static let title = "发布"
        static let heightForRowInSectionSelectType: CGFloat = 44
        static let heightForRowInSectionFillTitle: CGFloat = 44
        static let heightForRowInSectionFillContent: CGFloat = 120
        static let heightForSectionHeader: CGFloat = 44
        static let heightForTopSeperatorView: CGFloat = 20
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var adoptView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var submitBarButtonItem: UIBarButtonItem!
    
    // MARK: - Properties
    
    private var titleFillCell: RYPublishTitleFillCell?
    private var contentFillCell: RYPublishContentFillCell?
    
    private var cellFolder = RYCellFolder()
    
    private let types = [RYTypeItem(id: 1, name: "妙招"),
                         RYTypeItem(id: 2, name: "生活"),
                         RYTypeItem(id: 3, name: "健康"),
                         RYTypeItem(id: 4, name: "饮食")]
    private var selectedType: RYTypeItem = RYTypeItem(id: 1, name: "妙招")
    
    // save the last publish title and contents for preventing publish
    private var lastTitle: String?
    private var lastContent: String?
    
    /// Only record once when user publish the first time successfully after pushed the publish page.
    private var hasPublishedOnce = false
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            adoptView.backgroundColor = UIColor(named: "Color_FCFCFC")
        } else {
            adoptView.backgroundColor = .white
        }
        
        // nav configuration
        title = Constants.title
        self.navigationItem.rightBarButtonItems = [submitBarButtonItem]
        submitBarButtonItem.setTitleTextAttributes([.foregroundColor: RYColors.color(from: 0x306EE6)], for: .normal)
        
        // initial type
        selectedType = types[0]
        
        // tableview configurations
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.defaultCellReuseIdentifier)
        
        // add gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapGesture.cancelsTouchesInView = false // otherwise, blocking the cell selection
        tableView.addGestureRecognizer(tapGesture)
        
        // add keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // check if has logined
        if !RYProfileCenter.me.isLogined {
            view.makeToast("请先登录", duration: 0.8, position: .top) { _ in
                RYLoginPannel.presentLoginPannel(from: self)
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.hideAllToasts()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Touch events
    
    @IBAction func submitBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        // dismiss keyboard
        dismissKeyboard()
        
        // check login state
        guard RYProfileCenter.me.isLogined else {
            view.makeToast("请先登录", duration: 0.8, position: .top) { _ in
                RYLoginPannel.presentLoginPannel(from: self)
            }
            return
        }
        
        // prepare data
        guard let title = titleFillCell?.filledText(), !title.isEmpty else {
            view.makeToast("标题不能为空", duration: 1.4, position: .center)
            return
        }
        
        guard let content = contentFillCell?.filledText(), !content.isEmpty else {
            view.makeToast("内容不能为空", duration: 1.4, position: .center)
            return
        }
        
        guard let typeId = selectedType.id else {
            view.makeToast("类型选择不正确", duration: 1.4, position: .center)
            return
        }
        
        // check if is repeatly operation
        guard !isPublishRepeatly(title, content) else {
            self.view.makeToast("你的发布已经在审核中, 请不要重复发布", duration: 1.8, position: .top, title: "重复发布")
            return
        }
        
        let params: [String: Any] = ["classification": typeId,
                      "title": title,
                      "content": content]
        
        // request publish api
        requestPublishAPI(params)
    }
    
    private func isPublishRepeatly(_ title: String, _ content: String) -> Bool {
        // when you adjudge whether it is a repeated operation, there must has previous records.
        guard hasPublishedOnce else { return false }
        
        // check previous title and content
        guard let lastTitle = lastTitle, let lastContent = lastContent, !lastTitle.isEmpty, !lastContent.isEmpty else { return false }
        
        // check whether equal between previous data and current data
        guard lastTitle == title, lastContent == content else { return false }
        
        return true
    }
    
    @objc func tableViewTapped(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    
    // MARK: - Notification
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let fillContentCell = contentFillCell, fillContentCell.isFirstResponderForInterResponder() else { return }
        
        // fold expended cells inside first sections
        self.foldTypeSelectCell()
        
        if let userInfo = notification.userInfo {
            if let rect = userInfo["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                let keyboardHeight = rect.height
                
                let insideSafeMarginTableView: CGFloat = tableView.bounds.height - (Constants.heightForTopSeperatorView + Constants.heightForSectionHeader*3 + Constants.heightForRowInSectionSelectType + Constants.heightForRowInSectionFillTitle + Constants.heightForRowInSectionFillContent)
                
                let offset = insideSafeMarginTableView - keyboardHeight
                if offset < 0 {
                    tableView.setContentOffset(CGPoint(x: 0, y: -offset), animated: true)
                }
            }
        }
    }
}

// MARK: - Table view data source

extension RYPublishPage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.heightForSectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if cellFolder.isContainedIndexPath(at: IndexPath(row: 0, section: section)) { // unfold types for select
                return types.count + 1 // + 1 for the first row cell at 0 section
            } else {
                return 1
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            if cellFolder.isContainedIndexPath(at: indexPath) {
                return indexPath.row == 0 ? Constants.heightForRowInSectionSelectType : Constants.heightForRowInSectionSelectType-4
            }
            
            return Constants.heightForRowInSectionSelectType
            
        case 1:
            return Constants.heightForRowInSectionFillTitle
            
        case 2:
            return Constants.heightForRowInSectionFillContent
            
        default:
            fatalError("Invalid indexPath")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if cellFolder.isContainedIndexPath(at: IndexPath(row: 0, section: indexPath.section)) {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RYPublishChooseTypeCell.self), for: indexPath)
                    if let cell = cell as? RYPublishChooseTypeCell {
                        cell.update(selectedType)
                        cell.rotate(true)
                    }
                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.defaultCellReuseIdentifier, for: indexPath)
                    // synchorinousIndex can sync indexPath.row and index of types
                    let synchorinousIndex = indexPath.row - 1
                    if synchorinousIndex < types.count {
                        cell.textLabel?.text = types[synchorinousIndex].name
                    }
                    
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RYPublishChooseTypeCell.self), for: indexPath)
                if let cell = cell as? RYPublishChooseTypeCell {
                    cell.update(selectedType)
                    cell.rotate(false)
                }
                return cell
            }
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RYPublishTitleFillCell.self), for: indexPath)
            if let cell = cell as? RYPublishTitleFillCell {
                titleFillCell = cell
            }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RYPublishContentFillCell.self), for: indexPath)
            if let cell = cell as? RYPublishContentFillCell {
                cell.delegate = self
                contentFillCell = cell
            }
            return cell
            
        default:
            fatalError("Exception occurred")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = nil
        view.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        
        let titleLabel = UILabel(frame: CGRect(x: 16+10, y: (44-30) / 2.0 + 3.0, width: 100, height: 30))
        view.addSubview(titleLabel)
        
        titleLabel.backgroundColor = nil
        titleLabel.textColor = RYColors.color(from: 0x999999)
        
        switch section {
        case 0:
            titleLabel.text = "分类"
            
        case 1:
            titleLabel.text = "标题"
            
        case 2:
            titleLabel.text = "内容"
            
        default:
            break
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 0 else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 { // handle selected at (0, 0)
        
            if cellFolder.isContainedIndexPath(at: indexPath) {
                cellFolder.removeIndexPath(at: indexPath)
            } else {
                cellFolder.recordIndexPath(at: indexPath)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }
            
        } else { // handle selected excepted (0, 0)
            
            guard cellFolder.isContainedIndexPath(at: IndexPath(row: 0, section: indexPath.section)) else { return }
            
            // synchorinousIndex can sync indexPath.row and index of types
            let synchorinousIndex = indexPath.row - 1
            if synchorinousIndex < types.count {
                selectedType = types[synchorinousIndex]
            }
            
            // remove record
            cellFolder.removeIndexPath(at: IndexPath(row: 0, section: indexPath.section))
            
            // update tableview
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }
        }
    }
    
    private func foldTypeSelectCell() {
        let recordIndexPath = IndexPath(row: 0, section: 0)
        guard cellFolder.isContainedIndexPath(at: recordIndexPath) else { return }
        
        // remove record
        cellFolder.removeIndexPath(at: recordIndexPath)
        
        // update tableview
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: recordIndexPath.section), with: .none)
        }
    }
}

// MARK: - Touch events

extension RYPublishPage {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
}

// MARK: - UIScrollViewDelegate

extension RYPublishPage: UIScrollViewDelegate {
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        dismissKeyboard()
//    }
    
    func dismissKeyboard() {
        titleFillCell?.dismissKeyboard()
        contentFillCell?.dismissKeyboard()
    }
}

extension RYPublishPage: RYPublishContentFillCellDelegate {
    
//    func textViewDidBeginEditing() {
//        keyboardWillShow(Notification(name: UIResponder.keyboardWillShowNotification))
//    }
}

// MARK: - API Requests

extension RYPublishPage {
    
    private func requestPublishAPI(_ params: Parameters?) {
        
        DispatchQueue.main.async {
            self.showLoadingView(true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            RYAPIRequester.request(RYAPICenter.api_publish(), method: .post,
                                   parameters: params,
                                   encoding: .default,
                                   needUserAuthorizationHeaders: true,
                                   successHandler: {[weak self] data in
                                    
                                    guard let strongSelf = self else { return }
                                    // publish successfully
                                    
                                    // record for preventing publishing repeatly.
                                    strongSelf.hasPublishedOnce = true
                                    strongSelf.lastTitle = strongSelf.titleFillCell?.filledText()
                                    strongSelf.lastContent = strongSelf.contentFillCell?.filledText()
                                    
                                    strongSelf.showLoadingView(false)
                                    strongSelf.view.makeToast("为了营造健康的发布环境,我们会对你的发布进行审核, 请耐心等待", duration: 2.0, position: .center, title: "发布成功")
                                    
            }) {[weak self] error in
                
                guard let strongSelf = self else { return }
                // publish failed
                strongSelf.showLoadingView(false)
                strongSelf.view.makeToast("请确保网络环境良好, 或重新进入发布页面", duration: 2.0, position: .center, title: "发布失败")
                
                return
            }
        }
    }
        
}
