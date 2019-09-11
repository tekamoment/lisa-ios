//
//  HomeViewController+CollectionView.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/1/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

extension HomeViewController {
    internal func configure(collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "HomeSectionHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeSectionHeaderCollectionReusableView.reuseIdentifier)
        collectionView.register(UINib(nibName: "ServiceCardCell", bundle: nil), forCellWithReuseIdentifier: ServiceCardCell.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        Temporary, will eventually have to connect to
//        the number of sections returned from the API call
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let serviceCell = ServiceCardCell.dequeue(fromCollectionView: collectionView, identifier: ServiceCardCell.reuseIdentifier, atIndexPath: indexPath)
        
        // temporary
        serviceCell.imageView.image = #imageLiteral(resourceName: "CleaningServiceImage")
        serviceCell.label.text = "ROOM CLEANING"
        
        //gradient layer
        let gradientLayer = CAGradientLayer.appStyleGradient()
        
        //define frame
        gradientLayer.frame = serviceCell.bounds
        
        //insert the gradient layer to the view layer
        serviceCell.layer.insertSublayer(gradientLayer, at: 0)
        
        return serviceCell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 40, height: BaseRoundedCardCell.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: HomeSectionHeaderCollectionReusableView.viewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionViewHeader = HomeSectionHeaderCollectionReusableView.dequeue(fromCollectionView: collectionView, identifier: HomeSectionHeaderCollectionReusableView.reuseIdentifier, ofKind: UICollectionView.elementKindSectionHeader, atIndexPath: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        sectionViewHeader.dateLabel.text = dateFormatter.string(from: Date()).uppercased()
        sectionViewHeader.dateLabel.font = UIFont.systemFont(ofSize: sectionViewHeader.dateLabel.font.pointSize, weight: .heavy)
        sectionViewHeader.dateLabel.textColor = UIColor.init(white: 0.5, alpha: 1)

        sectionViewHeader.accountNameLabel.text = "Welcome to LISA!"
//        if let baseProfile = CombinedUserInformation.shared.baseProfile() {
//            sectionViewHeader.accountNameLabel.text = "Welcome, \(baseProfile.fullName)!"
//        } else {
//            sectionViewHeader.accountNameLabel.text = "Welcome to LISA!"
//        }
        
        // modify shit if needed
        return sectionViewHeader
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Did select the cell.
        guard let _ = services else {
            displayAlertWithOK(title: "Information loading", body: "Service information is still loading.")
            return
        }
        self.performSegue(withIdentifier: "showService", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showService" {
            if let indexPaths = collectionView.indexPathsForSelectedItems {
                let serviceVC = segue.destination as! ServiceViewController
                serviceVC.service = services?[indexPaths.first!.row]
            }
        }
    }
}

extension UITabBarController {
    func cleanTitles() {
        guard let items = self.tabBar.items else {
            return
        }
        for item in items {
            item.title = ""
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }
}

