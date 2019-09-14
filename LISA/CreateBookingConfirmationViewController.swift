//
//  CreateBookingConfirmationViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/18/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit

class CreateBookingConfirmationViewController: UIViewController {

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAdditionalBottomInsetsIfNeeded()
        
        headlineLabel.textColor = .white
        bodyLabel.textColor = .white
        
        let gradientLayer = CAGradientLayer.appStyleGradient()
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        continueButton.layer.cornerRadius = 8
        
        navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        
        if let presentingVC = presentingViewController as? ServiceViewController {
            presentingVC.shouldDismissForBookingHistory = true
        }
        
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
