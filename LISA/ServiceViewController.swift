//
//  ServiceViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/9/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import IGListKit

final class ServiceViewController: UIViewController, ListAdapterDataSource {
    
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
    
    var service: Service? {
        didSet {
            guard let service = service else { return }
            let title = Title(text: service.title)
            
            let basePrice = Subtitle(text: "₱ 499 for 2 hours", color: UIColor(named: "LISABlue")!)
            
            let tidbitCollection = TidbitCollection(tidbits: [Tidbit(iconName: nil, text: "Working Hours:\nMondays - Fridays"), Tidbit(iconName: nil, text: "Available Hours:\n09:00 am - 05:00 pm")])
//            let tidbitCollection = TidbitCollection(tidbits: [Tidbit(iconName: "clock", text: "09:00 am - 05:00 pm"), Tidbit(iconName: "calendar", text: "Mondays - Fridays"), Tidbit(iconName: "money-bill-alt", text: "₱499 for 2 hours"), Tidbit(iconName: "money-bill-alt", text: "₱100 per extra hour")])
            
            let description = Description(text: service.description)
            let serviceFeatures = service.features.map { (servFeat)  in
                return ServiceFeatureCollectionModel(featureId: servFeat.id, title: servFeat.title, featureDescription: servFeat.description, placeholderImage: UIImage(named: "FullLogo")!, mainPhoto: URL(string: servFeat.mainPhotoURL ?? ""), secondaryPhoto:  URL(string: servFeat.secondaryPhotoURL ?? ""))
//                ServiceFeatureListModel(serviceFeature: servFeat)
            }
            let buttonModel = ButtonModel(text: "BOOK")
            
            var subheadingColor: UIColor
            
            if #available(iOS 13, *) {
                subheadingColor = .label
            } else {
                subheadingColor = .black
            }
            
            
            let whatToExpectModel = Subheading(text: "What to expect", color: subheadingColor)
            data = [title, basePrice, tidbitCollection, buttonModel, description, whatToExpectModel, ServiceFeatureCollection(serviceFeatures: serviceFeatures)]
//            data = [title, tidbitCollection, buttonModel, description, featureModel, ServiceFeatureList(serviceFeatures: serviceFeatures)]
            adapter.performUpdates(animated: false, completion: nil)
        }
    }
    
    var data: [Any]? = nil

    var shouldDismissForBookingHistory = false
    
    
    let saveButton: UIButton = {
        var saveButton  = UIButton(type: UIButton.ButtonType.system) as UIButton
        saveButton.setTitle("X", for: .normal)
        saveButton.titleLabel?.textColor = .black
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        saveButton.tintColor = .black
        return saveButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    @objc func buttonAction(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldDismissForBookingHistory {
            if let presentingVC = self.presentingViewController as? MiddleButtonTabBarController {
                dismiss(animated: true) {
                    presentingVC.selectedIndex = 2
                }
            }
        }
        
        guard #available(iOS 13, *) else {
            saveButton.addTarget(self, action: #selector(buttonAction(sender:)), for: UIControl.Event.touchUpInside)
            saveButton.frame = CGRect(x: self.view.frame.width - 60, y: 45, width: 35, height: 35)
            saveButton.layer.backgroundColor = UIColor(white: 0.5, alpha: 0.5).cgColor
            saveButton.layer.cornerRadius =  (saveButton.frame.size.height) / 2
            saveButton.layer.masksToBounds = true;
            saveButton.isUserInteractionEnabled = true
            saveButton.alpha = 0
            UIApplication.shared.keyWindow?.addSubview(saveButton)
            return
        }
        
        
        
//        saveButton.frame = CGRect(x: view.frame.size.width - 80 , y: view.frame.size.height - 130, width: 60, height: 60)
//        UIApplication.shared.keyWindow?.addSubview(self.saveButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.saveButton.alpha = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.saveButton.removeFromSuperview()
        self.saveButton.removeFromSuperview()
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
        case is Subtitle: return SubtitleSectionController()
        case is Description: return DescriptionSectionController()
        case is ButtonModel:
            let controller = ButtonSectionController()
            controller.delegate = self
            return controller
//        case is TidbitCollection: return LeftAlignedTidbitSectionController()
        case is TidbitCollection: return TidbitSectionController()
//        case is ServiceFeatureCollection: return ServiceFeatureCollectionSectionController()
//        case is ServiceFeatureList: return ServiceFeatureListContainerSectionController()
        case is ServiceFeatureCollection: return ServiceFeatureListContainerSectionController()
        case is Subheading: return SubheadingSectionController()
        default: return SelfSizingSectionController()
        }
//        return SelfSizingSectionController()
    }
    
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "showCreateBooking" {
            guard let service = service else {
                return
            }
            let destNavVC = segue.destination as! UINavigationController
            let destVC = destNavVC.topViewController as! CreateBookingFormViewController
            destVC.service = service
        }
    }

}

