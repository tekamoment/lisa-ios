//
//  BookingCollectionViewCell.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/23/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class BookingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var serviceTypeLabel: UILabel!
    @IBOutlet weak var cleanerNameLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: PillUILabel!
    
    var serviceType: String? {
        get {
            return serviceTypeLabel.text
        }
        set {
            serviceTypeLabel.text = newValue
        }
    }
    
    var cleanerName: String? {
        get {
            return cleanerNameLabel.text
        }
        set {
            cleanerNameLabel.text = newValue
        }
    }
    
    var dateTime: String? {
        get {
            return dateTimeLabel.text
        }
        set {
            dateTimeLabel.text = newValue
        }
    }
    
    var totalAmount: String? {
        get {
            return totalAmountLabel.text
        }
        set {
            totalAmountLabel.text = newValue
        }
    }
    
    var address: String? {
        get {
            return addressLabel.text
        }
        set {
            addressLabel.text = newValue
        }
    }
    
    var status: String? {
        get {
            return statusLabel.text
        }
        
        set {
            statusLabel.text = newValue
        }
    }
}
