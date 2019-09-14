//
//  CreateBookingFormViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/13/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import Eureka
import PKHUD

class CreateBookingFormViewController: FormViewController {
    // hella temporary
    var service: Service?
//    var servicePrices: [ServicePrice]?
    var durationInHours: Int?
    var selectedDate: Date?
    var selectedTime: Date?
    
    var targetPriceString: String? {
        didSet {
            let priceRow = self.form.rowBy(tag: "price")! as! LabelRow
            priceRow.value = targetPriceString
            priceRow.reload()
        }
    }
    
    var addresses: [Address]? = nil {
        didSet {
            form.rowBy(tag: "address")?.updateCell()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Create booking"
        
        PKHUD.sharedHUD.show()
        
        let addressRequest = NetworkRequest(url: URL(string: AppAPIBase.AddressesPath)!, method: .GET, data: nil, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()!.accessToken))
        addressRequest.execute { (data) in
            guard let data = data, let addresses = try? JSONDecoder().decode([Address].self, from: data) else {
                fatalError()
            }
            
            DispatchQueue.main.async {
                PKHUD.sharedHUD.hide(true)
                self.addresses = addresses
            }
            
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelCreateBooking(sender:)))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "LISABlue")

        tableView?.estimatedSectionHeaderHeight = 140
        
        form
//            +++ Section() {
//                var header = HeaderFooterView<CreateBookingHeaderView>(.class)
//                header.height = {UITableView.automaticDimension}
//                $0.header = header
//            }
            +++ Section()
            <<< DateRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "date"
                $0.minimumDate = Date()
                var dateComponents = DateComponents()
                dateComponents.weekOfYear = 3
                $0.maximumDate = Calendar(identifier: .gregorian).date(byAdding: dateComponents, to: Date())
                }.cellSetup { cell, row in
//                    let prefixString = NSAttributedString(string: "Enter your ", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
//                    let postfixString = NSMutableAttributedString(string: "desired date", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold)])
//
//                    let attString = NSMutableAttributedString(attributedString: prefixString)
//                    attString.append(postfixString)
//                    cell.textLabel?.attributedText = attString
                    
                    row.title = "Enter your desired date"
                    cell.detailTextLabel?.text = ""
                    
                    if #available(iOS 13, *) {
                        cell.textLabel?.textColor = .label
                        cell.detailTextLabel?.textColor = .label
                    }
                }.cellUpdate { cell , row in
                    if #available(iOS 13, *) {
                        cell.detailTextLabel?.textColor = .label
                        cell.textLabel?.textColor = .label
                    }
                    if let date = row.value {
                        let onString = NSAttributedString(string: "On ", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
                        let dateAttributedString = NSMutableAttributedString(string: ((row.dateFormatter?.string(from: date))!), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor(named: "LISABlue")])
                        
                        let attString = NSMutableAttributedString(attributedString: onString)
                        attString.append(dateAttributedString)
                        
                        cell.textLabel?.attributedText = attString
                    } else {
                        let prefixString = NSAttributedString(string: "Enter your ", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
                        let postfixString = NSMutableAttributedString(string: "desired date", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold)])
                        
                        let attString = NSMutableAttributedString(attributedString: prefixString)
                        attString.append(postfixString)
                        cell.textLabel?.attributedText = attString
                    }
//                    cell.textLabel?.textColor = row.title == "Date" ? .gray : .black
                    cell.detailTextLabel?.text = ""
                    

            }
            <<< TimeRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "time"
                $0.minuteInterval = 15

                $0.minimumDate =  Calendar.current.date(bySettingHour: 9, minute: 00, second: 0, of: Date())!
                $0.maximumDate =  Calendar.current.date(bySettingHour: 17, minute: 00, second: 0, of: Date())!
