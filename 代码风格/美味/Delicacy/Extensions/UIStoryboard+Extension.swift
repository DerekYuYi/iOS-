//
//  UIStoryboard+extension.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/9/21.
//  Copyright © 2018年 RuiYu. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    
    // MARK: - Main
    static func mainStoryboard_starter() -> RYTabBarViewController? {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = mainStoryBoard.instantiateViewController(withIdentifier: "RYTabBarViewController") as? RYTabBarViewController {
            return tabBarVC
        }
        return nil
    }
    
    // MARK: - HomePage
    private static func homePageStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "HomePage", bundle: nil)
    }
    
    static func homePageStoryboard_starter() -> RYNavigationController? {
        if let homePageNav = homePageStoryboard().instantiateViewController(withIdentifier: "RYHomePageNavigationController") as? RYNavigationController {
            return homePageNav
        }
        return nil
    }
    
    static func homePageStoryboard_homePage() -> RYHomePage? {
        if let homePage = homePageStoryboard().instantiateViewController(withIdentifier: "RYHomePage") as? RYHomePage {
            return homePage
        }
        return nil
    }
    
    // MARK: - Category
    private static func categoryStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Category", bundle: nil)
    }
    
    static func categoryStoryboard_starter() -> RYNavigationController? {
        if let categoryNav = categoryStoryboard().instantiateViewController(withIdentifier: "RYCategoryNavigationController") as? RYNavigationController {
            return categoryNav
        }
        return nil
    }
    
    static func categoryStoryboard_categoryPage() -> RYCategoryPage? {
        if let categoryPage = categoryStoryboard().instantiateViewController(withIdentifier: "RYCategoryPage") as? RYCategoryPage {
            return categoryPage
        }
        return nil
    }
    
    // MARK: - Square
    private static func squareStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Square", bundle: nil)
    }
    
    static func squareStoryboard_starter() -> RYNavigationController? {
        if let squareNav = squareStoryboard().instantiateViewController(withIdentifier: "RYSquareNavigationController") as? RYNavigationController {
            return squareNav
        }
        return nil
    }
    
    static func squareStoryboard_squarePage() -> RYSquarePage? {
        if let squarePage = squareStoryboard().instantiateViewController(withIdentifier: "RYSquarePage") as? RYSquarePage {
            return squarePage
        }
        return nil
    }
    
    // MARK: - Profile
    private static func profileStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: nil)
    }
    
    static func profileStoryboard_starter() -> RYNavigationController? {
        if let profileNav = profileStoryboard().instantiateViewController(withIdentifier: "RYProfileNavigationController") as? RYNavigationController {
            return profileNav
        }
        return nil
    }
    
    static func profileStoryboard_ProfilePage() -> RYProfilePage? {
        if let profilePage = profileStoryboard().instantiateViewController(withIdentifier: "RYProfilePage") as? RYProfilePage {
            return profilePage
        }
        return nil
    }
    
    static func preferenceStoryboard_PreferencePage() -> RYPreferencesPage? {
        if let preferencePage = profileStoryboard().instantiateViewController(withIdentifier: "RYPreferencesPage") as? RYPreferencesPage {
            return preferencePage
        }
        return nil
    }
    
    static func settingStoryboard_SettingPage() -> RYSettingPage? {
        if let settingPage = profileStoryboard().instantiateViewController(withIdentifier: "RYSettingPage") as? RYSettingPage {
            return settingPage
        }
        return nil
    }
    
    static func editingStoryboard_EditingPage() -> RYEditingPage? {
        if let editingPage = profileStoryboard().instantiateViewController(withIdentifier: "RYEditingPage") as? RYEditingPage {
            return editingPage
        }
        return nil
    }
    
    static func profileStoryboard_FavoritesPage() -> RYFavoritesListPage? {
        if let favoritePage = profileStoryboard().instantiateViewController(withIdentifier: "RYFavoritesListPage") as? RYFavoritesListPage {
            return favoritePage
        }
        return nil
    }
    
    // MARK: - WebPage
    static func webPageStoryboard_starter() -> RYNavigationController? {
        let webStoryboard = UIStoryboard(name: "WebPage", bundle: nil)
        if let starter = webStoryboard.instantiateViewController(withIdentifier: "RYNavigationController_WebPage") as? RYNavigationController {
            return starter
        }
        return nil
    }
    
    static func webPageStoryboard_webPage() -> RYWebPage? {
        let webStoryboard = UIStoryboard(name: "WebPage", bundle: nil)
        if let webPage = webStoryboard.instantiateViewController(withIdentifier: "RYWebPage") as? RYWebPage {
            return webPage
        }
        return nil
    }
    
    
    // MARK: - Search
    static func searchStoryboard_searchPage() -> RYSearchPanel? {
        let searchStoryboard = UIStoryboard(name: "Search", bundle: nil)
        if let searchPage = searchStoryboard.instantiateViewController(withIdentifier: "RYSearchPanel") as? RYSearchPanel {
            return searchPage
        }
        return nil
    }
    
    static func searchStoryboard_searchParentPage() -> RYSearchParentPage? {
        let searchStoryboard = UIStoryboard(name: "Search", bundle: nil)
        if let searchParentPage = searchStoryboard.instantiateViewController(withIdentifier: "RYSearchParentPage") as? RYSearchParentPage {
            return searchParentPage
        }
        return nil
    }
    
    // MARK: - Dishes
    /*
    static func dishesStoryboard_starter() -> RYNavigationController? {
        let dishStoryboard = UIStoryboard(name: "Dishes", bundle: nil)
        if let dishesNav = dishStoryboard.instantiateViewController(withIdentifier: "RYDishesNavigationController") as? RYNavigationController {
            return dishesNav
        }
        return nil
    }
    */
    
    static func dishStoryboard_dishPage() -> RYDishPage? {
        let dishStoryboard = UIStoryboard(name: "Dishes", bundle: nil)
        if let dishPage = dishStoryboard.instantiateViewController(withIdentifier: "RYDishPage") as? RYDishPage {
            return dishPage
        }
        return nil
    }
    
    static func dishStoryboard_dishDetailsPage() -> RYDishDetailsPage? {
        let dishStoryboard = UIStoryboard(name: "Dishes", bundle: nil)
        if let dishDetailsPage = dishStoryboard.instantiateViewController(withIdentifier: "RYDishDetailsPage") as? RYDishDetailsPage {
            return dishDetailsPage
        }
        return nil
    }
    
    // MARK: - SKill List
    static func skillStoryboard_skillDetailsPage() -> RYSkillDetailsPage? {
        let skillStoryboard = UIStoryboard(name: "Skill", bundle: nil)
        if let skillDetailsPage = skillStoryboard.instantiateViewController(withIdentifier: "RYSkillDetailsPage") as? RYSkillDetailsPage {
            return skillDetailsPage
        }
        return nil
    }
    
    // MARK: - Login
    static func loginStoryboard_loginBoardPage() -> RYLoginBoard? {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        if let loginBoardPage = loginStoryboard.instantiateViewController(withIdentifier: "RYLoginBoard") as? RYLoginBoard {
            return loginBoardPage
        }
        return nil
    }
    
    static func loginStoryboard_loginPage() -> RYLoginPage? {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        if let loginPage = loginStoryboard.instantiateViewController(withIdentifier: "RYLoginPage") as? RYLoginPage {
            return loginPage
        }
        return nil
    }
    
    static func loginStoryboard_registerPage() -> RYRegisterPage? {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        if let registerPage = loginStoryboard.instantiateViewController(withIdentifier: "RYRegisterPage") as? RYRegisterPage {
            return registerPage
        }
        return nil
    }
    
}