extension ServiceViewController: ButtonSectionControllerDelegate {
    func buttonTapped(sectionController: ButtonSectionController) {
        if CombinedUserInformation.shared.loginDetails() == nil {
            let signInController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginController")
            present(signInController, animated: true, completion: nil)
        } else {
//            displayAlertWithOK(title: "Coming soon!", body: "Booking screen will come in the next mini-build! \n- Carlos")
            performSegue(withIdentifier: "showCreateBooking", sender: nil)
        }
    }
}


// will move out


final class HeadlineSectionController: ListSectionController {
    private var model: Title!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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

final class SubtitleSectionController: ListSectionController {
    private var model: Subtitle!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let text = model
        guard let cell = collectionContext?.dequeueReusableCell(of: SubtitleFullWidthSelfSizingCell.self, for: self, at: index) as? SubtitleFullWidthSelfSizingCell else {
            fatalError()
        }
        cell.text = text?.text
        cell.textColor = text?.color
        cell.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.model = object as? Subtitle
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
}


final class SubheadingSectionController: ListSectionController {
    private var model: Subheading!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let text = model
        guard let cell = collectionContext?.dequeueReusableCell(of: FullWidthSelfSizingCell.self, for: self, at: index) as? FullWidthSelfSizingCell else {
            fatalError()
        }
        
        cell.text = text?.text
        cell.textColor = text?.color
        cell.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.model = object as? Subheading
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
}


final class DescriptionSectionController: ListSectionController {
    private var model: Description!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 1
        minimumInteritemSpacing = 1
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let text = model
        guard let cell = collectionContext?.dequeueReusableCell(of: FullWidthSelfSizingCell.self, for: self, at: index) as? FullWidthSelfSizingCell else {
            fatalError()
        }
        
        cell.text = text?.text
        cell.font = UIFont.systemFont(ofSize: 16.0)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.model = object as? Description
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
}

final class TidbitSectionController: ListSectionController {
    private var model: TidbitCollection!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 1
        minimumInteritemSpacing = 1
    }
    
    override func numberOfItems() -> Int {
        return model.tidbits.count
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
//        let text = model
        guard let cell = collectionContext?.dequeueReusableCell(of: TidbitFullWidthSelfSizingCell.self, for: self, at: index) as? TidbitFullWidthSelfSizingCell else {
            fatalError()
        }
        
        cell.attributedText = model.tidbits[index].attributedString
        cell.font = UIFont.systemFont(ofSize: 16.0)
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.model = object as? TidbitCollection
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
    
//    override func sizeForItem(at index: Int) -> CGSize {
//        return CGSize(width: collectionContext!.containerSize.width, height: 55)
//    }
//
//    override func cellForItem(at index: Int) -> UICollectionViewCell {
//        let attributedText = model.tidbits[index].attributedString
//        guard let cell = collectionContext?.dequeueReusableCell(of: ManuallySelfSizingCell.self, for: self, at: index) as? ManuallySelfSizingCell else {
//            fatalError()
//        }
//
//        cell.attributedText = attributedText
//        return cell
//    }
//
//    override func didUpdate(to object: Any) {
//        self.model = object as? TidbitCollection
//    }
//}

}


import AlignedCollectionViewFlowLayout

// adapts Horizontal View Controller
final class LeftAlignedTidbitSectionController: ListSectionController, ListAdapterDataSource {
    