//                trigger updates to min and max date to set time correctly
            }.cellSetup { cell, row in
                if #available(iOS 13, *) {
                    cell.textLabel?.textColor = .label
                    cell.detailTextLabel?.textColor = .label
                }
                
                row.title = "Enter your desired start time"
                cell.detailTextLabel?.text = ""
            }.cellUpdate { cell , row in
                if #available(iOS 13, *) {
                    cell.detailTextLabel?.textColor = .label
                    cell.textLabel?.textColor = .label
                }
                if let date = row.value {
                    let onString = NSAttributedString(string: "Starting ", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
                    let dateAttributedString = NSMutableAttributedString(string: ((row.dateFormatter?.string(from: date))!), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor(named: "LISABlue")])
                    
                    let attString = NSMutableAttributedString(attributedString: onString)
                    attString.append(dateAttributedString)
                    
                    cell.textLabel?.attributedText = attString
                } else {
                    let prefixString = NSAttributedString(string: "Enter your ", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
                    let postfixString = NSMutableAttributedString(string: "desired start time", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold)])
                    
                    let attString = NSMutableAttributedString(attributedString: prefixString)
                    attString.append(postfixString)
                    cell.textLabel?.attributedText = attString
                }
                cell.detailTextLabel?.text = ""
            }
            // change retval to Address
            <<< PushRow<Address>() {
                $0.add(rule: RuleRequired())
//                $0.title = "Select your address"
                $0.tag = "address"
                $0.selectorTitle = "Choose an Address"
            }.cellSetup { cell, row in
                if #available(iOS 13, *) {
                    cell.detailTextLabel?.textColor = .label
                    cell.textLabel?.textColor = .label
                }
            }.cellUpdate { cell, row in
                    if #available(iOS 13, *) {
                        cell.detailTextLabel?.textColor = .label
                        cell.textLabel?.textColor = .label
                    }
                    
                    row.options = self.addresses
                    
                    if let address = row.value {
                        let prefixString = NSAttributedString(string: "At your ", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
                        let addressLabelString = NSMutableAttributedString(string: address.label! + " ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor(named: "LISABlue")])
                        let postfixString = NSAttributedString(string: "address", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
                        
                        let attString = NSMutableAttributedString(attributedString: prefixString)
                        attString.append(addressLabelString)
                        attString.append(postfixString)
                        cell.textLabel?.attributedText = attString
                        
                        cell.detailTextLabel?.text = ""
                        
//                        cell.textLabel?.text = "At your \(address.label!) address"
                    } else {
                        let prefixString = NSAttributedString(string: "Select your ", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
                        let postfixString = NSMutableAttributedString(string: "address", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold)])
                        
                        let attString = NSMutableAttributedString(attributedString: prefixString)
                        attString.append(postfixString)
                        cell.textLabel?.attributedText = attString
                    }
                }.onPresent({ (_, presentingVC) in
                    presentingVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add
                        , target: self, action: #selector(self.presentAddAddressViewController))
                    
                    presentingVC.selectableRowSetup = { row in
                        row.cellProvider = CellProvider<ListCheckCell<Address>>(nibName: "AddressSelectionCell", bundle: Bundle.main)
                    }
                    
                    presentingVC.selectableRowCellUpdate = { cell, row in
                        if #available(iOS 13, *) {
                            cell.detailTextLabel?.textColor = .label
                            cell.textLabel?.textColor = .label
                        }
                        cell.textLabel?.text = row.selectableValue?.label
                        cell.detailTextLabel?.text = row.selectableValue?.concatenatedAddress()
                        cell.detailTextLabel?.numberOfLines = 0
                    }
                })
            <<< StepperRow() {
                let prices = service!.prices.sorted { $0.durationInMinutes < $1.durationInMinutes }
                
                $0.add(rule: RuleRequired())
                $0.tag = "duration"
                $0.title = "Hours"
                $0.value = Double(prices.first!.durationInMinutes) / 60.0
                $0.displayValueFor = nil
//                $0.cell.stepper.minimumValue = 2.00
                $0.cell.stepper.minimumValue = Double(prices.first!.durationInMinutes) / 60.0
                $0.cell.stepper.maximumValue = Double(prices.last!.durationInMinutes) / 60.0
                $0.cell.stepper.tintColor = UIColor(named: "LISABlue")
                }.onChange{ row in
                    let numberOfHours = Int(row.value!)
                    let priceRow = self.form.rowBy(tag: "price")! as! LabelRow
                    let numberOfMinutes = numberOfHours * 60
                    guard let service = self.service else {
                        return
                    }
                    let servicePrices = service.prices
                    guard let targetPrice = servicePrices.filter({ price -> Bool in
                        return price.durationInMinutes == numberOfMinutes
                    }).first else {
                        return
                    }
//                    priceRow.value = "₱ \(targetPrice.price)"
                    self.targetPriceString = String(format: "₱ %.2f", targetPrice.price)
//                    priceRow.value = String(format: "₱ %.2f", targetPrice.price)
//                    priceRow.reload()
                    
                }.cellUpdate { cell, row in
                    if #available(iOS 13, *) {
                        cell.detailTextLabel?.textColor = .label
                        cell.textLabel?.textColor = .label
                    }
                    if let value = row.value {
                        let intValue = Int(value)
                        
                        let onString = NSAttributedString(string: "For ", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
                        let dateAttributedString = NSMutableAttributedString(string: value > 1 ? "\(intValue) hours" : "\(intValue) hour", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor(named: "LISABlue")])
                        
                        let attString = NSMutableAttributedString(attributedString: onString)
                        attString.append(dateAttributedString)
                        
                        cell.textLabel?.attributedText = attString
                        
                        
                        self.durationInHours = intValue
                    }
                }.cellSetup { cell, row in
                    if #available(iOS 13, *) {
                        cell.detailTextLabel?.textColor = .label
                        cell.textLabel?.textColor = .label
                    }
                    let priceRow = self.form.rowBy(tag: "price")! as! LabelRow
                    let numberOfMinutes = 2 * 60
                    guard let service = self.service else {
                        return
                    }
                    let servicePrices = service.prices
                    guard let targetPrice = servicePrices.filter({ price -> Bool in
                        return price.durationInMinutes == numberOfMinutes
                    }).first else {
                        return
                    }
                    self.targetPriceString = String(format: "₱ %.2f", targetPrice.price)
            }
            <<< TextAreaRow() {
                $0.tag = "comment"
                $0.placeholder = "(Optional) Enter a comment, i.e. Inform the receptionist when you arrive at the building. Be careful in cleaning the bathroom because it was newly renovated."
                }.cellSetup { cell, row in
                    
                    if #available(iOS 13, *) {
                        cell.textView.backgroundColor = .secondarySystemBackground
                        cell.placeholderLabel?.textColor = .secondaryLabel
                    }
                    
                    cell.textView.textColor = UIColor(named: "LISABlue")
                    cell.textView.tintColor = UIColor(named: "LISABlue")
            }.cellUpdate { cell, row in
                if #available(iOS 13, *) {
                    cell.detailTextLabel?.textColor = .label
                    cell.textLabel?.textColor = .label
                    cell.textView.textColor = UIColor(named: "LISABlue")
                }
            }
            +++ Section()
            <<< LabelRow() {
                $0.title = "Total payable: "
                $0.tag = "price"
                }.cellUpdate { cell, row in
                        if #available(iOS 13, *) {
                            cell.detailTextLabel?.textColor = .label
                            cell.textLabel?.textColor = .label
                        }
                        //                    cell.detailTextLabel?.text = row.value
                        //                    cell.detailTextLabel?.tintColor = UIColor(named: "LISABlue")
                        if let amount = row.value {
                            let amountString = NSMutableAttributedString(string: amount, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor(named: "LISABlue")])
                            cell.detailTextLabel?.attributedText = amountString
                        }
                        
                }.cellSetup { cell, row in
                    if #available(iOS 13, *) {
                        cell.detailTextLabel?.textColor = .label
                        cell.textLabel?.textColor = .label
                    }
