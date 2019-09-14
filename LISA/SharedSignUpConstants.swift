//
//  SharedSignUpConstants.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/15/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

struct SharedSignUpConstants {
    static let sharedFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let sharedColor = UIColor(red: 56.0/255, green: 56.0/255, blue: 56.0/255, alpha: 0.3)
    static let sharedLeftRect = CGRect(x: 0, y: 0, width: 15, height: 20)
    
    static func setDefaultStylingFieldFor( _ textField: inout UITextField) {
        textField.backgroundColor = .white
        textField.font = SharedSignUpConstants.sharedFont
        
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.backgroundColor = SharedSignUpConstants.sharedColor.cgColor
        textField.textColor = .white
        textField.tintColor = .white
        
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [.foregroundColor : UIColor.init(white: 0.75, alpha: 1)])
        
        let paddingView = UIView(frame: SharedSignUpConstants.sharedLeftRect)
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
//    static
}
