//
//  LeakAvoider.swift
//  WKWebviewJSDemo
//
//  Created by DerekYuYi on 2019/3/7.
//  Copyright © 2019 Wenlemon. All rights reserved.
//

import UIKit
import WebKit

class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(_ delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
