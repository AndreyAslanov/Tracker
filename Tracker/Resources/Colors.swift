//
//  Colors.swift
//  Tracker
//
//  Created by Андрей Асланов on 29.11.23.
//

import UIKit

final class Colors {
    let viewBackgroundColor = UIColor.mainColor
    let navigationBarTintColor = UIColor.mainColor
    let tabBarBackgroundColor = UIColor.mainColor
    let collectionViewBackgroundColor = UIColor.mainColor
    
//    var navigationBarTintColor: UIColor = UIColor { (traits) -> UIColor in
//        let isDarkMode = traits.userInterfaceStyle == .dark
//        return isDarkMode ? UIColor.black : UIColor.white
//    }
//
//    var tabBarBackgroundColor: UIColor = UIColor { (traits) -> UIColor in
//        let isDarkMode = traits.userInterfaceStyle == .dark
//        return isDarkMode ? UIColor.black : UIColor.white
//    }
//
//    var collectionViewBackgroundColor: UIColor {
//        return UIColor { (traits) -> UIColor in
//            let isDarkMode = traits.userInterfaceStyle == .dark
//            return isDarkMode ? UIColor.black : UIColor.white
//        }
//    }
    
    var labelTextColor: UIColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? UIColor.white : UIColor.black
    }
    
    static var backgroundLight = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? UIColor.white: UIColor.white
    }
    
    func searchTextFieldColor() -> UIColor {
        return UIColor { (traits) -> UIColor in
            let isDarkMode = traits.userInterfaceStyle == .dark
            return isDarkMode ? UIColor.white : UIColor.gray
        }
    }
    func searchControllerTextFieldPlaceholderAttributes() -> [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: searchTextFieldColor(),
            
        ]
    }
    var filterViewBackgroundColor: UIColor {
        return UIColor { (traits) -> UIColor in
            let isDarkMode = traits.userInterfaceStyle == .dark
            return isDarkMode ? UIColor.backgroundDark : UIColor.darkBackground
        }
    }
}
