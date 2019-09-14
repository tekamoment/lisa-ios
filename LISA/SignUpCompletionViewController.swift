//
//  SignUpCompletionViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/18/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class SignUpCompletionViewController: UIViewController {

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAdditionalBottomInsetsIfNeeded()
        
        let gradientLayer = CAGradientLayer.appStyleGradient()
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        continueButton.layer.cornerRadius = 8
        logoImageView.layer.cornerRadius = 12
        
        headlineLabel.textColor = .white
        bodyLabel.textColor = .white
        continueButton.tintColor = .white
        
        logoImageView.layer.shadowPath = UIBezierPath(rect: logoImageView.bounds).cgPath
        logoImageView.layer.shadowRadius = 10
        logoImageView.layer.shadowOffset = .zero
        logoImageView.layer.shadowOpacity = 1
        
        
        headlineLabel.text = "Welcome to LISA, \(CombinedUserInformation.shared.baseProfile()!.fullName)!"
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
