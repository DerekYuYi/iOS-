//
//  RYRequestProtocol.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/15.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation

enum eRYDataListLoadingType {
    case none // no any loading, error tips, ...
    case zeroData // success but no data
    case loading // initial loading, animation loading for this project
    case notReachable // network wrong
    case error // errors occured: 404, 500
}


protocol RYRequestProtocol: NSObjectProtocol {
    
}
