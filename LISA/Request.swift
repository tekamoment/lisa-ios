//
//  Request.swift
//  LISA
//
//  Created by Carlos Arcenas on 5/6/19.
//  Copyright © 2019 Carlos Arcenas. All rights reserved.
//

import Foundation

protocol Request {
    var verb: RequestVerb { get }
    var pathURLString: String { get }
    var parameters: [String: Any] { get }
    var data: Data? { get }
}

enum RequestVerb: String {
    case GET
    case POST
    case PATCH
//    case PUT
    case DELETE
}

extension Request {
    func requstFromPath() -> URLRequest? {
        guard let url = URL(string: pathURLString) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = verb.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        return request
    }
}

class NetworkRequest {
    let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
    let urlRequest: URLRequest
    
    init(url: URL, method: NetworkMethod, data: Data?, headers: [String: String]?) {
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        if let data = data {
            urlRequest.httpBody = data
        }
        self.urlRequest = urlRequest
    }
    
    func execute(withCompletion completion: @escaping (Data?) -> Void) {
        let task = session.dataTask(with: urlRequest, completionHandler: { (data: Data?, _, _) -> Void in
            completion(data)
        })
        task.resume()
    }
    
    enum NetworkMethod: String {
        case GET
        case POST
        case PATCH
        case PUT
    }
    
    static func createMultipartBody(parameters: [String: String]?, boundary: String, data: Data, mimeType: String, filename: String) -> Data {
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        if let parameters = parameters {
            for (key, value) in parameters {
                body.appendString(boundaryPrefix)
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