//                    cell.detailTextLabel?.text =
                    if let amount = row.value {
                        let amountString = NSMutableAttributedString(string: amount, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor(named: "LISABlue")])
                        cell.detailTextLabel?.attributedText = amountString
                    }
            }
            <<< LabelRow() {
                $0.title = "Payment"
                }.cellSetup{ cell, row in
                    if #available(iOS 13, *) {
                        cell.detailTextLabel?.textColor = .label
                        cell.textLabel?.textColor = .label
                    }
                    cell.textLabel?.numberOfLines = 0
                }.cellUpdate{ cell, row in
                    if #available(iOS 13, *) {
                        cell.detailTextLabel?.textColor = .label
                        cell.textLabel?.textColor = .label
                    }
                    let prefixString = NSAttributedString(string: "Payment:", attributes: [NSAttributedString.Key.font: cell.textLabel?.font])
                    let attString = NSMutableAttributedString(attributedString: prefixString)
                    cell.textLabel?.attributedText = attString
                    
                    let detailLabelString = NSMutableAttributedString(string: "Cash upon completion", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor(named: "LISABlue")])
                    cell.detailTextLabel?.attributedText = detailLabelString
//                    attString.append(infixString)
//                    attString.append(postfixString)
                    
            }
            <<< ButtonRow() {
                $0.title = "Book Service"
                $0.onCellSelection(self.buttonTapped(cell:row:))
                
                }.cellSetup { cell, row in
                    cell.tintColor = .white
                    cell.backgroundColor = UIColor(named: "LISABlue")
                    
                    let bookServiceString = NSMutableAttributedString(string: "Book Service", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (cell.textLabel?.font.pointSize)!, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.white])
                    cell.textLabel?.attributedText = bookServiceString
