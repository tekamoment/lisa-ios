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
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        
        view.addSubview(loginButton)
        // Do any additional setup after loading the view.
        
        if let accessToken = AccessToken.current {
            print(accessToken)
        }
    }
}

extension ViewController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(let grantedPermissions, let refusedPermissions, let accessToken):
            print("Granted permissions: \(grantedPermissions), refused permissions: \(refusedPermissions), access token: \(accessToken)")
        case .cancelled:
            break
        case .failed(let error):
            print(error)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        // Log out!
    }
    
    func graphRequestPhoto(accessToken: AccessToken) {
        guard let userId = accessToken.userId else {
            print("Missing user id in access token")
            return
        }
        let graphRequest = GraphRequest(graphPath: "/\(userId)/picture", parameters: ["redirect" : "false"], accessToken: accessToken, httpMethod: .GET, apiVersion: .defaultVersion)
        graphRequest.start { (urlResponse, requestResult) in
            print(urlResponse)
            print(requestResult)
        }
    }
}

