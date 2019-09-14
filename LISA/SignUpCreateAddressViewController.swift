//
//  SignUpCreateAddressViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/15/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import PKHUD

class SignUpCreateAddressViewController: UIViewController {

    var stepNumber: Int? = nil
    var maxSteps: Int? = nil
    
    @IBOutlet weak var stepField: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    
    @IBOutlet weak var premiseField: UITextField!
    @IBOutlet weak var thoroughfareField: UITextField!
    @IBOutlet weak var dependentLocalityField: UITextField!
    @IBOutlet weak var localityField: UITextField!
    @IBOutlet weak var postalCodeField: UITextField!
    
    
    weak var highestView: UIView!
    weak var lowestView: UIView!
    
    var textFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAdditionalBottomInsetsIfNeeded()
        
        highestView = stepField
        lowestView = postalCodeField
        
        setupBackground()
        continueButton.layer.cornerRadius = 8
        
        textFields = [premiseField, thoroughfareField, dependentLocalityField, localityField, postalCodeField]
        
        if let stepNumber = stepNumber, let maxSteps = maxSteps {
            stepField.text = "STEP \(stepNumber) OF \(maxSteps)"
        } else {
            stepField.text = ""
        }
        
        var index = textFields.startIndex
        while index != textFields.endIndex {
            SharedSignUpConstants.setDefaultStylingFieldFor(&textFields[index])
            textFields[index].delegate = self
            textFields[index].clearButtonMode = .whileEditing
            index = textFields.index(after: index)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpCreateAddressViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpCreateAddressViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        // Do any additional setup after loading the view.
    }
    
    func setupBackground() {
        let gradientLayer = CAGradientLayer.appStyleGradient()
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        headlineLabel.textColor = .white
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0 {
            guard let lowestView = lowestView else {
                self.view.frame.origin.y -= keyboardFrame.height
                return
            }
            
            let distanceFromLowestViewBottomToMainViewBottom = self.view.frame.size.height  - (lowestView.frame.size.height + lowestView.frame.origin.y)
            let distanceFromMainViewTopToHighestViewTop = highestView.frame.origin.y + highestView.frame.size.height
            
            if distanceFromLowestViewBottomToMainViewBottom < keyboardFrame.height {
                //                let margin: CGFloat = 30.0
                let margin: CGFloat = (distanceFromMainViewTopToHighestViewTop + distanceFromLowestViewBottomToMainViewBottom) / 2.0 / 2.0
                
                // eventually make the margin based on the distance from the topmost view to the top as well to fully center that
                self.view.frame.origin.y -= (keyboardFrame.height - (distanceFromLowestViewBottomToMainViewBottom) + margin)
            }
        }
    }
    
    func validateAndCreateAddress() {
        var premise: String? = nil
        var thoroughfare: String? = nil
        var dependentLocality: String? = nil
        var locality: String? = nil
        var postalCode: String? = nil
        
        
        for field in textFields {
            if field.isEqual(premiseField) {
                premise = field.text
            }
            
            if field.isEqual(thoroughfareField) {
                guard let text = field.text, text.count > 0 else {
                    displayAlertWithOK(title: "Form imcomplete", body: "You must enter your street address.")
                    self.continueButton.isUserInteractionEnabled = true
                    return
                }
                thoroughfare = field.text
            }
            
            if field.isEqual(dependentLocalityField) {
                guard let text = field.text, text.count > 0 else {
                    displayAlertWithOK(title: "Form imcomplete", body: "You must enter your village and/or barangay.")
                    self.continueButton.isUserInteractionEnabled = true
                    return
                }
                dependentLocality = field.text
            }
            
            if field.isEqual(localityField) {
                guard let text = field.text, text.count > 0 else {
                    displayAlertWithOK(title: "Form imcomplete", body: "You must enter your city.")
                    self.continueButton.isUserInteractionEnabled = true
                    return
                }
                locality = field.text
            }
            
            if field.isEqual(postalCodeField) {
                guard let text = field.text, text.count > 0 else {
                    displayAlertWithOK(title: "Form imcomplete", body: "You must enter your postal code.")
                    self.continueButton.isUserInteractionEnabled = true
                    return
                }
                postalCode = field.text
            }
        }
        
    let address = Address(id: nil, label: "Main", subPremise: nil, premise: premise, thoroughfare: thoroughfare, postalCode: postalCode, locality: locality, dependentLocality: dependentLocality, subAdministrativeArea: nil, administrativeArea: nil, country: "PH")
        
        HUD.show(.progress)
        createAddress(address) { (success) in
            if success {
                HUD.flash(.success)
                self.continueButton.isUserInteractionEnabled = true
                self.performSegue(withIdentifier: "moveToAskPushNotifications", sender: nil)
            } else {
                HUD.flash(.error)
                self.continueButton.isUserInteractionEnabled = true
                self.displayAlertWithOK(title: "Unable to create address", body: "Please check your network connection, and try again later.")
            }
        }
    }
    
    func createAddress(_ address: Address, completion: @escaping (Bool) -> Void) {
        guard let addressData = try? JSONEncoder().encode(address) else {
            return
        }
        
        let addressRequest = NetworkRequest(url: URL(string: AppAPIBase.AddressesPath)!, method: .POST, data: addressData, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()?.accessToken))
        
        addressRequest.execute { (data) in
            guard let data = data else {
                completion(false)
                return
            }
            
            guard let _ = try? JSONDecoder().decode(Address.self, from: data) else {
                print(String(data: data, encoding: .utf8))
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        validateAndCreateAddress()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func endEditing() {
        _ = self.view.endEditing(true)
        self.view.frame.origin.y = 0
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "moveToAskPushNotifications" {
            let destVC = segue.destination as! SignUpAskPushNotificationsViewController
            if let stepNumber = stepNumber, let maxSteps = maxSteps {
                destVC.stepNumber = stepNumber + 1
                destVC.maxSteps = maxSteps
            }
        }
    }
}

extension SignUpCreateAddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let index = textFields.firstIndex(of: textField) else {
            return true
        }
        
        if index < textFields.count - 1 {
            let nextField = textFields[index + 1]
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
