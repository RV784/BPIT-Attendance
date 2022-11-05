//
//  LoginModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 09/10/22.
//

import Foundation

struct LoginModel: Codable {
    var token: String?
    var name: String?
    var email: String?
    var isFirstLogin: Bool?
    var id: Int?
    
    enum CodingKeys: String, CodingKey {
        case token,
        name,
        email,
        isFirstLogin = "is_first_login",
        id
    }
}
