//
//  SignUpCreateAccountViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/15/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import PKHUD

class SignUpCreateAccountViewController: UIViewController {
    
    var stepNumber: Int? = nil
    var maxSteps: Int? = nil
    
    private var userCreationModel: UserCreation? = nil

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var stepField: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var highestView: UIView!
    weak var lowestView: UIView!
    
    var textFields: [UITextField]!
    
    var finalEmail: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAdditionalBottomInsetsIfNeeded()
        
        textFields = [emailField, passwordField, passwordConfirmationField]
        
        setupBackground()
        continueButton.layer.cornerRadius = 8
        
        if let stepNumber = stepNumber, let maxSteps = maxSteps {
            stepField.text = "STEP \(stepNumber) OF \(maxSteps)"
        } else {
            stepField.text = ""
        }
        
        var index = textFields.startIndex
        while index != textFields.endIndex {
            SharedSignUpConstants.setDefaultStylingFieldFor(&textFields[index])
            
            let currentField = textFields[index]
            currentField.delegate = self
            currentField.clearButtonMode = .whileEditing
            
//            if let clearButton = currentField.value(forKey: "_clearButton") as? UIButton {
//                let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
//                clearButton.setImage(templateImage, for: .normal)
//                clearButton.tintColor = .white
//            }
            
            index = textFields.index(after: index)
            
        }
        
        highestView = stepField
        lowestView = passwordConfirmationField
        
        passwordField.isSecureTextEntry = true
        passwordConfirmationField.isSecureTextEntry = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpCreateAccountViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpCreateAccountViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        continueButton.isUserInteractionEnabled = false
        cancelButton.isUserInteractionEnabled = false
        validateAndCreateUser()
    }
    
    func showError(title: String, body: String) {
        DispatchQueue.main.async {
            self.displayAlertWithOK(title: title, body: body)
            HUD.flash(.error)
            self.continueButton.isUserInteractionEnabled = true
            self.cancelButton.isUserInteractionEnabled = true
        }
    }
    
    func validateAndCreateUser() {
        
        var email: String?
        var password: String?
        
        for field in textFields {
            
            if field.isEqual(emailField) {
                guard let text = field.text, text.count > 0, text.isValidEmail() else {
                    displayAlertWithOK(title: "Form incomplete", body: "You must enter a valid email.")
                    continueButton.isUserInteractionEnabled = true
                    cancelButton.isUserInteractionEnabled = true
                    return
                }
                email = text
            }
            
            if field.isEqual(passwordField) {
                guard let text = field.text, text.count >= 8 else {
                    displayAlertWithOK(title: "Form incomplete", body: "You must enter a password longer than 8 characters.")
                    continueButton.isUserInteractionEnabled = true
                    cancelButton.isUserInteractionEnabled = true
                    return
                }
                password = text
            }
            
            if field.isEqual(passwordConfirmationField) {
                guard let confText = field.text, let passText = passwordField.text, confText == passText  else {
                    displayAlertWithOK(title: "Form incomplete", body: "Your passwords must match.")
                    continueButton.isUserInteractionEnabled = true
                    cancelButton.isUserInteractionEnabled = true
                    return
                }
            }
        }
        
        guard let finalEmail = email, let finalPassword = password else {
            return
        }
    
        HUD.show(.progress)
        
        userCreationModel = UserCreation(username: finalEmail, email: finalEmail, password: finalPassword)
        createUser { (success) in
            if success {
                self.finalEmail = finalEmail
                DispatchQueue.main.async {
                    HUD.flash(.success)
                    self.continueButton.isUserInteractionEnabled = true
                    self.cancelButton.isUserInteractionEnabled = true
                    self.performSegue(withIdentifier: "moveToProfileCreation", sender: nil)
                }
            } else {
                HUD.flash(.error)
                self.continueButton.isUserInteractionEnabled = true
                self.cancelButton.isUserInteractionEnabled = true
                self.displayAlertWithOK(title: "Unable to create user", body: "Please try again in a few minutes.")
                // generate UIAlert
                
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "moveToProfileCreation" {
            let destVC = segue.destination as! SignUpCreateProfileViewController
            if let stepNumber = stepNumber, let maxSteps = maxSteps {
                destVC.suppliedEmail = finalEmail
                destVC.stepNumber = stepNumber + 1
                destVC.maxSteps = maxSteps
            }
        }
    }
    
    func createUser(completion: @escaping (Bool) -> Void) {
        guard let newUser = userCreationModel, let newUserData = try? JSONEncoder().encode(newUser) else {
            return
        }
        
        let newUserRequest = NetworkRequest(url: URL(string: AppAPIBase.CreateUserAuth)!, method: .POST, data: newUserData, headers: AppAPIBase.StandardHeaders)
        
        newUserRequest.execute { (data) in
            guard let data = data else {
                completion(false)
                return
            }
            
            guard let userDetails = try? JSONDecoder().decode(UserDetails.self, from: data) else {
                print(String(data: data, encoding: .utf8))
                completion(false)
                return
            }
            
            CombinedUserInformation.shared.setUserDetails(userDetails)
            
            guard let loginDetails = try? JSONDecoder().decode(LoginDetails.self, from: data) else {
                print(String(data: data, encoding: .utf8))
                completion(false)
                return
            }
            
            CombinedUserInformation.shared.setLoginDetails(loginDetails)
            completion(true)
        }
        
    }
}

extension SignUpCreateAccountViewController: UITextFieldDelegate {
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

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
