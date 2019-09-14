//
//  UIViewController+AdditionalInsets.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/16/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

extension UIViewController {
    func setAdditionalBottomInsetsIfNeeded() {
        if UIApplication.shared.keyWindow?.safeAreaInsets.bottom == 0 {
            additionalSafeAreaInsets.bottom = 24.0
        }
    }
    
    func offsetValueForTabBarActiveIndicator() -> CGFloat {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }
    
    func displayAlertWithOK(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension UIImage {
    func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: lineWidth))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
