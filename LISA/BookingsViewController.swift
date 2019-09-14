//
//  BookingsViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/22/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import IGListKit
import PKHUD

class BookingsViewController: UIViewController, ListAdapterDataSource, BookingsSectionControllerDelegate {
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    var notLoggedInView: SettingsNotLoggedInView! = {
        let view = SettingsNotLoggedInView()
        view.notLoggedInMessageLabel.text = "Please sign in to access your Bookings."
        view.frame = .zero
        return view
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var bookings: [Booking]? {
        didSet {
            let title = Title(text: "Bookings")
            data = [title]
            guard let bookings = bookings, bookings.count > 0 else {
                data?.append(Description(text: "You haven't made a booking yet! Your history will be displayed here."))
                adapter.performUpdates(animated: true, completion: nil)
                return
            }
            
            let sortedBookings = bookings.sorted { $0.datetimeRequested > $1.datetimeRequested }
            self.bookings = sortedBookings
            
            let bookingModels = sortedBookings.map {
                return BookingModel(withBooking: $0)
            }
            
            data = [title, BookingModelCollection(bookingModels: bookingModels)]
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    var loginDetails: LoginDetails? = nil
    
    var data: [Any]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 50)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        collectionView.collectionViewLayout = layout
        
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    // temp
    override func viewWillAppear(_ animated: Bool) {
//        data = [Title(text: "Bookings")]
//        adapter.performUpdates(animated: false, completion: nil)
        guard let login = CombinedUserInformation.shared.loginDetails() else {
            loginDetails = nil
            setupLogInView()
            return
        }
        
        loginDetails = login
        refreshBookings()
    }
    
    func setupLogInView() {
        self.navigationController?.view.addSubview(notLoggedInView)
        notLoggedInView.frame = view.frame
        notLoggedInView.signInOrRegisterButton.addTarget(self, action: #selector(signInOrRegisterTapped(sender:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func signInOrRegisterTapped(sender: Any) {
        let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginController")
        present(signInVC, animated: true, completion: nil)
    }

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let data = data else { return [] }
        return data.map { $0 as! ListDiffable }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is Title: return BookingHeadlineSectionController()
        case is Description: return DescriptionSectionController()
        case is BookingModelCollection:
            let bookingsSectionController = BookingsSectionController()
            bookingsSectionController.delegate = self
            return bookingsSectionController
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
    
    func didSelectBooking(atIndex index: Int) {
        guard let bookings = bookings else { return }
        let booking = bookings[index]
        
        if booking.status == "created" || booking.status == "assigned" || booking.status == "partner_cancelled" {
            let actionSheet = UIAlertController(title: nil, message: "Would you like to cancel your booking?", preferredStyle: .actionSheet)
            let cancelBookingAction = UIAlertAction(title: "Yes, cancel it", style: .destructive) { [unowned self] (_) in
                self.cancelBooking(atIndex: index)
            }
            let cancelDialogAction = UIAlertAction(title: "No, go back", style: .cancel, handler: nil)
            actionSheet.addAction(cancelBookingAction)
            actionSheet.addAction(cancelDialogAction)
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func cancelBooking(atIndex index: Int) {
        guard let bookings = bookings else {
            return
        }
        
        HUD.show(.progress)
        let cancelRequest = NetworkRequest(url: URL(string: AppAPIBase.CancelBookingPath(forId: bookings[index].id))!, method: .POST, data: nil, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()!.accessToken))
        cancelRequest.execute { [unowned self] (data) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            guard let data = data, let updatedBooking = try? decoder.decode(Booking.self, from: data) else {
                HUD.flash(.error)
                self.displayAlertWithOK(title: "Unable to cancel booking", body: "Please make sure you have a working internet connection")
                return
            }
            
            DispatchQueue.main.async {
                HUD.flash(.success)
                self.bookings![index] = updatedBooking
                self.adapter.performUpdates(animated: false, completion: nil)
            }
        }
    }
    
}

final class BookingModelCollection: NSObject {
    let bookingModels: [BookingModel]
    
    init(bookingModels: [BookingModel]) {
        self.bookingModels = bookingModels
        super.init()
    }
}

extension BookingModelCollection: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}


final class BookingModel: NSObject {
    let status: String
    let startTime: String
    let durationInMinutes: Int
    let address: String
    let cleanerName: String?
    let totalAmount: String
    
    
    init(withBooking booking: Booking) {
        self.status = booking.sanitizedStatus()
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a - MMM dd, yyyy"
        self.startTime = formatter.string(from: booking.datetimeRequested)
        
        
        self.durationInMinutes = booking.durationInMinutes
        self.address = booking.address.concatenatedAddress()
        self.cleanerName = booking.cleanerName
        self.totalAmount = String(format: "‎₱ %.2f", booking.totalAmount)
        
        super.init()
    }
}

extension BookingModel: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}

final class BookingsSectionController: ListSectionController {
    private var object: BookingModelCollection?
    
    var delegate: BookingsSectionControllerDelegate? = nil
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20)
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
    }
    
