//
//  CreateAddressFormViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/19/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import Eureka
import PKHUD

class CreateAddressFormViewController: FormViewController {

    var delegate: CreateAddressFormDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.title = "New address"
        
        form
            +++ Section("Enter a label for your address")
            <<< TextRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "label"
                $0.placeholder = "Label"
            }
            
            +++ Section("Enter your address details")
            <<< TextRow() {
                $0.tag = "premise"
                $0.placeholder = "Unit, Apartment, Suite, etc. (optional)"
//                $0.title = "
            }
            <<< TextRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "thoroughfare"
                $0.placeholder = "Street address (e.g. no. and street)"
            }
            <<< TextRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "dependentLocality"
                $0.placeholder = "Village and/or Barangay"
            }
            <<< TextRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "locality"
                $0.placeholder = "City"
            }
            <<< TextRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "postalCode"
                $0.placeholder = "Postal code"
            }
        
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneTapped() {
        let errors = form.validate()
        
        guard errors.count == 0 else {
            displayAlertWithOK(title: "Form incomplete", body: "Please make sure to fill in all required form details.")
            return
        }
        
        let formValues = self.form.values()
        
        guard let label = formValues["label"] as? String,
              let thoroughfare = formValues["thoroughfare"] as? String,
              let dependentLocality = formValues["thoroughfare"] as? String,
              let locality = formValues["locality"] as? String,
              let postalCode = formValues["postalCode"] as? String else {
                return
        }
        
        let premise = formValues["premise"] as? String
        
        let newAddress = Address(id: nil, label: label, subPremise: nil, premise: premise, thoroughfare: thoroughfare, postalCode: postalCode, locality: locality, dependentLocality: dependentLocality, subAdministrativeArea: nil, administrativeArea: nil, country: "PH")
        
        HUD.show(.progress)
        createAddress(newAddress) { (success, receivedAddress) in
            if success {
                guard let address = receivedAddress else {
                    HUD.flash(.error)
                    self.displayAlertWithOK(title: "Unable to create address", body: "Please check your network connection, and try again later.")
                    return
                }
                HUD.flash(.success)
                self.delegate?.completedCreationWithAddress(address)
                self.dismiss(animated: true, completion: nil)
            } else {
                HUD.flash(.error)
                self.displayAlertWithOK(title: "Unable to create address", body: "Please check your network connection, and try again later.")
            }
        }
        
    }
    
    func createAddress(_ address: Address, completion: @escaping (Bool, Address?) -> Void) {
        guard let addressData = try? JSONEncoder().encode(address) else {
            return
        }
        
        let addressRequest = NetworkRequest(url: URL(string: AppAPIBase.AddressesPath)!, method: .POST, data: addressData, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()?.accessToken))
        
        addressRequest.execute { (data) in
            guard let data = data else {
                completion(false, nil)
                return
            }
            
            guard let receivedAddress = try? JSONDecoder().decode(Address.self, from: data) else {
                print(String(data: data, encoding: .utf8))
                completion(false, nil)
                return
            }
            
            completion(true, receivedAddress)
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

protocol CreateAddressFormDelegate: class {
    func completedCreationWithAddress(_ address: Address)
}
