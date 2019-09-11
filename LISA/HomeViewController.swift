//
//  HomeViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/1/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var services: [Service]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchServices()
        configure(collectionView: collectionView)
        
        
        let tabBar = self.tabBarController!.tabBar
//        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: UIColor(named: "LISABlue")!, size: CGSize(width: ceil(tabBar.frame.width / CGFloat(tabBar.items!.count)), height: tabBar.frame.height - 1), lineWidth: 2.5).resizableImage(withCapInsets: .zero)
        self.tabBarController?.cleanTitles()
    }
}

extension HomeViewController {
    func fetchServices() {
        let serviceRequest = NetworkRequest(url: URL(string: AppAPIBase.ServicesPath)!, method: .GET, data: nil, headers: nil)
        serviceRequest.execute { [weak self] (data) in
            guard let data = data else {
                return
            }
            
            let jsonDecoder = JSONDecoder()
            self?.services = try? jsonDecoder.decode([Service].self, from: data)
        }
    }
}


class MiddleButtonTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 1
        setupMiddleButton()
    }
    
    func setupMiddleButton() {
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 88, height: 88))
        
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height - (tabBar.bounds.height / 2)
        menuButtonFrame.origin.x = view.bounds.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame
        
//        menuButton.backgroundColor = UIColor(named: "LISABlue")
        menuButton.backgroundColor = .white
        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        
//        menuButton.layer.shadowColor = UIColor(named: "LISABlue")!.cgColor
        menuButton.layer.shadowColor = UIColor.black.cgColor
        menuButton.layer.shadowOpacity = 0.4
        menuButton.layer.shadowRadius = 3.5
        menuButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        menuButton.layer.masksToBounds = false
        
        view.addSubview(menuButton)
        
        menuButton.setImage(UIImage(named: "SmallLogoSquare")?.withRenderingMode(.alwaysOriginal), for: .normal)
        menuButton.imageView?.tintColor = .white
        menuButton.tintColor = .white
        menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }
    
    func updateSelectionIndicatorImage() {
        guard let selectedItem = tabBar.selectedItem, let index = tabBar.items?.firstIndex(of: selectedItem) else { return }
        
        switch index {
        case Int(ceil(Double(self.tabBar.items!.count / 2))):
            tabBar.selectionIndicatorImage = nil
            
        default:
            tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: UIColor(named: "LISABlue")!, size: CGSize(width: ceil(tabBar.frame.width / CGFloat(tabBar.items!.count)), height: tabBar.frame.height - 1), lineWidth: 2.5).resizableImage(withCapInsets: .zero)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        super.tabBar(tabBar, didSelect: item)
        updateSelectionIndicatorImage()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectionIndicatorImage()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateSelectionIndicatorImage()
    }
    
    
    @objc private func menuButtonAction(sender: UIButton) {
        selectedIndex = Int(ceil(Double(self.tabBar.items!.count / 2)))
        updateSelectionIndicatorImage()
    }
}