    private var tidbitCollection: TidbitCollection!
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.dataSource = self
        return adapter
    }()
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { return .zero }
        return CGSize(width: width, height: collectionContext?.containerSize.height ?? 0)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: EmbeddedCollectionViewCell.self,
                                                                for: self,
                                                                at: index) as? EmbeddedCollectionViewCell else {
                                                                    fatalError()
        }
        adapter.collectionView = cell.collectionView
        
        
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        alignedFlowLayout.estimatedItemSize = CGSize(width: 100, height: 50)
        cell.collectionView.collectionViewLayout = alignedFlowLayout
        return cell
    }
    
    override func didUpdate(to object: Any) {
        tidbitCollection = object as? TidbitCollection
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let tidbitCollection = tidbitCollection else { return [] }
        return [tidbitCollection as ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return TidbitSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }

}




class DynamicHeightCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.size.equalTo(self.intrinsicContentSize){
            self.invalidateIntrinsicContentSize()
        }
    }
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}



final class EmbeddedCollectionViewCell: UICollectionViewCell {

    lazy var collectionView: DynamicHeightCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
//        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let view = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = true
//        self.contentView.addSubview(view)
        
        view.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.frame
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
        } else {
            contentView.backgroundColor = .white
        }
        
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint(item: collectionView,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 15).isActive = true
//                            constant: 0).isActive = true
        NSLayoutConstraint(item: collectionView,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 15).isActive = true
//                            constant: 0).isActive = true/
        NSLayoutConstraint(item: contentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: collectionView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 15).isActive = true
//                            constant: 0).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: collectionView,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 15).isActive = true
//                            constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = collectionView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        // note: don't change the width
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
//

final class ButtonSectionController: ListSectionController, FullWidthButtonCellDelegate {
    private var model: ButtonModel!
    weak var delegate: ButtonSectionControllerDelegate? = nil
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 0
        minimumLineSpacing = 0
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let text = model?.text
        guard let buttonCell = collectionContext?.dequeueReusableCell(of: FullWidthButtonCell.self, for: self, at: index) as? FullWidthButtonCell else {
            fatalError()
        }
        
        buttonCell.text = text
        buttonCell.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        buttonCell.delegate = self
        return buttonCell
    }
    
    override func didUpdate(to object: Any) {
        self.model = object as? ButtonModel
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 100)
    }
    
    func didTapButton(cell: FullWidthButtonCell) {
        delegate?.buttonTapped(sectionController: self)
    }
}

protocol ButtonSectionControllerDelegate: class {
    func buttonTapped(sectionController: ButtonSectionController)
}


final class SelfSizingSectionController: ListSectionController {
    private var model: String!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }
    
    // temp
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let text = model
        let cell: UICollectionViewCell
        guard let manualCell = collectionContext?.dequeueReusableCell(of: FullWidthSelfSizingCell.self, for: self, at: index) as? FullWidthSelfSizingCell else {
            fatalError()
        }
        manualCell.text = text
        cell = manualCell
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.model = object as? String
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 55)
    }
}


final class ServiceFeatureListContainerSectionController: ListSectionController, ListAdapterDataSource {
    private var serviceFeatureList: ServiceFeatureCollection!
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.dataSource = self
        return adapter
    }()
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 4
        minimumInteritemSpacing = 4
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
//        guard let width = collectionContext?.containerSize.width else { return .zero }
        return CGSize(width: collectionContext!.containerSize.width, height: 550)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: EmbeddedStandardCollectionViewCell.self,
                                                                for: self,
                                                                at: index) as? EmbeddedStandardCollectionViewCell else {
                                                                    fatalError()
        }
        adapter.collectionView = cell.collectionView
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        cell.collectionView.isPagingEnabled = true
        cell.collectionView.collectionViewLayout = layout
        return cell
    }
    
    override func didUpdate(to object: Any) {
        serviceFeatureList = object as? ServiceFeatureCollection
    }
    
    // MARK: ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let serviceFeatureList = serviceFeatureList else { return [] }
        return [serviceFeatureList as ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ServiceFeatureContainerSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}


