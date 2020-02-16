//
//  UITableView+Extension.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/8.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import Foundation
import UIKit

private var wg_orininalFrame = "wg_orininalFrame"
private var wg_imageView = "wg_imageView"

extension UITableView {
    func showFooterActivityIndicator(for type: eRYDataListLoadingType, description text: String? = nil, handler tapHandler:(() -> Void)? = nil) {
        switch type {
        case .none:
            tableFooterView = nil
            
        case .zeroData, .loading, .notReachable, .error:
            tableFooterView = activityIndicator(for: type, description: text, handler: tapHandler)
        }
    }
    
    
    func wg_setHeaderView(frame: CGRect, image: UIImage?) {
        
        objc_setAssociatedObject(self, &wg_orininalFrame, frame, .OBJC_ASSOCIATION_RETAIN)
        
        let header = UIView(frame: frame)
        self.tableHeaderView = header
        
        // 背景图片
        let bgImg = UIImageView(frame: frame)
        bgImg.image = image
        bgImg.contentMode = .scaleAspectFill
        self.insertSubview(bgImg, at: 0)
        
        // 创建关联(image)
        objc_setAssociatedObject(self, &wg_imageView, bgImg, .OBJC_ASSOCIATION_RETAIN)
        
        // KVC监听(注意:字符串必须是contentOffset)
        self.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }
    
    // 只要有新值变化就会调用该方法
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // 获取关联的对象
        let orginal = objc_getAssociatedObject(self, &wg_orininalFrame) as? CGRect
        let img = objc_getAssociatedObject(self, &wg_imageView) as? UIImageView
        
        // 偏移量
        let offset = self.contentOffset.y
        if offset<0 {
            
            img?.frame = CGRect.init(x: offset, y: offset, width: (orginal?.size.width)!-2*offset, height: (orginal?.size.height)!-offset)
        }else{
            img?.frame = orginal!
        }
    }
}

