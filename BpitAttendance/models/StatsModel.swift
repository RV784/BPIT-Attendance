//
//  StatsModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 10/11/22.
//

import Foundation

struct StatsModel: Codable {
    var columns: [String]?
    var student_data: [StudentData]?
    
    struct StudentData: Codable {
        var name: String?
        var enrollment_number: String?
        var class_roll_no: String?
        var attendance_data: [Int]?
    }
}
