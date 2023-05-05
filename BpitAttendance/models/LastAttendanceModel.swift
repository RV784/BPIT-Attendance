//
//  LastAttendanceModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 05/11/22.
//

import Foundation

struct LastAttendanceModel: Encodable {
    
    var record: [studentData]

    struct studentData: Encodable {
        var id: Int
        var enrollment_number: String
        var batch: String
        var name: String
        var status: Bool
        var class_roll_number: Int
        var date: String
        var subject: String
    }
}