final class ServiceFeatureContainerSectionController: ListSectionController {
    private var model: ServiceFeatureCollection!
    var idsArray = [Int]()
    var placeholderImages: [Int: UIImage] = [Int: UIImage]()
    var headlineImages: [Int: UIImage?] = [Int: UIImage?]()
    var descriptionImages: [Int: UIImage?] = [Int: UIImage?]()
    
    private let insetValue: CGFloat = 30
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: insetValue / 2, bottom: 0, right: insetValue / 2)
        minimumLineSpacing = insetValue
        minimumInteritemSpacing = insetValue
    }
    
    override func numberOfItems() -> Int {
        return model.serviceFeatures.count
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "ServiceFeatureCardCollectionViewCell", bundle: nil, for: self, at: index) as? ServiceFeatureCardCollectionViewCell else {
            fatalError()
        }

        if #available(iOS 13, *) {
            cell.backgroundColor = .systemBackground
        } else {
            cell.backgroundColor = .white
        }
        
        let serviceFeatureModel = model.serviceFeatures[index]
        
        cell.headlineLabel.text = serviceFeatureModel.title
        cell.descriptionLabel.text = serviceFeatureModel.featureDescription
        
        let featureId = idsArray[index]
        cell.mainPhotoView.image = headlineImages[featureId] ?? placeholderImages[featureId] ?? nil
        cell.secondaryPhotoView.image = descriptionImages[featureId] ?? placeholderImages[featureId] ?? nil
        
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.75
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - insetValue, height: collectionContext!.containerSize.height - 30)
    }
    
    override func didUpdate(to object: Any) {
        model = object as? ServiceFeatureCollection
        
        guard let collection = self.model else {
            return
        }
        
        for feature in collection.serviceFeatures {
            idsArray.append(feature.featureId)
            placeholderImages[feature.featureId] = feature.placeholderImage
            headlineImages[feature.featureId] = nil
            descriptionImages[feature.featureId] = nil
        }
        
        for (index, feature) in collection.serviceFeatures.enumerated() {
            if let mainPhotoURL = feature.mainPhotoURL {
                let headlineImageRequest = NetworkRequest(url: mainPhotoURL, method: .GET, data: nil, headers: nil)
                
                DispatchQueue.global(qos: .utility).async { [weak self] in
                    headlineImageRequest.execute { (data) in
                        guard let data = data, let photo = UIImage(data: data), let self = self else {
                            return
                        }
                        
                        self.collectionContext?.performBatch(animated: false, updates: { (batchContext) in
                            self.headlineImages[feature.featureId] = photo
                            batchContext.reload(in: self, at: IndexSet(integer: index))
                        }, completion: nil)
                        
                    }
                }
            }
            
            if let secondaryPhotoURL = feature.secondaryPhotoURL {
                let secondaryImageRequest = NetworkRequest(url: secondaryPhotoURL, method: .GET, data: nil, headers: nil)
                
                DispatchQueue.global(qos: .utility).async { [weak self] in
                    secondaryImageRequest.execute { (data) in
                        guard let data = data, let photo = UIImage(data: data), let self = self else {
                            return
                        }
                        
                        self.collectionContext?.performBatch(animated: false, updates: { (batchContext) in
                            self.descriptionImages[feature.featureId] = photo
                            batchContext.reload(in: self, at: IndexSet(integer: index - 1))
                        }, completion: nil)
                    }
                }
            }
        }
    }
}

final class EmbeddedStandardCollectionViewCell: UICollectionViewCell {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = true
        view.isPagingEnabled = true
        self.contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.frame
    }
    
}





// =====
// CELLs
// =====

