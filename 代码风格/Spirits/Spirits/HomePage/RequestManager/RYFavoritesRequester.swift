//
//  RYFavoritesRequester.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/15.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation

class RYFavoritesRequester: NSObject {
    
    static func requestFavoritesAPI(_ type: Int) {
        RYAPIRequester.request(RYAPICenter.api_favorite(at: type),
                               method: .post,
                               needUserAuthorizationHeaders: true,
                               successHandler: { dict in
                                debugPrint("\(#function) is successfully")
        },
                               failureHandler: { error in
                                debugPrint("\(#function) is failed")
        })
    }
    
    static func requestCancelFavoritesAPI(_ type: Int) {
        RYAPIRequester.request(RYAPICenter.api_cancelFavorite(at: type),
                               method: .post,
                               needUserAuthorizationHeaders: true,
                               successHandler: { dict in
                                debugPrint("\(#function) is successfully")
        },
                               failureHandler: { error in
                                debugPrint("\(#function) is failed")
        })
    }
}
