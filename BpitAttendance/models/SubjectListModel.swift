//
//  SubjectListModel.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 21/09/22.
//

import UIKit

struct SubjectListModel: Codable {
    var id: Int?
    var batch: String?
    var semester: Int?
    var is_lab: Bool?
    var branch_name: String?
    var subject_code: String?
    var section: String?
    var branch_code: String?
    var subject_name: String?
    var group: String?
}
