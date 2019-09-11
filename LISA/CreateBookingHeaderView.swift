//
//  CreateBookingHeaderView.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/19/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class CreateBookingHeaderView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var bookingLabelView: UILabel!
    
    var labelText: String? {
        get {
            return bookingLabelView.text
        }
        set {
            bookingLabelView.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
//        self.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        Bundle.main.loadNibNamed("CreateBookingHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let gradient = CAGradientLayer.appStyleGradient()
        gradient.frame = contentView.bounds
        contentView.layer.insertSublayer(gradient, at: 0)
        
        bookingLabelView.textColor = .white
    }
}
