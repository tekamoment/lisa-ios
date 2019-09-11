//
//  LoginEmailViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/8/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import PKHUD

class LoginEmailViewController: UIViewController {

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    weak var highestView: UIView!
    weak var lowestView: UIView!
    
    var textFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sharedFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        let sharedColor = UIColor(red: 56.0/255, green: 56.0/255, blue: 56.0/255, alpha: 0.3)
        let sharedLeftRect = CGRect(x: 0, y: 0, width: 15, height: 20)
        
        textFields = [emailField, passwordField]
        
        textFields.forEach { textField in
            textField.backgroundColor = .white
            textField.font = sharedFont
            
            textField.layer.masksToBounds = true
            textField.layer.cornerRadius = 8
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.backgroundColor = sharedColor.cgColor
            textField.textColor = .white
            textField.tintColor = .white
            
            let paddingView = UIView(frame: sharedLeftRect)
            textField.leftView = paddingView
            textField.leftViewMode = .always
            
            textField.clearButtonMode = .whileEditing
            
            textField.delegate = self
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginEmailViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginEmailViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        let gradientLayer = CAGradientLayer.appStyleGradient()
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        
        signInButton.layer.cornerRadius = 8
        
        forgotPasswordButton.tintColor = .white
        
        emailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [.foregroundColor : UIColor.white])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [.foregroundColor : UIColor.white])
        passwordField.isSecureTextEntry = true
        
        
        highestView = headlineLabel
        lowestView = signInButton
        
        // Do any additional setup after loading the view.
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    func validateAndLogIn() {
        var email: String?
        var password: String?
        
        for field in textFields {
            
            if field.isEqual(emailField) {
                guard let text = field.text, text.count > 0, text.isValidEmail() else {
                    displayAlertWithOK(title: "Form incomplete", body: "You must enter a valid email.")
                    signInButton.isUserInteractionEnabled = true
                    return
                }
                email = text
            }
            
            if field.isEqual(passwordField) {
                guard let text = field.text, text.count >= 8 else {
                    displayAlertWithOK(title: "Form incomplete", body: "You must enter a password longer than 8 characters.")
                    signInButton.isUserInteractionEnabled = true
                    return
                }
                password = text
            }
        }
        
        guard let finalEmail = email, let finalPassword = password else {
            return
        }
        
        HUD.show(.progress)
        
        let userLogin = UserLogin(username: finalEmail, password: finalPassword)
        
        guard let loginData = try? JSONEncoder().encode(userLogin) else {
            return
        }
        
        let loginRequest = NetworkRequest(url: URL(string: AppAPIBase.JWTLoginPath)!, method: .POST, data: loginData, headers: AppAPIBase.StandardHeaders)
        
        loginRequest.execute { (data) in
            guard let data = data else {
                HUD.flash(.error)
                return
            }
            
            guard let loginDetails = try? JSONDecoder().decode(LoginDetails.self, from: data) else {
                print(String(data: data, encoding: .utf8))
                HUD.flash(.error)
                self.displayAlertWithOK(title: "Unable to log in", body: "Please check if your credentials are correct, and that you have a working internet connection.")
                return
            }
            
            CombinedUserInformation.shared.setLoginDetails(loginDetails)
            
            AppAPIBase.getUserDetails(completion: { (success) in
                if success {
                    AppAPIBase.getUserProfile(completion: { (success) in
                        if success {
                            AppAPIBase.getCustomerProfile(completion: { (success) in
                                if success {
                                    if let profilePhotoURL = CombinedUserInformation.shared.baseProfile()!.profilePhotoURL {
                                        AppAPIBase.getProfilePhoto(path: URL(string: profilePhotoURL)!, completion: { (success) in
                                            if success {
                                                HUD.flash(.success)
                                                self.dismiss(animated: true, completion: nil)
                                            } else {
                                                HUD.flash(.error)
                                                self.displayAlertWithOK(title: "Unable to retrieve profile photo", body: "Please ensure you have a working internet connection.")
                                            }
                                        })
                                    } else {
                                        HUD.flash(.success)
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                } else {
                                    HUD.flash(.error)
                                    self.displayAlertWithOK(title: "Unable to fetch customer details", body: "Please ensure you have a working internet connection.")
                                }
                            })
                        } else {
                            HUD.flash(.error)
                            self.displayAlertWithOK(title: "Unable to fetch profile", body: "Please ensure you have a working internet connection.")
                        }
                    })
                } else {
                    HUD.flash(.error)
                    self.displayAlertWithOK(title: "Unable to fetch user details", body: "Please ensure you have a working internet connection.")
                }
            })
        }
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

    @IBAction func signInTapped(_ sender: Any) {
        validateAndLogIn()
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
        self.dismiss(animated: true, completion: nil)
    }
}


extension LoginEmailViewController: UITextFieldDelegate {
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
