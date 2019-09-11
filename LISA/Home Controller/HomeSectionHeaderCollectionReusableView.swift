//
//  HomeSectionHeaderCollectionReusableView.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/1/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class HomeSectionHeaderCollectionReusableView: UICollectionReusableView {

    internal static let reuseIdentifier = "HomeSectionHeader"
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    internal static func dequeue(fromCollectionView collectionView: UICollectionView, identifier: String, ofKind kind: String, atIndexPath indexPath: IndexPath) -> HomeSectionHeaderCollectionReusableView {
        guard let view: HomeSectionHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? HomeSectionHeaderCollectionReusableView else {
            fatalError("*** Failed to dequeue HomeSectionHeader ***")
        }
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
