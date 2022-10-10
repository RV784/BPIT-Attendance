//
//  File.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 10/10/22.
//

import UIKit

class OTPTextField: UITextField {
    
    weak var previousTextField: OTPTextField?
    weak var nextTextField: OTPTextField?
    
    override public func deleteBackward() {
        text = ""
        previousTextField?.becomeFirstResponder()
    }
}