    override func numberOfItems() -> Int {
        return object?.bookingModels.count ?? 0
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
//        guard let cell = collectionContext?.dequeueReusableCell(of: FullWidthSelfSizingCell.self, for: self, at: index) as? FullWidthSelfSizingCell else {
//            fatalError()
//        }
        
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "BookingCollectionViewCell", bundle: nil, for: self, at: index) as? BookingCollectionViewCell else {
            fatalError()
        }
        
        let bookingModel = object!.bookingModels[index]
        
        cell.serviceType = "House Cleaning"
        cell.dateTime = bookingModel.startTime
        cell.address = bookingModel.address
        cell.status = bookingModel.status.uppercased()
        cell.totalAmount = bookingModel.totalAmount
        cell.cleanerName = bookingModel.cleanerName ?? "Cleaner to be assigned"
        
        if bookingModel.status == "Cancelled" {
            cell.cleanerName = bookingModel.cleanerName ?? "No cleaner assigned"
            cell.statusLabel.backgroundColor = UIColor(named: "Berry")
            cell.contentView.alpha = 0.5
        } else if bookingModel.status == "Completed" {
            cell.contentView.alpha = 1.0
            cell.statusLabel.backgroundColor = UIColor(named: "DarkLISA")
        } else if bookingModel.status == "Created" {
            cell.contentView.alpha = 1.0
            cell.statusLabel.backgroundColor = UIColor(named: "Sunshine")
        } else {
            cell.contentView.alpha = 1.0
            cell.statusLabel.backgroundColor = UIColor(named: "Royal")
        }
        
//
//        cell.statusLabel.layer.cornerRadius = cell.statusLabel.frame.height / 2
//        cell.statusLabel.clipsToBounds = true
        
        cell.backgroundColor = UIColor(named: "BookingCellBackground")!
        cell.layer.cornerRadius = 10
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.65
        cell.layer.shadowOffset = CGSize(width: 0, height: 6)
        
        
        
//        cell.text = object?.bookingModels[index].status ?? "undefined"
//        cell.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return cell

    }
    
    override func didUpdate(to object: Any) {
        self.object = object as? BookingModelCollection
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - 30, height: 180)
    }
    
    override func didSelectItem(at index: Int) {
        delegate?.didSelectBooking(atIndex: index)
    }
}

protocol BookingsSectionControllerDelegate: class {
    func didSelectBooking(atIndex index: Int)
}


final class BookingHeadlineSectionController: ListSectionController {
    private var model: Title!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 5)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let text = model
        guard let cell = collectionContext?.dequeueReusableCell(of: HeadlineFullWidthSelfSizingCell.self, for: self, at: index) as? HeadlineFullWidthSelfSizingCell else {
            fatalError()
        }
        
        cell.text = text?.text
        cell.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.model = object as? Title
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
}
