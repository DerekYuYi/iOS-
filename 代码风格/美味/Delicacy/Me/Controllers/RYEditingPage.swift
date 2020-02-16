//
//  RYEditingPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/16.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Toast_Swift

enum eRYEditingType {
    case nickName, sex, intro
}

class RYEditingPage: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editingNavigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    var editingType: eRYEditingType = .nickName
    var editedCallBackClosure: ((String?) -> Void)?
    
    // sex
    private let genders = ["男", "女"]
    private var selectedSexRow: Int?
    
    // nickname
    private var editedName = RYProfileCenter.me.nickName
    private var nameTextField: UITextField?
    
    // intro
    private var editedIntro: String?
    private var introTextView: UITextView?
    
    
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYEditingPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYEditingPage()
    }
    
    private func setup_RYEditingPage() {
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        editingNavigationBar.barTintColor = .white
        editingNavigationBar.tintColor = RYColors.yellow_theme
        doneBarButtonItem.title = "完成"
        doneBarButtonItem.isEnabled = false
//        doneBarButtonItem.setTitleTextAttributes(<#T##attributes: [NSAttributedString.Key : Any]?##[NSAttributedString.Key : Any]?#>, for: <#T##UIControl.State#>)
        cancelBarButtonItem.title = "取消"
        navigationBarItem.rightBarButtonItems = [doneBarButtonItem]
        navigationBarItem.leftBarButtonItems = [cancelBarButtonItem]
        
        switch editingType {
        case .nickName:
            self.navigationBarItem.title = "设置名字"
            
        case .sex:
            self.navigationBarItem.title = "设置性别"
            
        case .intro:
            self.navigationBarItem.title = "设置个性签名"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = RYFormatter.bgLightGrayColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navBarHeightConstraint.constant = RYFormatter.navigationBarPlusStatusBarHeight(for: self) - RYFormatter.statusBarHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if editingType == .nickName {
            if let nameTextField = nameTextField {
                nameTextField.text = RYProfileCenter.me.nickName
                if !nameTextField.isFirstResponder {
                    nameTextField.becomeFirstResponder()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard editingType == .sex else { return }
        switch editingType {
        case .nickName:
            if let nameTextField = nameTextField {
                if !nameTextField.isFirstResponder {
                    nameTextField.becomeFirstResponder()
                }
            }
            
        case .sex:
            if let sex = RYProfileCenter.me.sex {
                if sex == "男" {
                    selectedSexRow = 0
                } else if sex == "女" {
                    selectedSexRow = 1
                }
                tableView.reloadData()
            }
            
        case .intro:
            if let introTextView = introTextView, !introTextView.isFirstResponder {
                introTextView.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func doneBarButtonitemTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        switch self.editingType {
        case .nickName:
            if let editedName = editedName {
                RYProfileCenter.me.nickName = editedName
                if let closure = editedCallBackClosure {
                    closure(editedName)
                }
            }
            
        case .sex:
            if let selectedIndex = selectedSexRow {
                RYProfileCenter.me.sex = genders[selectedIndex]
                if let closure = editedCallBackClosure {
                    closure(genders[selectedIndex])
                }
            }
            
        case .intro:
            if let intro = editedIntro {
                RYProfileCenter.me.introduction = intro
                if let closure = editedCallBackClosure {
                    closure(intro)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBarButtonitemTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        self.view.clearToastQueue()
    }
    
}

private let kRYHeightForHeaderInSection: CGFloat = 16
private let kRYHeightForNormalRow: CGFloat = 44

extension RYEditingPage: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kRYHeightForHeaderInSection
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch editingType {
        case .nickName, .intro:
            return 1
            
        case .sex:
            return genders.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch editingType {
        case .nickName, .sex:
            return 44
            
        case .intro:
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch editingType {
        case .nickName:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYEditNameCell", for: indexPath)
            if let cell = cell as? RYEditNameCell {
                cell.delegate = self
                nameTextField = cell.nameTextField
                cell.nameTextField.delegate = self
            }
            return cell
            
        case .sex:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYEditSexCell", for: indexPath)
            if let cell = cell as? RYEditSexCell, indexPath.row < genders.count {
                if let selectedSexRow = selectedSexRow, selectedSexRow == indexPath.row {
                    cell.update(genders[indexPath.row], indexPathRow: indexPath.row, isHiddenFlag: false)
                } else {
                    cell.update(genders[indexPath.row], indexPathRow: indexPath.row, isHiddenFlag: true)
                }
            }
            return cell
            
        case .intro:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYEditIntroductionCell", for: indexPath)
            if let cell = cell as? RYEditIntroductionCell {
                introTextView = cell.introTextView
                introTextView?.delegate = self
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch editingType {
        case .sex:
            // choose flag
            selectedSexRow = indexPath.row
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.doneBarButtonItem.isEnabled = true
            }
        default:
            break
        }
    }
}


extension RYEditingPage: RYEditNameCellDelegate, UITextFieldDelegate {
    // MARK: - RYEditNameCellDelegate
    func nameTextFieldEditingChanged(_ textField: UITextField) {
        // 1. guard
        guard let editedText = textField.text, !editedText.isEmpty else {
            return
        }
        
        // 2. trimmed
        let trimmedString = editedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedString.isEmpty {
            return
        }
        
        if let nickName = RYProfileCenter.me.nickName {
            if nickName == trimmedString { // not changed at all
                doneBarButtonItem.isEnabled = false
            } else { // changed
                doneBarButtonItem.isEnabled = true
            }
        } else { // changed
            doneBarButtonItem.isEnabled = true
        }
        
        // 3. limited
        if trimmedString.count > 20 {
            DispatchQueue.main.async {
                self.view.makeToast("听说食神的名字都在20字以内", duration: 1.7, position: .center)
                let trimmedIndex = trimmedString.index(trimmedString.startIndex, offsetBy: 20)
                textField.text = String(trimmedString[trimmedString.startIndex..<trimmedIndex])
            }
            return
        }
        
        // 4. udpate editted
        editedName = trimmedString
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}


extension RYEditingPage: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 1. trimmed
        let trimmedString = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedString.isEmpty {
            return
        }
        
        if let intro = RYProfileCenter.me.introduction {
            if intro == trimmedString { // not changed at all
                doneBarButtonItem.isEnabled = false
            } else { // changed
                doneBarButtonItem.isEnabled = true
            }
        } else { // changed
            doneBarButtonItem.isEnabled = true
        }
        
        // 2. limit
        if trimmedString.count > 50 {
            DispatchQueue.main.async {
                self.view.makeToast("听说食神的介绍都在50字以内", duration: 1.7, position: .center)
                let trimmedIndex = trimmedString.index(trimmedString.startIndex, offsetBy: 50)
                textView.text = String(trimmedString[trimmedString.startIndex..<trimmedIndex])
                self.editedIntro = textView.text
            }
            return
        }
        
        // 3. udpate edited
        editedIntro = trimmedString
    }
}