final class FullWidthButtonCell : UICollectionViewCell {
    private let button: UIButton = {
       let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "LISABlue")
        button.layer.cornerRadius = 15.0
        return button
    }()
    
    var text: String? {
        get {
            return button.titleLabel?.text
        }
        set {
            button.setTitle(newValue, for: .normal)
//            button.titleLabel?.text = newValue
        }
    }
    
    var font: UIFont? {
        get {
            return button.titleLabel?.font
        }
        set {
            button.titleLabel?.font = newValue
        }
    }
    
    var buttonBackgroundColor: UIColor? {
        get {
            return button.backgroundColor
        }
        set {
            button.backgroundColor = newValue
        }
    }
    
    weak var delegate: FullWidthButtonCellDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
        } else {
            contentView.backgroundColor = .white
        }
        
        contentView.addSubview(button)
        
        NSLayoutConstraint(item: button,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 15).isActive = true
        NSLayoutConstraint(item: button,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 15).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: button,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: button,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 15).isActive = true
        
        button.addTarget(self, action: #selector(onHeart), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        // note: don't change the width
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    
    @objc func onHeart() {
        delegate?.didTapButton(cell: self)
    }
}

protocol FullWidthButtonCellDelegate: class {
    func didTapButton(cell: FullWidthButtonCell)
}

final class TidbitFullWidthSelfSizingCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var font: UIFont? {
        get {
            return label.font
        }
        set {
            label.font = newValue
        }
    }
    
    var attributedText: NSAttributedString? {
        get {
            return label.attributedText
        }
        set {
            label.attributedText = newValue
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
        } else {
            contentView.backgroundColor = .white
        }
        
        contentView.addSubview(label)
        
        NSLayoutConstraint(item: label,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 15).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        // note: don't change the width
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}



final class SubtitleFullWidthSelfSizingCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var font: UIFont? {
        get {
            return label.font
        }
        set {
            label.font = newValue
        }
    }
    
    var attributedText: NSAttributedString? {
        get {
            return label.attributedText
        }
        set {
            label.attributedText = newValue
        }
    }
    
    var textColor: UIColor? {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
        } else {
            contentView.backgroundColor = .white
        }
        
        contentView.addSubview(label)
        
        NSLayoutConstraint(item: label,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 15).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 15).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        // note: don't change the width
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}



final class HeadlineFullWidthSelfSizingCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var font: UIFont? {
        get {
            return label.font
        }
        set {
            label.font = newValue
        }
    }
    
    var attributedText: NSAttributedString? {
        get {
            return label.attributedText
        }
        set {
            label.attributedText = newValue
        }
    }
    
    var textColor: UIColor? {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
        } else {
            contentView.backgroundColor = .white
        }
        
        contentView.addSubview(label)
        
        NSLayoutConstraint(item: label,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 15).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        // note: don't change the width
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}




final class FullWidthSelfSizingCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var font: UIFont? {
        get {
            return label.font
        }
        set {
            label.font = newValue
        }
    }
    
    var attributedText: NSAttributedString? {
        get {
            return label.attributedText
        }
        set {
            label.attributedText = newValue
        }
    }
    
    var textColor: UIColor? {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
        } else {
            contentView.backgroundColor = .white
        }
        
        contentView.addSubview(label)
        
        NSLayoutConstraint(item: label,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: 15).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 15).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 15).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        // note: don't change the width
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}

final class ManuallySelfSizingCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
//        label.backgroundColor = UIColor.green.withAlphaComponent(0.1)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var attributedText: NSAttributedString? {
        get {
            return label.attributedText
        }
        set {
            label.attributedText = newValue
        }
    }
    
    var color: UIColor? {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
        } else {
            contentView.backgroundColor = .white
        }
        
        contentView.addSubview(label)
        
        let sharedConstant: CGFloat = 5
        
        NSLayoutConstraint(item: label,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: sharedConstant).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .leading,
                           multiplier: 1,
                           constant: sharedConstant).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: sharedConstant).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: sharedConstant).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.width = ceil(size.width)
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    
}


// MARK: - Models

final class Title: NSObject {
    let text: String
    
    init(text: String) {
        self.text = text
        
        super.init()
    }
}

extension Title: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}


final class Subtitle: NSObject {
    let text: String
    let color: UIColor
    
    init(text: String, color: UIColor) {
        self.text = text
        self.color = color
        
        super.init()
    }
}

extension Subtitle: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}




final class Subheading: NSObject {
    let text: String
    let color: UIColor
    
    init(text: String, color: UIColor) {
        self.text = text
        self.color = color
        
        super.init()
    }
}

