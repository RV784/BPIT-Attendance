//
//  StudentListModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 21/09/22.
//

import UIKit

struct StudentListModel: Codable {
    var enrollment_number: String?
    var name: String?
    var class_roll_number: String?
    var attendance_count: Int?
}
