//
//  SettingsNotLoggedInView.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/17/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class SettingsNotLoggedInView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var notLoggedInMessageLabel: UILabel!
    @IBOutlet weak var signInOrRegisterButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SettingsNotLoggedInView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
