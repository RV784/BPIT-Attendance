//
//  ProfileModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 28/09/22.
//

import UIKit

struct ProfileModel: Codable {
    var id: Int
    var email: String
    var name: String
    var phone_number: String
    var is_staff: Bool
    var is_superuser: Bool
    var is_active: Bool
    var date_joined: String
    var designation: String
    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case email
//        case name
//        case designation
//        case phoneNumber = "phone_number"
//        case isStaff = "is_staff"
//        case isSuperUser = "is_superuser"
//        case isActive = "is_active"
//        case dateJoined = "date_joined"
//    }
}
