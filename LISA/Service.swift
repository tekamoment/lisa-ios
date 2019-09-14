//
//  Service.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/6/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import Foundation
import UIKit

struct Service {
    let id: Int
    let title: String
    let description: String
    var features: [ServiceFeature]
    var prices: [ServicePrice]
    let headerPhoto: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, features, prices, headerPhoto = "header_photo"
    }
}

extension Service: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        description = try values.decode(String.self, forKey: .description)
        features = try values.decode([ServiceFeature].self, forKey: .features)
        prices = try values.decode([ServicePrice].self, forKey: .prices)
        headerPhoto = try values.decodeIfPresent(String.self, forKey: .headerPhoto)
    }
}


struct ServiceFeature {
    let id: Int
    let title: String
    let description: String
    let mainPhotoURL: String?
    let secondaryPhotoURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, mainPhotoURL = "main_photo", secondaryPhotoURL = "secondary_photo"
    }
}

extension ServiceFeature: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        description = try values.decode(String.self, forKey: .description)
        mainPhotoURL = try values.decodeIfPresent(String.self, forKey: .mainPhotoURL)
        secondaryPhotoURL = try values.decodeIfPresent(String.self, forKey: .secondaryPhotoURL)
    }
}

struct ServicePrice {
    let id: Int
    let price: Float
    let durationInMinutes: Int
    
    enum CodingKeys: String, CodingKey {
        case id, price, durationInMinutes = "duration_in_minutes"
    }
}

extension ServicePrice: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        price = Float(try values.decode(String.self, forKey: .price))!
        durationInMinutes = try values.decode(Int.self, forKey: .durationInMinutes)
        
    }
}

struct Booking {
    let id: Int
    let comment: String?
    let datetimeRequested: Date
    let totalAmount: Double
    let durationInMinutes: Int
    let address: Address
    let status: String
    let cleanerName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, comment, dateTimeRequested = "datetime_requested", totalAmount = "total_amount", durationInMinutes = "duration_in_minutes", address = "address", status, cleanerName = "cleaner_name"
    }
    
    func sanitizedStatus() -> String {
        if status == "user_cancelled" {
            return "Cancelled"
        } else if status == "partner_cancelled" {
            return "Created"
        } else {
            return status.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

extension Booking: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
//        id = 0
        comment = try values.decodeIfPresent(String.self, forKey: .comment)
        datetimeRequested = try values.decode(Date.self, forKey: .dateTimeRequested)
        let totalAmountString = try values.decode(String.self, forKey: .totalAmount)
        totalAmount = Double(totalAmountString)!
        durationInMinutes = try values.decode(Int.self, forKey: .durationInMinutes)
        address = try values.decode(Address.self, forKey: .address)
        status = try values.decode(String.self, forKey: .status)
        cleanerName = try values.decodeIfPresent(String.self, forKey: .cleanerName)
    }
}


struct Address {
    let id: Int?
    let label: String?
    let subPremise: String?
    let premise: String?
    let thoroughfare: String?
    let postalCode: String?
    let locality: String?
    let dependentLocality: String?
    let subAdministrativeArea: String?
    let administrativeArea: String?
    let country: String?
    
    var description: String {
        return label ?? "Address"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, label, subPremise = "sub_premise", premise, thoroughfare, postalCode = "postal_code", locality, dependentLocality = "dependent_locality", subAdministrativeArea = "sub_administrative_area", administrativeArea = "administrative_area", country
    }
    
    
}

extension Address: Codable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        subPremise = try values.decodeIfPresent(String.self, forKey: .subPremise)
        premise = try values.decodeIfPresent(String.self, forKey: .premise)
        thoroughfare = try values.decodeIfPresent(String.self, forKey: .thoroughfare)
        postalCode = try values.decodeIfPresent(String.self, forKey: .postalCode)
        locality = try values.decodeIfPresent(String.self, forKey: .locality)
        dependentLocality = try values.decodeIfPresent(String.self, forKey: .dependentLocality)
        subAdministrativeArea = try values.decodeIfPresent(String.self, forKey: .subAdministrativeArea)
        administrativeArea = try values.decodeIfPresent(String.self, forKey: .administrativeArea)
        country = try values.decodeIfPresent(String.self, forKey: .country)
    }
    
    func concatenatedAddress() -> String {
        let fieldSequence = [subPremise, premise, thoroughfare, dependentLocality, locality, subPremise, administrativeArea, postalCode, country].compactMap { $0 }
        return fieldSequence.joined(separator: ", ")
    }
}

