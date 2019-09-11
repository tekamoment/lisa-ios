//
//  ServiceFeatureViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/23/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import IGListKit

class ServiceFeatureViewController: UIViewController, ListAdapterDataSource {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 50)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    var data: [Any]? = nil
    
    var serviceFeature: ServiceFeature? {
        didSet {
            guard let serviceFeature = serviceFeature else { return }
            let title = Title(text: serviceFeature.title)
            let description = Description(text: serviceFeature.description)
            data = [title, description]
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let data = data else { return [] }
        return data.map { $0 as! ListDiffable }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is Title: return HeadlineSectionController()
        case is Description: return DescriptionSectionController()
        default: return SelfSizingSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
