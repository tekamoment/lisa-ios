//
//  LoginSplashViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/8/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import FontAwesome_swift
import FacebookCore
import FBSDKCoreKit
import FacebookLogin
import PKHUD

class LoginSplashViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var continueWithFacebookButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    var facebookLoginDetails: FacebookLoginDetails? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAdditionalBottomInsetsIfNeeded()
        
        signUpButton.layer.cornerRadius = 8
        continueWithFacebookButton.layer.cornerRadius = 8
        logoImageView.layer.cornerRadius = 12
        
        let gradientLayer = CAGradientLayer.appStyleGradient()
        gradientLayer.frame = view.bounds
        
        
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = [UIColor(named: "GradientLight")!.cgColor, UIColor(named: "DarkLISA")!.cgColor]
        animation.toValue = [UIColor(named: "DarkLISA")!.cgColor, UIColor(named: "GradientLight")!.cgColor]
        animation.duration = 5.0
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        gradientLayer.add(animation, forKey: nil)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
//        createParticles()
        
        headlineLabel.textColor = .white
        bodyLabel.textColor = .white
        signInButton.tintColor = .white
        
        logoImageView.layer.shadowPath = UIBezierPath(rect: logoImageView.bounds).cgPath
        logoImageView.layer.shadowRadius = 10
        logoImageView.layer.shadowOffset = .zero
        logoImageView.layer.shadowOpacity = 1
        // Do any additional setup after loading the view.
        
        
        let facebookFont = UIFont.fontAwesome(ofSize: 20, style: .brands)
        let systemBoldFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        let fullText = "facebook   Continue with Facebook"
        let attributedString = NSMutableAttributedString(string: fullText, attributes: nil)
        
        let logoRange = (attributedString.string as NSString).range(of: "facebook")
        let textRange = (attributedString.string as NSString).range(of: "   Continue with Facebook")
        attributedString.setAttributes([NSAttributedString.Key.font: facebookFont, NSAttributedString.Key.foregroundColor: UIColor.white], range: logoRange)
        attributedString.setAttributes([NSAttributedString.Key.font: systemBoldFont, NSAttributedString.Key.foregroundColor: UIColor.white], range: textRange)
        
        continueWithFacebookButton.setAttributedTitle(attributedString, for: .normal)
        
        
        
        let systemRegularFont = signInButton.titleLabel!.font!
        let angleRightFont = UIFont.fontAwesome(ofSize: systemRegularFont.pointSize, style: .solid)
        
        let signInText = "Sign in  chevron-right"
        let signInAttributedString = NSMutableAttributedString(string: signInText, attributes: nil)
        let signInRange = (signInAttributedString.string as NSString).range(of: "Sign in")
        let angleRightRange = (signInAttributedString.string as NSString).range(of: "chevron-right")
        signInAttributedString.setAttributes([NSAttributedString.Key.font: systemRegularFont, NSAttributedString.Key.foregroundColor: UIColor.white], range: signInRange)
        signInAttributedString.setAttributes([NSAttributedString.Key.font: angleRightFont, NSAttributedString.Key.foregroundColor: UIColor.white], range: angleRightRange)
        
        signInButton.setAttributedTitle(signInAttributedString, for: .normal)
        
    }
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0, y: view.frame.height / 2.0)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        particleEmitter.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = .pi
        cell.spinRange = 5
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.color = UIColor(white: 1, alpha: 0.1).cgColor
        cell.alphaSpeed = -0.025
        cell.contents = UIImage(named: "Particle")?.cgImage
        particleEmitter.emitterCells = [cell]
        
        view.layer.insertSublayer(particleEmitter, at: 1)
    }
    
    
    @IBAction func continueWithFacebookTapped(_ sender: UIButton) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                print("Granted permissions: \(grantedPermissions)")
                print("Declined permissions: \(declinedPermissions)")
                print("Access token details: { userId: \(accessToken.userID), authenticationToken: \(accessToken.tokenString)")
                let userId = accessToken.userID
                
                let connection = GraphRequestConnection()
                
                let profileRequest = GraphRequest(graphPath: "/me",
                                                  parameters: ["fields": "id, name, picture.type(large)"],
                                                  httpMethod: .get)
                
                connection.add(profileRequest) { connection, result, error in
                    if let result = result as? [String: Any] {
                        print("Custom Graph Request Succeeded: \(result)")
                        
                        if let imageUrlString = result["imageUrl"] as? String, let imageUrl = URL(string: imageUrlString) {
                            let imageRequest = NetworkRequest(url: imageUrl, method: .GET, data: nil, headers: nil)
                            imageRequest.execute(withCompletion: { (data) in
                                guard let data = data, let _ = UIImage(data: data) else {
                                    let facebookResponse = FacebookLoginDetails(name: result["name"] as? String, email: result["email"] as? String, imageData: nil)
                                    self.loginWithFacebookAuth(token: accessToken.tokenString, userId: userId, fbDetails: facebookResponse)
                                    return
                                }
                                
                                let facebookResponse = FacebookLoginDetails(name: result["name"] as? String, email: result["email"] as? String, imageData: data)
                                self.loginWithFacebookAuth(token: accessToken.tokenString, userId: userId, fbDetails: facebookResponse)
                                return
                            })
                        } else {
                            let facebookResponse = FacebookLoginDetails(name: result["name"] as? String, email: result["email"] as? String, imageData: nil)
                            
                            self.loginWithFacebookAuth(token: accessToken.tokenString, userId: userId, fbDetails: facebookResponse)
                        }
                    } else {
                        if let error = error {
                          print("Custom Graph Request Failed: \(error)")
                        }
                        
                    }
                }
                connection.start()
            }
        }
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "jumpToAccountCreation" {
            let destVC = segue.destination as! SignUpCreateAccountViewController
            destVC.stepNumber = 1
            destVC.maxSteps = 4
        } else if identifier == "jumpToProfileCreation" {
            let destVC = segue.destination as! SignUpCreateProfileViewController
            destVC.stepNumber = 1
            destVC.maxSteps = 3
            destVC.facebookLoginDetails = facebookLoginDetails
        }
    }
}

