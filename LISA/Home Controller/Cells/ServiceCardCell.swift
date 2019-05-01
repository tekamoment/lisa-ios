//
//  ServiceCardCell.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/1/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class ServiceCardCell: BaseRoundedCardCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    internal static let reuseIdentifier = "ServiceCardCell"
    
    internal static func dequeue(fromCollectionView collectionView: UICollectionView, identifier: String, atIndexPath indexPath: IndexPath) -> ServiceCardCell {
        guard let cell: ServiceCardCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ServiceCardCell else {
            fatalError("*** Failed to dequeue ServiceCardCell ***")
        }
        return cell
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.setNeedsUpdateConstraints()
        self.layer.cornerRadius = 14.0
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

}
