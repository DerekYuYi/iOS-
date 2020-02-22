//
//  RYLoginRequester.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/12.
//  Copyright © 2019 RuiYu. All rights reserved.
//

/**
 Abstruct:
 Manages request steps when login.
 
 **/

import UIKit
import Alamofire

class RYLoginRequester: NSObject {
    
    private weak var loginPannel: RYLoginPannel?

    init(_ loginPannel: RYLoginPannel) {
        self.loginPannel = loginPannel
        super.init()
    }
    
    // MARK: - request 
    
    func requestLogin() {
        guard let loginPannel = loginPannel else { return }
        
        guard let phoneNumber = loginPannel.phoneNumber(), let password = loginPannel.password() else { return }
        
        let params = ["username": phoneNumber,
                      "password": password]
        
        RYAPIRequester.request(RYAPICenter.api_login(),
                               method: .post,
                               parameters: params,
                               encoding: .default,
                               needUserAuthorizationHeaders: true,
                               successHandler: { data in
                                
                                loginPannel.disEnabledConfirmButton()
                                
                                // retrieve profileData and update profile data
                                if let data = data["data"] as? [String: Any], data.count > 0 {
                                    RYProfileCenter.me.profileData = RYProfileItem(data)
                                }
                                
                                loginPannel.showUIWhenLoginSuccessfully()
        }) { error in
            loginPannel.disEnabledConfirmButton()
            
            loginPannel.showUIWhenLoginFailed()
        }
    }
    
    func requestRegister() {
        guard let loginPannel = loginPannel else { return }
        
        guard let url = URL(string: RYAPICenter.api_regiter()) else { return }
        
        // Note: Generally, phone number and password have checked when input, so there is no need to check detailly.
        guard let phoneNumber = loginPannel.phoneNumber(), let password = loginPannel.password() else { return }
            
        let params: [String: String] = ["username": phoneNumber,
                                        "password": password]
        
        let dataRequest = Alamofire.request(url,
                                            method: .post,
                                            parameters: params,
                                            encoding: URLEncoding.default,
                                            headers: nil)
        
        // visible network indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        dataRequest.responseData { response in
            // 1. guard
            
            // 2. asynchronously handle indicators
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                loginPannel.disEnabledConfirmButton()
            }
            
            switch response.result {
            case .success(let value):
                
                let dict = try? JSONSerialization.jsonObject(with: value, options: .allowFragments)
                if let dict = dict as? [String: Any], let code = dict["code"] as? Int, code == 1 {
                    // login successfully
                    if let data = dict["data"] as? [String: Any], data.count > 0 {
                        // retrieve profileData and update profile data
                        RYProfileCenter.me.profileData = RYProfileItem(data)
                    }
                    
                    loginPannel.showUIWhenLoginSuccessfully()
                    
                } else {
                    // login failed
                    loginPannel.showUIWhenLoginFailed()
                }
                
            case .failure:
                // login failed
                loginPannel.showUIWhenLoginFailed()
            }
        }
    }
}