private extension LoginSplashViewController {
    func loginWithFacebookAuth(token: String, userId: String, fbDetails: FacebookLoginDetails?) {
        HUD.show(.progress)
        let socialAuthModel = SocialMediaAuthUser(token: token, providerId: userId)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .useDefaultKeys
        
        guard let socialAuthData = try? jsonEncoder.encode(socialAuthModel) else {
            print("ERROR ERROR ERROR")
            return
        }
        print(String(data: socialAuthData, encoding: .utf8)!)
        
        let socialAuthRequest = NetworkRequest(url: URL(string: AppAPIBase.SocialAuth)!,
                                               method: .POST, data: socialAuthData, headers: AppAPIBase.StandardHeaders)
        socialAuthRequest.execute { (data) in
            guard let data = data else {
                print("False response")
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            if let userDetails = try? jsonDecoder.decode(LoginDetails.self, from: data) {
                print(userDetails)
                CombinedUserInformation.shared.setLoginDetails(userDetails)
                
                self.checkForExistingProfile(completion: { [unowned self] (profileExists) in
                    if profileExists {
                        HUD.flash(.success)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        HUD.hide()
                        self.facebookLoginDetails = fbDetails
                        self.performSegue(withIdentifier: "jumpToProfileCreation", sender: nil)
                    }
                })
            }
        }
    }
    
    func checkForExistingProfile(completion: @escaping (Bool) -> Void) {
        AppAPIBase.getUserDetails(completion: { (success) in
            if success {
                AppAPIBase.getUserProfile(completion: { (success) in
                    if success {
                        AppAPIBase.getCustomerProfile(completion: { (success) in
                            if success {
                                if let profilePhotoURL = CombinedUserInformation.shared.baseProfile()!.profilePhotoURL {
                                    AppAPIBase.getProfilePhoto(path: URL(string: profilePhotoURL)!, completion: { (success) in
                                        if success {
                                            completion(true)
                                        } else {
//                                            HUD.flash(.error)
//                                            HUD.flash(.success)
//                                            self.displayAlertWithOK(title: "Unable to retrieve profile photo", body: "Please ensure you have a working internet connection.")
                                            completion(true)
                                        }
                                    })
                                } else {
                                    completion(true)
                                }
                            } else {
                                HUD.flash(.error)
                                self.displayAlertWithOK(title: "Unable to fetch customer details", body: "Please ensure you have a working internet connection.")
                                completion(true)
                            }
                        })
                    } else {
//                        HUD.flash(.error)
                        completion(false)
                    }
                })
            } else {
//                HUD.flash(.error)
//                self.displayAlertWithOK(title: "Unable to fetch user details", body: "Please ensure you have a working internet connection.")
                completion(false)
            }
        })
    }
}

