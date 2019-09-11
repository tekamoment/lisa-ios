//
//  SettingsRootTableViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/1/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class SettingsRootTableViewController: UITableViewController {

    var loginDetails: LoginDetails? = nil
    var notLoggedInView: SettingsNotLoggedInView! = {
        let view = SettingsNotLoggedInView()
        view.frame = .zero
        return view
    }()
    
    @objc func signInOrRegisterTapped(sender: Any) {
        let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginController")
        present(signInVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Sample table view cell
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = .white
    }
    
    func setupLogInView() {
        self.navigationController?.view.addSubview(notLoggedInView)
        notLoggedInView.frame = view.frame
        notLoggedInView.signInOrRegisterButton.addTarget(self, action: #selector(signInOrRegisterTapped(sender:)), for: UIControl.Event.touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let login = CombinedUserInformation.shared.loginDetails() else {
            loginDetails = nil
            
            setupLogInView()
            
            return
        }
    
        
        loginDetails = login
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController, navController.view.subviews.contains(notLoggedInView) {
            notLoggedInView.removeFromSuperview()
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Profile, Payment Methods, Lisa Support
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 4
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Profile"
        case 1:
            return "LISA Support"
        case 2:
            return " "
        default:
            return ""
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let loginDetails = loginDetails else {
            return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        }
        
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SignOutCell", for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.section == 0 {
            switch indexPath.item {
            case 0:
                cell.textLabel?.text = "Edit profile"
                cell.detailTextLabel?.text = "Your name, birthday and contact details"
            case 1:
                cell.textLabel?.text = "Edit your addresses"
            default:
                break
            }
        }
        
        if indexPath.section == 1 {
            switch indexPath.item {
            case 0:
                cell.textLabel?.text = "FAQs"
            case 1:
                cell.textLabel?.text = "Help"
            case 2:
                cell.textLabel?.text = "Contact us"
            case 3:
                cell.textLabel?.text = "Terms and conditions"
            default:
                break
            }
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                performSegue(withIdentifier: "showEditProfile", sender: nil)
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.item == 0 {
                let logOutConfirmation = UIAlertController(title: "Log out?", message: "Are you sure you want to log out of LISA?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { (_) in
                    CombinedUserInformation.shared.logOut()
                    self.setupLogInView()
                }
                logOutConfirmation.addAction(cancelAction)
                logOutConfirmation.addAction(logOutAction)
                present(logOutConfirmation, animated: true)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0))
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditProfile" {
            guard let editProfileNavVC = segue.destination as? UINavigationController, let editProfileVC = editProfileNavVC.topViewController as? EditProfileFormViewController  else {
                fatalError()
            }
        }
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
