//
//  EditProfileFormViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/20/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import Eureka
import ImageRow

class EditProfileFormViewController: FormViewController {
    
    var defaultValues: [String: Any?]? = nil
    var changes: [String: Any?]? = nil {
        didSet {
            if changes != nil {
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        let doneButton =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        doneButton.isEnabled = false
        navigationItem.rightBarButtonItem = doneButton
        
        navigationItem.title = "Edit profile"
        
        defaultValues = [
            "profilePhoto": CombinedUserInformation.shared.profilePhoto(),
            "fullName": CombinedUserInformation.shared.baseProfile()?.fullName,
            "email": CombinedUserInformation.shared.userDetails()?.email,
            "phone": CombinedUserInformation.shared.baseProfile()?.contactNumber
        ]
        
        
        form
            +++ Section()
            <<< ImageRow() {
                $0.title = "Profile picture"
                $0.tag = "profilePhoto"
                $0.sourceTypes = .PhotoLibrary
                $0.clearAction = .no
                $0.allowEditor = true
                $0.useEditedImage = true
                $0.value = CombinedUserInformation.shared.profilePhoto()
                }.cellUpdate { [unowned self] cell, row in
                    let cellHeight: CGFloat = 60
                    let accessoryViewDimension = cellHeight - 4
                    let accessoryViewRadius = accessoryViewDimension / 2
                    cell.height = ({return cellHeight})
                    cell.accessoryView?.layer.cornerRadius = accessoryViewRadius
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: accessoryViewDimension, height: accessoryViewDimension)
                    self.checkAndEnableDone()
                }
            
            +++ Section()
            <<< TextRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "fullName"
                }.cellSetup { cell, row in
                    row.title = "Full name"
//                    cell.detailTextLabel?.text = CombinedUserInformation.shared.baseProfile()?.fullName
                    row.value = CombinedUserInformation.shared.baseProfile()?.fullName
                }.cellUpdate { [unowned self] cell, row in
                    cell.textField.textColor = .gray
                    self.checkAndEnableDone()
            }
            <<< EmailRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "email"
                
                }.cellSetup { cell, row in
                    row.title = "Email"
                    row.value = CombinedUserInformation.shared.userDetails()?.email
//                    cell.detailTextLabel?.text = CombinedUserInformation.shared.
                    cell.tintColor = UIColor(named: "LISABlue")!
                    cell.textField.textColor = .gray
                }.cellUpdate { [unowned self]  cell, row in
                    cell.textField.textColor = .gray
                    self.checkAndEnableDone()
                }
            <<< PhoneRow() {
                $0.add(rule: RuleRequired())
                $0.tag = "phone"
                }.cellSetup { cell, row in
                    row.title = "Phone number"
                    row.value = CombinedUserInformation.shared.baseProfile()?.contactNumber
                }.cellUpdate { [unowned self] cell, row in
                    cell.textField.textColor = .gray
                    self.checkAndEnableDone()
        }
        // Do any additional setup after loading the view.
    }
    
    func checkAndEnableDone() {
        let errors = form.validate()
        guard errors.count == 0 else { return }
        
        guard let defaults = defaultValues else { return }
        
        let values = form.values()
        let changes = values.filter { (arg) -> Bool in
            let (key, value) = arg
            guard let defaultValue = defaults[key] else {
                return true
            }
            
            if let imageValue = value as? UIImage {
                guard let defaultImage = defaultValue as? UIImage else {
                    return true
                }
                
                guard let valueData = imageValue.jpegData(compressionQuality: 1.0), let defaultData = defaultImage.jpegData(compressionQuality: 1.0) else {
                    return true
                }
                
                return !(valueData == defaultData)
                
            } else if let stringValue = value as? String {
                return (defaultValue as? String) != stringValue
            } else {
                fatalError()
            }
        }
        
        self.changes = changes
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneTapped() {
//        dismiss(animated: true, completion: nil)
        
        if let profilePhotoChange = self.changes?["profilePhoto"] as? UIImage {
            AppAPIBase.createProfilePhoto(withImage: profilePhotoChange, filenamePrefix: CombinedUserInformation.shared.loginDetails()!.email!) { (success) in
                
            }
        }
        
        let nonProfilePhotoChanges = self.changes?.filter({ (arg) -> Bool in
            let (key, _) = arg
            return key != "profilePhoto"
        })
        
        guard let nPPC = nonProfilePhotoChanges, nPPC.count > 0 else {
            return
        }
        
        let patchBaseProfile = PatchBaseProfile(fullName: nPPC["fullName"] as? String, contactNumber: nPPC["phone"] as? String)
        
        guard let patchData = try? JSONEncoder().encode(patchBaseProfile) else {
            return
        }
        
        let patchRequest = NetworkRequest(url: URL(string: AppAPIBase.ProfilePath)!, method: .PATCH, data: patchData, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()!.accessToken))
        
        patchRequest.execute { [unowned self] (data) in
            guard let data = data else {
                return
            }
            
            let jsonDecoder = JSONDecoder()
            guard let newBaseProfileData = try? jsonDecoder.decode(BaseProfile.self, from: data) else {
                self.displayAlertWithOK(title: "Error", body: "We couldn't update your profile at this time. Please try again later.")
                return
            }
            
            CombinedUserInformation.shared.setBaseProfile(newBaseProfileData)
            self.dismiss(animated: true, completion: nil)
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
