//
//  APIManager.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 04/11/22.
//

import Foundation

final class APIManager {
    static let shared = APIManager()
    
    private init(){ }
    
    func request(isToken: Bool,
                 params: [String: Any]? = nil,
                 endpoint: EndPoints,
                 requestType: RequestType,
                 postData: Data?,
                 _ success: @escaping (Data?, URLResponse?) -> Void,
                 _ failure: @escaping (Error?) -> Void) {
        
        guard let url = URL(string: endpoint.description) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let params = params {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        }
        
        if isToken {
            guard let tok = Credentials.shared.defaults.string(forKey: "Token"),
                  tok != "" else {
                failure(nil)
                //TODO: back to login Screen
                return
            }
            request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        }
        
        if let data = postData {
            request.httpBody = data
        }
        
        print("Request START ----------------------------------")
        print(request.cURL(pretty: true))
        print("Request END ------------------------------------")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            
            DispatchQueue.main.async {
                if error != nil {
                    failure(error)
                } else {
                    success(data, response)
                }
            }
        })
        
        task.resume()
    }
}

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}
