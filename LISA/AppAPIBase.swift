//
//  AppAPIBase.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/6/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import Foundation
import UIKit

struct AppAPIBase {
    static let baseURL = "https://lisa-cleaning-service.herokuapp.com"
//    static let baseURL = "http://localhost:8000"
    static let APIPath = AppAPIBase.baseURL + "/api/v1"
    static let LoginDetailsPath = AppAPIBase.baseURL + "/auth/users/me/"
    static let SocialAuth = AppAPIBase.baseURL + "/auth/mobile_social"
    static let CreateUserAuth = AppAPIBase.baseURL + "/auth/users/create"
    static let JWTLoginPath = AppAPIBase.baseURL + "/auth/jwt/create/"
    static let ProfilePath = AppAPIBase.APIPath + "/profile/"
    static let CustomerProfilePath = AppAPIBase.ProfilePath + "customer"
    static let AddressesPath = AppAPIBase.APIPath + "/addresses/"
    static let ServicesPath = AppAPIBase.APIPath + "/services/"
    static let CreateBookingPath = AppAPIBase.APIPath + "/create_booking/"
    static let BookingsPath = AppAPIBase.APIPath + "/bookings/"
    static let APNSRegistrationPath = AppAPIBase.APIPath + "/device/apns/"
    static let ProfilePicturePath = AppAPIBase.ProfilePath + "profile_photo"
    
    static func CancelBookingPath(forId id: Int) -> String {
        return AppAPIBase.BookingsPath + "\(id)/cancel"
    }
    
    static let StandardHeaders: [String: String] = {
        var sharedHeaders = [String: String]()
        sharedHeaders["Content-Type"] = "application/json"
        return sharedHeaders
    }()
    
    static func standardHeaders(withToken token: String?) -> [String: String] {
        var sharedHeaders = [String: String]()
        sharedHeaders["Content-Type"] = "application/json"
        if let token = token {
            sharedHeaders["Authorization"] = "Bearer \(token)"
        }
        return sharedHeaders
    }
    
    static func getUserDetails(completion: @escaping (Bool) -> Void) {
        print("INSIDE GET USER DETAILS")
        let userDetailsRequest = NetworkRequest(url: URL(string: AppAPIBase.LoginDetailsPath)!, method: .GET, data: nil, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()!.accessToken))
        print("TOKEN: \(CombinedUserInformation.shared.loginDetails()!.accessToken)")
        print("TOKEN: \(userDetailsRequest.urlRequest.allHTTPHeaderFields!)")
        print("PATH: \(userDetailsRequest.urlRequest.url!)")
        
        userDetailsRequest.execute { (data) in
            guard let data = data else {
                completion(false)
                return
            }
            
            guard let userDetails = try? JSONDecoder().decode(UserDetails.self, from: data) else {
                print(String(data: data, encoding: .utf8))
                completion(false)
                return
            }
            
            CombinedUserInformation.shared.setUserDetails(userDetails)
            completion(true)
        }
    }
    
    static func getUserProfile(completion: @escaping (Bool) -> Void) {
        let userProfileRequest = NetworkRequest(url: URL(string: AppAPIBase.ProfilePath)!, method: .GET, data: nil, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()!.accessToken))
        
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
    
    static func getCustomerProfile(completion: @escaping (Bool) -> Void) {
        let customerProfileRequest = NetworkRequest(url: URL(string: AppAPIBase.CustomerProfilePath)!, method: .GET, data: nil, headers: AppAPIBase.standardHeaders(withToken: CombinedUserInformation.shared.loginDetails()!.accessToken))
        
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
    
    static func getProfilePhoto(path: URL, completion: @escaping (Bool) -> Void) {
        let profilePhotoRequest = NetworkRequest(url: path, method: .GET, data: nil, headers: nil)
        
        profilePhotoRequest.execute { (data) in
            guard let data = data, let photo = UIImage(data: data) else {
                CombinedUserInformation.shared.setProfilePhoto(nil)
                // iffy about the below
                completion(true)
                return
            }
            
            CombinedUserInformation.shared.setProfilePhoto(photo)
            completion(true)
        }
    }
    
    static func createProfilePhoto(withImage image: UIImage, filenamePrefix: String, completion: @escaping (Bool) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(false)
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let multipartBody = NetworkRequest.createMultipartBody(parameters: nil, boundary: boundary, data: imageData, mimeType: "image/jpeg", filename: "\(filenamePrefix)-\(UUID().uuidString).jpeg")
        
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
}
