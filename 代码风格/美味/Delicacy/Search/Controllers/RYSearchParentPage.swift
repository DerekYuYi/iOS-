//
//  RYSearchParentPage.swift
//  Delicacy
//
//  Created by DerekYuYi on 2019/3/11.
//  Copyright © 2019 RuiYu. All rights reserved.
//

// NOTE: No use.
import UIKit

class RYSearchParentPage: RYBaseViewController {
    
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "搜索"
        navigationItem.rightBarButtonItems = [cancelBarButtonItem]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 38))
        view.addSubview(searchBar)
        navigationItem.titleView = view
    }

}