//                    cell.textLabel?.attributedText =
                }
        // Do any additional setup after loading the view.
        
        self.targetPriceString = String(format: "₱ %.2f", service!.prices.first!.price)
    }
    
    @objc func presentAddAddressViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newAddressNavVC = storyboard.instantiateViewController(withIdentifier: "newAddressForm") as! UINavigationController
        let newAddressVC = newAddressNavVC.visibleViewController as! CreateAddressFormViewController
        newAddressVC.delegate = self
        present(newAddressNavVC, animated: true, completion: nil)
    }
    
    func buttonTapped(cell: ButtonCellOf<String>, row: ButtonRow) {
        let errors = form.validate()
        guard errors.count == 0 else {
            print("Errors found: \(errors)")
            displayAlertWithOK(title: "Form incomplete", body: "Please make sure to fill in all form details.")
            return
        }
        
        let formValues = self.form.values()
        
        guard let startDate = formValues["date"] as? Date,
              let time = formValues["time"] as? Date,
              let address = formValues["address"] as? Address,
              let duration = formValues["duration"] as? Double else {
            return
        }
        
        guard let service = service, let targetPrice = service.prices.filter({ price -> Bool in
            return price.durationInMinutes == Int(duration * 60)
        }).first else {
            return
        }
        
        let comment = formValues["comment"] as? String ?? " "
        let serviceRequest = BookingRequest.ServiceRequest(serviceId: service.id, priceId: targetPrice.id)
        
        let bookingRequest = BookingRequest(requestedStartDatetime: combineDateWithTime(date: startDate, time: time)!, addressId: address.id!, comment: comment, requestedServices: [serviceRequest])
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        
        guard let bookingRequestData = try? jsonEncoder.encode(bookingRequest) else {
            return
        }
        
        
        let createBookingRequest = NetworkRequest(url: URL(string: AppAPIBase.CreateBookingPath)!, method: .POST, data: bookingRequestData, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()!.accessToken))
        
        HUD.show(.progress)
        createBookingRequest.execute { (data) in
            guard let data = data else {
                HUD.flash(.error)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            if let bookingDetails = try? jsonDecoder.decode(Booking.self, from: data) {
                print(bookingDetails)
                HUD.flash(.success)
                self.performSegue(withIdentifier: "showCompletion", sender: nil)
                return
            }
            HUD.flash(.error)
        }
    }
    
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments)
    }
    
    @objc func cancelCreateBooking(sender: Any) {
        dismiss(animated: true, completion: nil)
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

extension CreateBookingFormViewController: CreateAddressFormDelegate {
    func completedCreationWithAddress(_ address: Address) {
        addresses?.append(address)
        form.rowBy(tag: "address")?.updateCell()
    }
}