extension Address: Equatable {
    static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.id == rhs.id
    }
}

struct BookingRequest {
    let requestedStartDatetime: Date
    let addressId: Int
    let comment: String?
    let requestedServices: [ServiceRequest]
    
    struct ServiceRequest: Encodable {
        let serviceId: Int
        let priceId: Int
        
        enum CodingKeys: String, CodingKey {
            case serviceId = "service_id", priceId = "price_id"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case addressId = "address_id", requestedStartDatetime = "requested_start_datetime", comment, requestedServices = "requested_services"
    }
}


extension BookingRequest: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestedStartDatetime, forKey: .requestedStartDatetime)
        try container.encode(addressId, forKey: .addressId)
        if let comment = comment {
            try container.encode(comment, forKey: .comment)
        }
        try container.encode(requestedServices, forKey: .requestedServices)
    }
}

struct PatchBaseProfile {
    let fullName: String?
    let contactNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name", contactNumber = "contact_number"
    }
}

extension PatchBaseProfile: Codable {}


struct BaseProfile {
    let fullName: String
    let contactNumber: String
    let profilePhotoURL: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name", contactNumber = "contact_number", profilePhotoURL = "profile_photo"
    }
}

extension BaseProfile: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(contactNumber, forKey: .contactNumber)
        try container.encodeIfPresent(profilePhotoURL, forKey: .profilePhotoURL)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fullName = try values.decode(String.self, forKey: .fullName)
        contactNumber = try values.decode(String.self, forKey: .contactNumber)
        
        let profilePhotoURL = try values.decodeIfPresent(String.self, forKey: .profilePhotoURL)
        if profilePhotoURL == nil {
            self.profilePhotoURL = nil
        } else {
            if profilePhotoURL == "" {
                self.profilePhotoURL = nil
            } else {
                self.profilePhotoURL = profilePhotoURL
            }
        }
    }
    
}


struct CustomerProfile {
    let birthDate: Date
    
    enum CodingKeys: String, CodingKey {
        case birthDate = "birth_date"
    }
}

extension CustomerProfile: Codable {
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let dateString = try? container.decode(String.self, forKey: .birthDate) {
            let formatter = DateFormatter.iso8601Truncated
            if let date = formatter.date(from: dateString) {
                birthDate = date
            } else {
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.birthDate, in: container, debugDescription: "Birthday did not ft the expected format of yyyy-MM-dd,")
            }
        } else if let dateDate = try? container.decode(Date.self, forKey: .birthDate) {
            birthDate = dateDate
        } else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.birthDate, in: container, debugDescription: "Birthday did not ft the expected format of yyyy-MM-dd,")
        }
    }
    
    
    
}


struct SocialMediaAuthUser: Encodable {
    let provider: String = "facebook"
    let token: String
    let providerId: String
    
    enum CodingKeys: String, CodingKey {
        case provider, token, providerId = "provider_id"
    }
}


struct UserCreation: Encodable {
    let username: String
    let email: String
    let password: String
}

struct UserLogin: Encodable {
    let username: String
    let password: String
}



struct LoginDetails {
    let username: String?
    let email: String?
    let userId: Int?
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case username, email, userId = "id", accessToken = "access", refreshToken = "refresh"
    }
}

extension LoginDetails: Codable {
    init (from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
        accessToken = try values.decode(String.self, forKey: .accessToken)
        refreshToken = try values.decode(String.self, forKey: .refreshToken)
    }
}

struct UserDetails {
    let username: String
    let id: Int
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case username, id, email
    }
}

extension UserDetails: Codable {}


struct APNSRequest: Encodable {
    let registrationId: String
    
    enum CodingKeys: String, CodingKey {
        case registrationId = "registration_id"
    }
}


struct CombinedUserInformation {
    static let shared = CombinedUserInformation()
    
    private var loginDeets: LoginDetails? = nil
    private var baseDeets: BaseProfile? = nil
    private var customerDeets: CustomerProfile? = nil
    
    private init() {}
    
    func loginDetails() -> LoginDetails? {
        let defaults = UserDefaults.standard
        guard let loginDetailsData = defaults.object(forKey: "loginDetails") as? Data else {
            return nil
        }
        
        guard let loginDetails = try? PropertyListDecoder().decode(LoginDetails.self, from: loginDetailsData) else {
            print("horror!")
            return nil
        }
        
        return loginDetails
    }
    
