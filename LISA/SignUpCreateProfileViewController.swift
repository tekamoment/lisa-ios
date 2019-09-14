//
//  SignUpCreateProfileViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/15/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import PKHUD

class SignUpCreateProfileViewController: UIViewController {

    var stepNumber: Int? = nil
    var maxSteps: Int? = nil
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var profilePictureLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    weak var highestView: UIView!
    weak var lowestView: UIView!
    
    var textFields: [UITextField]!
    
    var facebookLoginDetails: FacebookLoginDetails?
    var suppliedEmail: String? = nil
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    var birthdate: Date? = nil
    var profilePhoto: UIImage? = nil {
        didSet {
            if profilePhoto != nil {
                self.profilePictureView.alpha = 1.0
            } else {
                self.profilePictureView.alpha = 0.5
            }
        }
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        birthdayField.text = dateFormatter.string(from: sender.date)
        birthdate = sender.date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if facebookLoginDetails != nil {
            cancelButton.isHidden = false
        } else {
            cancelButton.isHidden = true
        }
        
        
        setAdditionalBottomInsetsIfNeeded()
        
        profilePictureLabel.textColor = .white
        
        profilePictureView.backgroundColor = .white
        profilePictureView.alpha = 0.5

        textFields = [fullNameField, birthdayField, emailField, phoneNumberField]
        
        highestView = stepLabel
        lowestView = phoneNumberField
        
        setupBackground()
        continueButton.layer.cornerRadius = 8
        
        birthdayField.inputView = datePicker
        
        if let stepNumber = stepNumber, let maxSteps = maxSteps {
            stepLabel.text = "STEP \(stepNumber) OF \(maxSteps)"
        } else {
            stepLabel.text = ""
        }
        
        var index = textFields.startIndex
        while index != textFields.endIndex {
            SharedSignUpConstants.setDefaultStylingFieldFor(&textFields[index])
            textFields[index].delegate = self
            textFields[index].clearButtonMode = .whileEditing
            index = textFields.index(after: index)
            
        }
        
        if let fbDetails = facebookLoginDetails {
            fullNameField.text = fbDetails.name
            suppliedEmail = fbDetails.email
            if let imageData = fbDetails.imageData, let image = UIImage(data: imageData) {
                profilePictureView.image = image
                profilePhoto = image
            }
        }
        
        if let email = suppliedEmail {
            emailField.text = email
            emailField.isUserInteractionEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpCreateProfileViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpCreateProfileViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    profilePictureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfilePhoto)))
        profilePictureView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
    }
    
    
    @objc func selectProfilePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            displayAlertWithOK(title: "No access", body: "You have not granted LISA access to your photos to select a profile photo")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profilePictureView.layer.cornerRadius = profilePictureView.bounds.size.width / 2.0
        profilePictureView.layer.borderColor = UIColor.white.cgColor
        profilePictureView.layer.borderWidth = 1.0
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
    
    func validateAndCreateProfile() {
        var fullName: String?
        var email: String?
        var birthday: String?
        var phoneNumber: String?
        
        
        for field in textFields {
            if field.isEqual(fullNameField) {
                guard let text = field.text, text.count > 0 else {
                    displayAlertWithOK(title: "Form imcomplete", body: "You must enter your name.")
                    continueButton.isUserInteractionEnabled = true
                    return
                }
                fullName = text
            }
            
            if field.isEqual(emailField) {
                guard let text = field.text, text.count > 0, text.isValidEmail() else {
                    displayAlertWithOK(title: "Form incomplete", body: "You must enter a valid email.")
                    continueButton.isUserInteractionEnabled = true
                    return
                }
                email = text
            }
            
            if field.isEqual(birthdayField) {
                guard let text = field.text, let _ = self.birthdate else {
                    displayAlertWithOK(title: "Form incomplete", body: "You must enter your birthday.")
                    continueButton.isUserInteractionEnabled = true
                    return
                }
                
                birthday = text
            }
            
            if field.isEqual(phoneNumberField) {
                guard let text = field.text, text.count > 0, text.isValidPhone() else {
                    displayAlertWithOK(title: "Form imcomplete", body: "You must enter your name.")
                    continueButton.isUserInteractionEnabled = true
                    return
                }
                phoneNumber = text
            }
        }
        
        guard let finalFullName = fullName, let _ = email, let finalBirthday = birthdate, let finalPhoneNumber = phoneNumber else {
            continueButton.isUserInteractionEnabled = true
            return
        }
        
        let baseProfile = BaseProfile(fullName: finalFullName, contactNumber: finalPhoneNumber, profilePhotoURL: nil)
        let customerProfile = CustomerProfile(birthDate: finalBirthday)
        
        HUD.show(.progress)
        
        if CombinedUserInformation.shared.baseProfile() != nil {
            self.createCustomerProfile(customerProfile) { (success) in
                if success {
                    HUD.flash(.success)
                    self.continueButton.isUserInteractionEnabled = true
                    self.performSegue(withIdentifier: "moveToAddressCreation", sender: nil)
                    return
                }
                self.continueButton.isUserInteractionEnabled = true
                self.displayAlertWithOK(title: "Unable to proceed with registration", body: "Please check your network settings, and try again later.")
            }
        } else {
            createUserProfile(baseProfile) { (success) in
                if success {
                    if let profilePhoto = self.profilePhoto {
                        self.createProfilePhoto(withImage: profilePhoto, completion: { (success) in
                            if success {
                                self.createCustomerProfile(customerProfile) { (success) in
                                    if success {
                                        HUD.flash(.success)
                                        self.continueButton.isUserInteractionEnabled = true
                                        self.performSegue(withIdentifier: "moveToAddressCreation", sender: nil)
                                        return
                                    } else {
                                        HUD.flash(.error)
                                        self.continueButton.isUserInteractionEnabled = true
                                        self.displayAlertWithOK(title: "Unable to proceed with registration", body: "Please check your network settings, and try again later.")
                                    }
                                }
                            } else {
                                HUD.flash(.error)
                                self.continueButton.isUserInteractionEnabled = true
                                self.displayAlertWithOK(title: "Unable to upload profile photo", body: "Please check your network settings, and try again later.")
                            }
                        })
                    } else {
                        self.createCustomerProfile(customerProfile) { (success) in
                            if success {
                                HUD.flash(.success)
                                self.continueButton.isUserInteractionEnabled = true
                                self.performSegue(withIdentifier: "moveToAddressCreation", sender: nil)
                                return
                            } else {
                                HUD.flash(.error)
                                self.continueButton.isUserInteractionEnabled = true
                                self.displayAlertWithOK(title: "Unable to proceed with registration", body: "Please check your network settings, and try again later.")
                            }
                        }
                    }
                    
                } else {
                    HUD.flash(.error)
                    self.continueButton.isUserInteractionEnabled = true
                    self.displayAlertWithOK(title: "Unable to proceed with registration", body: "Please check your network settings, and try again later.")
                }
                
            }
        }
    }
    
    func createUserProfile(_ userProfile: BaseProfile, completion: @escaping (Bool) -> Void) {
        guard let userProfileData = try? JSONEncoder().encode(userProfile) else {
            return
        }
        
        let userProfileRequest = NetworkRequest(url: URL(string: AppAPIBase.ProfilePath)!, method: .POST, data: userProfileData, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()?.accessToken))
        
        userProfileRequest.execute { (data) in
            guard let data = data else {
                completion(false)
                return
            }
            
            guard let userProfile = try? JSONDecoder().decode(BaseProfile.self, from: data) else {
                print(String(data: data, encoding: .utf8))
                completion(false)
                return
            }
            
            CombinedUserInformation.shared.setBaseProfile(userProfile)
            completion(true)
        }
    }
    
    func createCustomerProfile(_ customerProfile: CustomerProfile, completion: @escaping (Bool) -> Void) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Truncated)
        
        guard let customerProfileData = try? encoder.encode(customerProfile) else {
            return
        }
        
        let customerProfileRequest = NetworkRequest(url: URL(string: AppAPIBase.CustomerProfilePath)!, method: .POST, data: customerProfileData, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()?.accessToken))
        
        customerProfileRequest.execute { (data) in
            guard let data = data else {
                completion(false)
                return
            }
            
            guard let customerProfile = try? JSONDecoder().decode(CustomerProfile.self, from: data) else {
                print(String(data: data, encoding: .utf8))
                completion(false)
                return
            }
            
            CombinedUserInformation.shared.setCustomerProfile(customerProfile)
            completion(true)
        }
    }
    
    func createProfilePhoto(withImage image: UIImage, completion: @escaping (Bool) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(false)
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let multipartBody = NetworkRequest.createMultipartBody(parameters: nil, boundary: boundary, data: imageData, mimeType: "image/jpeg", filename: "\(emailField.text!)-\(UUID().uuidString).jpeg")
        
        var standardHeaders = AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()!.accessToken)
        standardHeaders["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        
        let profilePhotoRequest = NetworkRequest(url: URL(string: AppAPIBase.ProfilePicturePath)!, method: .PUT, data: multipartBody, headers: standardHeaders)
        profilePhotoRequest.execute { (data) in
            guard let data = data else {
                completion(false)
                return
            }
            
            guard let _ = try? JSONDecoder().decode(ProfilePhotoSuccess.self, from: data) else {
                print(String(data: data, encoding: .utf8))
                completion(false)
                return
            }
            
            // set the profile correctly, doh
            CombinedUserInformation.shared.setProfilePhoto(image)
            completion(true)
        }
        
    }
    
    
    @IBAction func continueTapped(_ sender: Any) {
        validateAndCreateProfile()
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
        
        if identifier == "moveToAddressCreation" {
            let destVC = segue.destination as! SignUpCreateAddressViewController
            if let stepNumber = stepNumber, let maxSteps = maxSteps {
                destVC.stepNumber = stepNumber + 1
                destVC.maxSteps = maxSteps
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
        CombinedUserInformation.shared.logOut()
        navigationController?.popViewController(animated: true)
    }
    
}

extension SignUpCreateProfileViewController: UITextFieldDelegate {
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
    func isValidPhone() -> Bool {
        let phoneRegex = "(\\+?\\d{2}?\\s?\\d{3}\\s?\\d{3}\\s?\\d{4})|([0]\\d{3}\\s?\\d{3}\\s?\\d{4})"
        
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
}

extension SignUpCreateProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profilePictureView.image = pickedImage
            self.profilePhoto = pickedImage
        } else if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profilePictureView.image = pickedImage
            self.profilePhoto = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SignUpCreateProfileViewController: UINavigationControllerDelegate {
    
}


extension DateFormatter {
    static let iso8601Truncated: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}