extension Subheading: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}



import FontAwesome_swift

final class TidbitCollection: NSObject {
    let tidbits: [Tidbit]
    
    init(tidbits: [Tidbit]) {
        self.tidbits = tidbits
        super.init()
    }
}

extension TidbitCollection: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
    
}

final class ServiceInformation: NSObject {
    let text: String
    
    init(text: String) {
        self.text = text
    }
}



final class Tidbit: NSObject {
    let iconName: String?
    let text: String
    
    var attributedString = NSAttributedString()
    
    init(iconName: String? , text: String) {
        self.iconName = iconName
        self.text = text
        
        let commonSize: CGFloat = 14.0
        let systemFont = UIFont.systemFont(ofSize: commonSize)
        let textAttributes = [NSAttributedString.Key.font: systemFont,
                              NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        
        if let icon = iconName {
            let iconFont = UIFont.fontAwesome(ofSize: commonSize, style: .regular)
            let iconAttributes = [NSAttributedString.Key.font: iconFont,
                                  NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            
            let iconString = NSAttributedString(string: icon, attributes: iconAttributes)
            let textString = NSAttributedString(string: "  " + text, attributes: textAttributes)
            
            let mutableString = NSMutableAttributedString()
            mutableString.append(iconString)
            mutableString.append(textString)
            
            self.attributedString = mutableString
        } else {
            self.attributedString = NSAttributedString(string: text, attributes: textAttributes)
        }
            
        super.init()
    }
}

extension Tidbit: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}



final class Description: NSObject {
    let text: String
    
    init(text: String) {
        self.text = text
        
        super.init()
    }
}

extension Description: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}




final class ServiceFeatureList: NSObject {
    let serviceFeatures: [ServiceFeatureListModel]
    
    init(serviceFeatures: [ServiceFeatureListModel]) {
        self.serviceFeatures = serviceFeatures
        super.init()
    }
}

extension ServiceFeatureList: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}

final class ServiceFeatureListModel: NSObject {
    let serviceFeature: ServiceFeature
    
    init (serviceFeature: ServiceFeature) {
        self.serviceFeature = serviceFeature
        super.init()
    }
}

extension ServiceFeatureListModel: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}



final class ButtonModel: NSObject {
    let text: String
    
    init(text: String) {
        self.text = text
        
        super.init()
    }
}

extension ButtonModel: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}





final class ServiceFeatureCollectionSectionController: ListSectionController {
    
    private var object: ServiceFeatureCollection?
    var idsArray = [Int]()
    var placeholderImages: [Int: UIImage] = [Int: UIImage]()
    var headlineImages: [Int: UIImage?] = [Int: UIImage?]()
    var descriptionImages: [Int: UIImage?] = [Int: UIImage?]()
    
    override required init() {
        super.init()
        self.minimumInteritemSpacing = 2
        self.minimumLineSpacing = 10
        inset = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
    }
    
    override func numberOfItems() -> Int {
        return object?.serviceFeatures.count ?? 0
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        let itemSize = floor(width / 2) - inset.left - inset.right
        return CGSize(width: itemSize, height: itemSize)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: ServiceFeatureCardCell.self, for: self, at: index) as? ServiceFeatureCardCell else {
            fatalError()
        }
        
        
        cell.text = object?.serviceFeatures[index].title ?? "undefined"
        //        cell.image = object?.serviceFeatures[index].image ?? nil
        
        let featureId = idsArray[index]
        cell.image = headlineImages[featureId] ?? placeholderImages[featureId] ?? nil
        
        //        cell.layer.shadowColor = UIColor.black.cgColor
        //        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        //        cell.layer.shadowRadius = 2.0
        //        cell.layer.shadowOpacity = 0.5
        //        cell.layer.masksToBounds = false
        //        cell.layer.cornerRadius = 10.0
        //        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as? ServiceFeatureCollection
        
        guard let collection = self.object else {
            return
        }
        
        for feature in collection.serviceFeatures {
            idsArray.append(feature.featureId)
            placeholderImages[feature.featureId] = feature.placeholderImage
            headlineImages[feature.featureId] = nil
            descriptionImages[feature.featureId] = nil
        }
        
