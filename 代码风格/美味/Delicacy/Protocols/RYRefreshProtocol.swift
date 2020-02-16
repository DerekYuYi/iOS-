//
//  RYRefreshProtocol.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/27.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import Foundation
import UIKit

protocol RefreshProtocol {
    var refreshControl: UIRefreshControl? { get set }
    
    func setupRefreshing()
    func endRefreshing()
    func refresh(_ refreshControl: UIRefreshControl)
}

/// optional methods
extension RefreshProtocol {
    func refreshText() -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [.font: RYFormatter.fontLarge(for: .light),
                                                         .foregroundColor: UIColor.red]
        return NSAttributedString(string: "下拉刷新", attributes: attributes)
    }
    
    func refreshingText() -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [.font: RYFormatter.fontLarge(for: .light),
                                                         .foregroundColor: UIColor.red]
        return NSAttributedString(string: "正在刷新...", attributes: attributes)
    }
    
    func refreshScrollView() -> UIScrollView? {
        return nil
    }
}
