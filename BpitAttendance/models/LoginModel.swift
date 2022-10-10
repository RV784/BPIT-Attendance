//
//  LoginModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 09/10/22.
//

import Foundation

struct LoginModel: Codable {
    let token: String?
    let name: String?
    let email: String?
    let isFirstLogin: Bool?
    
    enum CodingKeys: String, CodingKey {
        case token,
        name,
        email,
        isFirstLogin = "is_first_login"
    }
}
