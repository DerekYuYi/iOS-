//
//  RYWKLeakAvoider.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/3/7.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit
import WebKit

class RYWKLeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(_ delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
