//
//  RYPreferencesPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/7.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire

class RYPreferencesPage: RYBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var selectedImage: UIImage?
    private var nickName: String?
    private var sexString: String?
    private var introduction: String?
    
    
    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup_RYPreferencesPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup_RYPreferencesPage()
    }
    
    private func setup_RYPreferencesPage() {
        self.title = "个人资料"
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        super.viewDidLoad()
        tableView.backgroundColor = RYFormatter.bgLightGrayColor()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let vcs = self.navigationController?.viewControllers
        if let isContains = vcs?.contains(self), !isContains {
            debugPrint("pop action")
            // update only once when excute pop opearation
            requestUploadAvatarAPI()
            requestUpdateProfileAPI()
        }
    }
}


extension RYPreferencesPage: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYPreferenceImageCell", for: indexPath)
            if let cell = cell as? RYPreferenceImageCell {
                cell.udpate("头像", image: self.selectedImage)
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RYPreferenceCell", for: indexPath)
            if let cell = cell as? RYPreferenceCell {
                if indexPath.row == 0 {
                    if let nickName = RYProfileCenter.me.nickName {
                        cell.update("名字", nickName, true)
                    } else {
                        cell.update("名字", "设置名字", true)
                    }
                   
                } else if indexPath.row == 1 {
                    if let sex = RYProfileCenter.me.sex {
                        cell.update("性别", sex, true)
                    } else {
                        cell.update("性别", "设置性别", true)
                    }
                    
                } else if indexPath.row == 2 {
                    if let intro = RYProfileCenter.me.introduction {
                        cell.update("个性签名", intro, false)
                    } else {
                        cell.update("个性签名", "设置个人签名", false)
                    }
                }
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
        if indexPath.section == 0 { // modify avatar
            if !checkLoginStatus() { return }
            
            // add sheet
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let photoAction = UIAlertAction(title: "相册", style: .default) { action in
                // open photoLibrary
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                imagePicker.navigationBar.isTranslucent = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            alert.addAction(photoAction)
            
            let cameraAction = UIAlertAction(title: "相机", style: .default) { action in
                // open camera
                let imagePicker = UIImagePickerController()
                
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
            alert.addAction(cameraAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { action in
                // open camera
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            if indexPath.row == 0 { // update nickname
                if !checkLoginStatus() { return }
                presentEditingPage(.nickName)
                
            } else if indexPath.row == 1 { // update sex
                if !checkLoginStatus() { return }
                presentEditingPage(.sex)
                
            } else if indexPath.row == 2 { // update introduction
                if !checkLoginStatus() { return }
                presentEditingPage(.intro)
            }
        }
    }
    
    private func checkLoginStatus() -> Bool {
        guard RYProfileCenter.me.isLogined else {
            DispatchQueue.main.async {
                self.view.makeToast("您未登录", duration: 1.4, position: .center)
            }
            return false
        }
        return true
    }
    
    private func presentEditingPage(_ type: eRYEditingType) {
        if let editingPage = UIStoryboard.editingStoryboard_EditingPage() {
            editingPage.editingType = type
            editingPage.editedCallBackClosure = { string in
                if let string = string {
                    switch type {
                    case .nickName:
                        self.nickName = string
                        
                    case .sex:
                        self.sexString = string
                        
                    case .intro:
                        self.introduction = string
                    }
                }
            }
            self.present(editingPage, animated: true, completion: nil)
        }
    }
    
    private func requestUploadAvatarAPI() {
        guard let avatarImage = selectedImage else { return }
        var helperImage: UIImage?
        if let data = avatarImage.jpegData(compressionQuality: 0.2) {
            helperImage = UIImage(data: data)
        }
    
        // guard and prapare url
        guard let url = URL(string: RYAPICenter.api_userAvatarUpload()) else { return }
        
        // add cookie(login-sessionid)
        RYDataManager.constructLoginCookie(for: url)
        
        // construct request
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        
        request.httpMethod = "POST"
        
        var body = Data()
        if let helperImage = helperImage,
            let imageData = helperImage.pngData() {
            
            let boundary = NSUUID().uuidString
            let fieldName = "name"
            let fieldValue = "fileupload"
            let fileName = "profile.png"
            
            // 1. set content-type
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            // 2. add the reqtype field and its value to the raw http request data
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            if let ContentDispositionData = "Content-Disposition: form-data;name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8) {
                body.append(ContentDispositionData)
            }
            body.append("\(fieldValue)".data(using: .utf8)!)
            
            // 3. Add the image data to the raw http request data
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"name\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!) // mimetype
            body.append(imageData)
            
            // 4.  End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
            // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        }
        
        // visible network indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.uploadTask(with: request, from: body) { (data, response, error) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if let error = error {
                debugPrint(error)
            } else {
                if let response = response as? HTTPURLResponse {
                    debugPrint(response.statusCode)
                }
                
                if let data = data {
              
                    let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    if let dict = dict as? [String: Any], let info = dict["msg"] as? String {
                        debugPrint(info)
                    }
                    
                    
                    if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
                        // upload success
                        debugPrint("upload successfully")
                        if let data = dict["data"] as? [String: Any],
                            let imageUrlString = data["image_url"] as? String, !imageUrlString.isEmpty {
                            // update profile data
                            RYProfileCenter.me.avatarUrlString = imageUrlString
                        }
                    } else {
                        // upload failed
                        debugPrint("upload failed")
                    }
                }
            }
        }.resume()
    }
    
    private func requestUpdateProfileAPI() {
        var isValid = false
        var params: [String: Any] = [:]
        if let nickName = nickName, !nickName.isEmpty {
            isValid = true
            params.updateValue(nickName, forKey: "nick")
        }
        if let sex = sexString, !sex.isEmpty {
            isValid = true
            if sex == "男" {
                params.updateValue(0, forKey: "gender")
            } else {
                params.updateValue(1, forKey: "gender")
            }
            
        }
        if let intro = introduction, !intro.isEmpty {
            isValid = true
            params.updateValue(intro, forKey: "introduction")
        }
        if !isValid { return }
        
        // guard and prapare url
        guard let url = URL(string: RYAPICenter.api_userInfoUpdate()) else { return }
        
        // add cookie(login-sessionid)
        RYDataManager.constructLoginCookie(for: url)
        
        // construct request
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        request.httpMethod = "PUT"
        
        if params.count > 0 {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        let dataRequest = Alamofire.request(request)
        
        // visible network indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        dataRequest.responseData { response in
            // 2. asynchronously handle indicators
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            switch response.result {
            case .success(let value):
                let dict = try? JSONSerialization.jsonObject(with: value, options: .allowFragments)
                if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
                    // upload success
                    if let data = dict["data"] as? [String: Any], data.count > 0 {
                        // retrieve profileData and update profile data
                        RYProfileCenter.me.profileData = RYProfileItem(data)
                    }
                } else {
                    // upload failed
                }
            case .failure:
                // upload failed
                break
            }
        }
    }
}

extension RYPreferencesPage: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // update image
            self.selectedImage = originalImage
            
            // update UI
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
            // dismiss
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func resizeImage(_ originSize: CGSize) -> CGSize {
        
        //prepare constants
        let width = originSize.width
        let height = originSize.height
        let scale = width / height
        
        var resize = originSize
        
        if scale > 1 && width > 1024 {
            resize = CGSize(width: 1024, height: 1024/scale)
        } else if scale <= 1 && height > 1024 {
            resize = CGSize(width: 1024*scale, height: 1024)
        }
        
        return resize
    }
}

