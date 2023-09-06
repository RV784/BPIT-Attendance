//
//  Credentials.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 26/09/22.
//

import Foundation


class Credentials {
    static let shared = Credentials()
    
    private init() {
        
    }
    var email: String = ""
    var token: String = ""
    var password: String = ""
    var profileData: ProfileModel?
    let defaults = UserDefaults.standard
    
}
