//
//  SignUpAskPushNotificationsViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/15/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import PKHUD
import UIKit
import UserNotifications

class SignUpAskPushNotificationsViewController: UIViewController {
    
    var stepNumber: Int? = nil
    var maxSteps: Int? = nil

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var approveNotificationsButton: UIButton!
    @IBOutlet weak var declineNotificationsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAdditionalBottomInsetsIfNeeded()
        
        approveNotificationsButton.layer.cornerRadius = 8
        
        setupBackground()
        
        if let stepNumber = stepNumber, let maxSteps = maxSteps {
            stepLabel.text = "STEP \(stepNumber) OF \(maxSteps)"
        } else {
            stepLabel.text = ""
        }
        
        
        if let sharedDelegate = UIApplication.shared.delegate as? AppDelegate {
            sharedDelegate.pushNotificationRegistrationDelegate = self
        }
    }
    
    func setupBackground() {
        let gradientLayer = CAGradientLayer.appStyleGradient()
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        headlineLabel.textColor = .white
        bodyLabel.textColor = .white
        
        declineNotificationsButton.tintColor = .white
    }
    
    
    @IBAction func approveNotificationsTapped(_ sender: Any) {
        registerForPushNotifications()
    }
    
    @IBAction func declineNotificationsTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "moveToCompletion", sender: nil)
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

extension SignUpAskPushNotificationsViewController {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else {
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            DispatchQueue.main.async {
                HUD.show(.progress)
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

extension SignUpAskPushNotificationsViewController: AppDelegatePushNotificationRegistrationDelegate {
    func registrationForPushNotificationsCompleted(success: Bool) {
        if success {
            HUD.flash(.success)
            self.performSegue(withIdentifier: "moveToCompletion", sender: nil)
        } else {
            HUD.flash(.error)
            displayAlertWithOK(title: "Unable to register for push notificaitons", body: "Check your network settings and try again later.")
        }
        
    }
}
