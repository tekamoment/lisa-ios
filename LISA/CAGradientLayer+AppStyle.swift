//
//  CAGradientLayer+AppStyle.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/1/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    static func appStyleGradient() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(named: "GradientLight")!.cgColor, UIColor(named: "GradientDark")!.cgColor]
        return gradientLayer
    }
}
