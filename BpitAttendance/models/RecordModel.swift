//
//  RecordModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 21/09/22.
//

import UIKit

struct RecordData: Encodable {
    
    var record: [studentData]

    struct studentData: Encodable {
        var status: Bool
        var enrollment_number: String
        var subject: String
        var batch: String
    }
}
