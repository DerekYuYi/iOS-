//
//  UICollectionView+Extension.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/2/25.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import Foundation


extension UICollectionView {
    
    private struct AssocitedKeys {
        static var collectionFooterViewKey = "UICollectionView_collectionFooterViewKey"
    }
    
    var collectionFooterView: UIView? {
        get {
            if let footerView = objc_getAssociatedObject(self, &AssocitedKeys.collectionFooterViewKey) as? UIView {
                return footerView
            }
            return nil
        }
        
        set {
            objc_setAssociatedObject(self, &AssocitedKeys.collectionFooterViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func showFooterActivityIndicator(for type: eRYDataListLoadingType, description text: String? = nil, handler tapHandler:(() -> Void)? = nil) {
        switch type {
        case .none:
            emptyCollectionFooterView()
            
        case .zeroData, .loading, .notReachable, .error:
            // empty footer view
            emptyCollectionFooterView()
            
            // setup footer view
            if let collectionFooterView = activityIndicator(for: type, description: text, handler: tapHandler) {
                self.collectionFooterView = collectionFooterView
                self.addSubview(collectionFooterView)
                self.bringSubviewToFront(collectionFooterView)
                collectionFooterView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 285) // NOTE: The height is same as UITableView tableFooterView's height. See details at line 39 in `UIScrollView+Extension.swift`.
            }
        }
    }
    
    private func emptyCollectionFooterView() {
        collectionFooterView?.removeFromSuperview()
        collectionFooterView = nil
    }
}