        for (index, feature) in collection.serviceFeatures.enumerated() {
            if let mainPhotoURL = feature.mainPhotoURL {
                let headlineImageRequest = NetworkRequest(url: mainPhotoURL, method: .GET, data: nil, headers: nil)
                
                DispatchQueue.global(qos: .utility).async { [weak self] in
                    headlineImageRequest.execute { (data) in
                        guard let data = data, let photo = UIImage(data: data), let self = self else {
                            return
                        }
                        
                        self.collectionContext?.performBatch(animated: false, updates: { (batchContext) in
                            self.headlineImages[feature.featureId] = photo
                            batchContext.reload(in: self, at: IndexSet(integer: index))
                        }, completion: nil)
                        
                    }
                }
            }
            
            if let secondaryPhotoURL = feature.secondaryPhotoURL {
                let secondaryImageRequest = NetworkRequest(url: secondaryPhotoURL, method: .GET, data: nil, headers: nil)
                
                DispatchQueue.global(qos: .utility).async { [weak self] in
                    secondaryImageRequest.execute { (data) in
                        guard let data = data, let photo = UIImage(data: data), let self = self else {
                            return
                        }
                        
                        self.collectionContext?.performBatch(animated: false, updates: { (batchContext) in
                            self.descriptionImages[feature.featureId] = photo
                            batchContext.reload(in: self, at: IndexSet(integer: index - 1))
                        }, completion: nil)
                    }
                }
            }
        }
        
        
    }
}

final class ServiceFeatureCardCell: UICollectionViewCell {
    
    lazy private var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .center
        view.textColor = .black
        view.font = .boldSystemFont(ofSize: 18)
        view.numberOfLines = 0
        view.lineBreakMode = NSLineBreakMode.byWordWrapping
        view.preferredMaxLayoutWidth = self.contentView.bounds.width
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        //        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.autoresizesSubviews = false
        imageView.backgroundColor = UIColor(named: "GradientLight")
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    var text: String? {
        get {
            return label.text
        }
        set {
            self.setNeedsUpdateConstraints()
            label.text = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            self.setNeedsUpdateConstraints()
            imageView.image = newValue
        }
    }
    
    weak var delegate: ServiceFeatureCardCellDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
        } else {
            contentView.backgroundColor = .white
        }
        
        contentView.layer.cornerRadius = 10
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 15),
            contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 15)
            ])
        
        //        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        //        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        //        self.contentView.layer.cornerRadius = 2.0
        //        self.contentView.layer.borderWidth = 1.0
        //        self.contentView.layer.borderColor = UIColor.clear.cgColor
        //        self.contentView.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(CGSize(width:  layoutAttributes.frame.width,
                                                              height: CGFloat.greatestFiniteMagnitude),
                                                       withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
        var newFrame = layoutAttributes.frame
        // note: don't change the width
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}

protocol ServiceFeatureCardCellDelegate: class {
    func cardCellTapped(cell: ServiceFeatureCardCell)
}



final class ServiceFeatureCollection: NSObject {
    let serviceFeatures: [ServiceFeatureCollectionModel]
    
    init(serviceFeatures: [ServiceFeatureCollectionModel]) {
        self.serviceFeatures = serviceFeatures
        super.init()
    }
}

extension ServiceFeatureCollection: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}


final class ServiceFeatureCollectionModel: NSObject {
    let featureId: Int
    let title: String
    let featureDescription: String
    let placeholderImage: UIImage
    var mainPhotoURL: URL? = nil
    var secondaryPhotoURL: URL? = nil
    
    init(featureId: Int, title: String, featureDescription: String, placeholderImage: UIImage, mainPhoto: URL?, secondaryPhoto: URL?) {
        self.featureId = featureId
        self.title = title
        self.featureDescription = featureDescription
        self.placeholderImage = placeholderImage
        self.mainPhotoURL = mainPhoto
        self.secondaryPhotoURL = secondaryPhoto
        super.init()
    }
}

extension ServiceFeatureCollectionModel: ListDiffable {
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self === object ? true : self.isEqual(object)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
}
