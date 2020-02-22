//
//  StoryboardHelper.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/3/26.
//  Copyright © 2019 RuiYu. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    enum eRYStoryboard: String {
        case Main, WebPage, Ad
    }
    
    convenience init(storyboard: eRYStoryboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    class func storyboard(_ storyboard: eRYStoryboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(storyboard: storyboard, bundle: bundle)
    }
    
    class func storyboardPage<T: UIViewController>(_ storyboardName: eRYStoryboard) -> T {
        let storyboard = UIStoryboard(storyboard: storyboardName)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Coundn't instantiate view controller with identifier \(T.storyboardIdentifier)")
        }
        return viewController
    }
    
    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Coundn't instantiate view controller with identifier \(T.storyboardIdentifier)")
        }
        return viewController
    }
    
    /*
    func instantiateViewController<T: UIViewController>(a: T) -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Coundn't instantiate view controller with identifier \(T.storyboardIdentifier)")
        }
        return viewController
    }
    */
}


extension UIViewController: StoryboardIdentifiable {}

// MARK: - Identifiable

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

