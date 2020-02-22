//
//  RYTypeListRequestManager.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/15.
//  Copyright © 2019 RuiYu. All rights reserved.
//

/*
 Abstract: Manages all types list api requests.
 */

import UIKit

enum eRYRequestStatus {
    case loading
    case success(Bool) // Bool value indicates wheather the returned list is not empty.
    case failed(Error?)
}

protocol RYTypeListRequestManagerDelegate: NSObjectProtocol {
    func requestStatus(_ requestManager: RYTypeListRequestManager, _ status: eRYRequestStatus)
}

class RYTypeListRequestManager: NSObject {
    
    /// retrieved model datas which back from apis
    var typeList = [RYTypeContentItem]()
    weak var delegate: RYTypeListRequestManagerDelegate?
    
    private var pageCount: Int = 0
    
    init(_ delegate: RYTypeListRequestManagerDelegate?) {
        super.init()
        self.delegate = delegate
    }
    
    func performRequest(_ api: String, isNeedAuthorization: Bool) {
        
        RYAPIRequester.request(api,
                               method: .get,
                               needUserAuthorizationHeaders: isNeedAuthorization,
                               successHandler: {[weak self] dict in
                                
                                guard let strongSelf = self else { return }
                                
                                // calculate pages
                                if let totalNumber = dict["total"] as? Int, totalNumber > 0 {
                                    let remainder = totalNumber % 20
                                    let consult = totalNumber / 20
                                    if remainder > 0 {
                                        strongSelf.pageCount = consult + 1
                                    } else {
                                        strongSelf.pageCount = consult
                                    }
                                }
                             
                                // retrieve list data
                                if let data = dict["data"] as? [[String: Any]], data.count > 0 {
                                    
                                    var helper = [RYTypeContentItem]()
                                    
                                    data.forEach({ item in
                                        let itemData = try? JSONSerialization.data(withJSONObject: item, options: JSONSerialization.WritingOptions.prettyPrinted)
                                        if let itemData = itemData {
                                            let typeContentItem = try? JSONDecoder().decode(RYTypeContentItem.self, from: itemData)
                                            if let typeContentItem = typeContentItem {
                                                helper.append(typeContentItem)
                                            }
                                        }
                                    })
                                    
                                    strongSelf.typeList.append(contentsOf: helper)
                                    
                                    strongSelf.delegate?.requestStatus(strongSelf, .success(true))
                                    
                                } else {
                                    strongSelf.delegate?.requestStatus(strongSelf, .success(false))
                                }
        }) {[weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.requestStatus(strongSelf, .failed(nil))
        }
    }
    
    /// Clear typelist data
    func clearData() {
        typeList = [RYTypeContentItem]()
    }
    
    /// Returns a boolean value that indicates if has next page.
    /// - Parameter nextPageIndex: the next page index.
    func pagingEnabled(for nextPageIndex: Int) -> Bool {
        return (pageCount >= nextPageIndex)
    }
}

