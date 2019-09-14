//
//  ViewController.swift
//  LISA
//
//  Created by Carlos Arcenas on 4/24/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBLoginButton(permissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        
        view.addSubview(loginButton)
        // Do any additional setup after loading the view.
        
        if let accessToken = AccessToken.current {
            print(accessToken)
        }
    }
}

extension ViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let result = result, let token = result.token {
            print("Granted permissions: \(result.grantedPermissions), refused permissions: \(result.declinedPermissions), access token: \(token)")
        } else if let error = error {
            print(error)
        }
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: FBLoginButton, result: LoginResult) {
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // Log out!
    }
    
    func graphRequestPhoto(accessToken: AccessToken) {
        let userId = accessToken.userID
        
        let graphRequest = GraphRequest(graphPath: "/\(userId)/picture", parameters: ["redirect" : "false"], tokenString: accessToken.tokenString, version: nil, httpMethod: .get)
        graphRequest.start { (connection, response, error) in
            print(connection)
            print(response)
        }
    }
}

