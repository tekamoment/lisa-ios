//
//  BaseRoundedCardCell.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/1/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import CoreMotion

class BaseRoundedCardCell: UICollectionViewCell {
    internal static let cellHeight: CGFloat = 470.0
    
    private static let kInnerMargin: CGFloat = 20.0
    
    // Core Motion manager -- for doing the shadows
    private let motionManager = CMMotionManager()
    
    // Shadow View
    private weak var shadowView: UIView?
    
    override func awakeFromNib() {
        self.contentView.autoresizingMask.insert(.flexibleHeight)
        self.contentView.autoresizingMask.insert(.flexibleWidth)
    }
    
    override func layoutSubviews() {
        configureShadow()
    }
    
    private func configureShadow() {
        // Shadow View
        self.shadowView?.removeFromSuperview()
        let shadowView = UIView(frame: CGRect(x: BaseRoundedCardCell.kInnerMargin,
                                              y: BaseRoundedCardCell.kInnerMargin,
                                              width: bounds.width - (2 * BaseRoundedCardCell.kInnerMargin),
                                              height: bounds.height - (2 * BaseRoundedCardCell.kInnerMargin)))
        insertSubview(shadowView, at: 0)
        self.shadowView = shadowView
        
        // Roll/Pitch Dynamic Shadow
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
                if let motion = motion {
                    let pitch = motion.attitude.pitch * 10 // x-axis
                    let roll = motion.attitude.roll * 10 // y-axis
                    self.applyShadow(width: CGFloat(roll), height: CGFloat(pitch))
                }
            })
        }
    }
    
    private func applyShadow(width: CGFloat, height: CGFloat) {
        if let shadowView = shadowView {
            let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 14.0)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowRadius = 8.0
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: width, height: height)
            shadowView.layer.shadowOpacity = 0.35
            shadowView.layer.shadowPath = shadowPath.cgPath
        }
    }
}
