//
//  ProfileModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 28/09/22.
//

import UIKit

struct ProfileModel: Codable {
    let id: Int?
    let email: String?
    let name: String?
    let designation: String?
    let phoneNumber: String?
    let isStaff: Bool?
    let isSuperUser: Bool?
    let isActive: Bool?
    let dateJoined: String?
    let image_url: String?
    
    enum CodingKeys: String, CodingKey {
        case id,
             email,
             name,
             designation,
             phoneNumber = "phone_number",
             isStaff = "is_staff",
             isSuperUser = "is_superuser",
             isActive = "is_active",
             dateJoined = "date_joined",
             image_url
    }
}
