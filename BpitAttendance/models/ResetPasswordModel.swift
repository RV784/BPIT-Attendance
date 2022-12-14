//
//  ResetPasswordModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 04/11/22.
//

import UIKit

struct ResetPasswordModel: Codable {
    var message: String?
    var token: String?
    var error: [String]?
}