    func setLoginDetails(_ details: LoginDetails?) {
        let defaults = UserDefaults.standard
        
        guard let details = details else {
            defaults.set(nil, forKey: "loginDetails")
            return
        }
        
        let loginDetailsData = try? PropertyListEncoder().encode(details)
        guard let loginDetailsDataSecure = loginDetailsData else {
            print("Cannot encode!!!")
            return
        }
        defaults.set(loginDetailsDataSecure, forKey: "loginDetails")
    }
    
    func baseProfile() -> BaseProfile? {
        let defaults = UserDefaults.standard
        guard let baseProfileData = defaults.object(forKey: "baseProfile") as? Data else {
            return nil
        }
        
        guard let baseProfile = try? PropertyListDecoder().decode(BaseProfile.self, from: baseProfileData) else {
            print("horror base profile!")
            return nil
        }
        
        return baseProfile
    }
    
    func setBaseProfile(_ profile: BaseProfile?) {
        let defaults = UserDefaults.standard
        
        guard let profile = profile else {
            defaults.set(nil, forKey: "baseProfile")
            return
        }
        
        let baseProfileData = try? PropertyListEncoder().encode(profile)
        guard let baseProfileDataSecure = baseProfileData else {
            print("Cannot encode!!!")
            return
        }
        defaults.set(baseProfileDataSecure, forKey: "baseProfile")
    }
    
    func customerProfile() -> CustomerProfile? {
        let defaults = UserDefaults.standard
        guard let customerProfileData = defaults.object(forKey: "customerProfile") as? Data else {
            return nil
        }
        
        guard let customerProfile = try? PropertyListDecoder().decode(CustomerProfile.self, from: customerProfileData) else {
            print("horror customer profile!")
            return nil
        }
        
        return customerProfile
    }
    
    func setUserDetails(_ details: UserDetails?) {
        let defaults = UserDefaults.standard
        
        guard let details = details else {
            defaults.set(nil, forKey: "userDetails")
            return
        }
        
        let encoder = PropertyListEncoder()
        
        let userDetailsData = try? encoder.encode(details)
        guard let userDetailsDataSecure = userDetailsData else {
            print("Cannot encode!!!")
            return
        }
        defaults.set(userDetailsDataSecure, forKey: "userDetails")
    }
    
    func userDetails() -> UserDetails? {
        let defaults = UserDefaults.standard
        guard let userDetailsData = defaults.object(forKey: "userDetails") as? Data else {
            return nil
        }
        
        guard let userDetails = try? PropertyListDecoder().decode(UserDetails.self, from: userDetailsData) else {
            print("horror customer profile!")
            return nil
        }
        
        return userDetails
    }
    
    func setCustomerProfile(_ profile: CustomerProfile?) {
        let defaults = UserDefaults.standard
        
        guard let profile = profile else {
            defaults.set(nil, forKey: "customerProfile")
            return
        }
        
        let encoder = PropertyListEncoder()
        
        let customerProfileData = try? encoder.encode(profile)
        guard let customerProfileDataSecure = customerProfileData else {
            print("Cannot encode!!!")
            return
        }
        defaults.set(customerProfileDataSecure, forKey: "customerProfile")
    }
    
    private static let fileName = "/profilePhoto.jpeg"
    
    func setProfilePhoto(_ photo: UIImage?) {
        guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        
        let destinationPath = documentsDirectory.appending(CombinedUserInformation.fileName)
        
        if let photo = photo {
            let destinationURL = URL(fileURLWithPath: destinationPath)
            guard let photoData = photo.jpegData(compressionQuality: 1.0), let _ = try? photoData.write(to: destinationURL, options: .atomicWrite) else {
                return
            }
        } else {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: destinationPath) {
                do {
                    try fileManager.removeItem(atPath: destinationPath)
                } catch _ as NSError {
                    return
                }
            } else {
                return
            }
        }
    }
    
    func profilePhoto() -> UIImage? {
        guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        
        let destinationPath = documentsDirectory.appending(CombinedUserInformation.fileName)
        return UIImage(contentsOfFile: destinationPath)
    }
    
    func logOut() {
        CombinedUserInformation.shared.setBaseProfile(nil)
        CombinedUserInformation.shared.setCustomerProfile(nil)
        CombinedUserInformation.shared.setLoginDetails(nil)
        CombinedUserInformation.shared.setProfilePhoto(nil)
    }

}

struct FacebookLoginDetails {
    let name: String?
    let email: String?
//    let imageURL: URL?
    let imageData: Data?
}

struct ProfilePhotoSuccess: Decodable {
    let profilePhotoURL: String
    
    enum CodingKeys: String, CodingKey {
        case profilePhotoURL = "profile_photo"
    }
}
