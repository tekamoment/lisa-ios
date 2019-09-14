//
//  BookingsListViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/19/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import IGListKit
import AlignedCollectionViewFlowLayout

class BookingsListViewController: UIViewController, ListAdapterDataSource {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    let collectionView: UICollectionView = {
        //        let layout = UICollectionViewFlowLayout()
        let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .justified, verticalAlignment: .top)
        layout.estimatedItemSize = CGSize(width: 100, height: 50)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        if #available(iOS 13, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        return collectionView
    }()
    
    var bookings: [Booking]? {
        didSet {
            let title = Title(text: "Bookings")
            data = [title]
            guard let bookings = bookings else {
                data?.append(Description(text: "You haven't made a booking yet! Your history will be displayed here."))
                adapter.performUpdates(animated: true, completion: nil)
                return
            }
            
            data = [title] + bookings
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    var loginDetails: LoginDetails? = nil
    
    var data: [Any]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshBookings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let data = data else { return [] }
        return data.map {$0 as! ListDiffable}
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
    
    @objc func refreshBookings() {
        guard let loginDetails = loginDetails else {
            bookings = nil
            return
        }
        let bookingRequest = NetworkRequest(url: URL(string: AppAPIBase.BookingsPath)!, method: .GET, data: nil, headers: AppAPIBase.standardHeaders(withToken: loginDetails.accessToken))
        bookingRequest.execute { (data) in
            guard let data = data else {
                self.displayAlertWithOK(title: "Fetching error", body: "Looks like there was an error fetching the bookings.")
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            if let bookings = try? jsonDecoder.decode([Booking].self, from: data) {
                self.bookings = bookings
            } else {
                self.bookings = nil
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}




