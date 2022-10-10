//
//  OTPStackView.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 10/10/22.
//

import Foundation
import UIKit

protocol OTPDelegate: AnyObject {
    
    //always triggers when the otp field is valid
    func didChangeValidity(isValid: Bool)
}

class OTPStackView: UIStackView {
    
    //customize OTPfield
    let numberOfField = 6
    var textFieldCollection: [OTPTextField] = []
    weak var delegate: OTPDelegate?
    var showWarningColor = false
    
    //colors
    let inactiveFieldBorderColor = UIColor(white: 1, alpha: 0.3)
    let textBackgroundColor = UIColor(white: 1, alpha: 0.5)
    let activeFIeldBorderColor = UIColor.white
    var remainingStrStack: [String] = []
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
        addOTPFields()
    }
    
    private final func setupStackView() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .center
        self.distribution = .fillEqually
        self.spacing = 8
    }
    
    private final func addOTPFields() {
        for index in 0..<numberOfField {
            let field = OTPTextField()
            setupTextField(field)
            textFieldCollection.append(field)
            
            //adding marker to previous field
            index != 0 ? (field.previousTextField = textFieldCollection[index-1]) : (field.previousTextField = nil)
            //adding marker to next field
            index != 0 ? (textFieldCollection[index-1].nextTextField = field) : ()
        }
        textFieldCollection[0].becomeFirstResponder()
    }
    
    private func setupTextField(_ textField: OTPTextField) {
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(textField)
        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        textField.backgroundColor = textBackgroundColor
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = false
        textField.textColor = .white
        textField.layer.borderColor = inactiveFieldBorderColor.cgColor
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 2
        textField.keyboardType = .numberPad
        textField.autocorrectionType = .yes
        textField.textContentType = .oneTimeCode
    }
    
    //check if all otp field are filled
    private final func checkForValidity() {
        for fields in textFieldCollection {
            if fields.text == "" {
                delegate?.didChangeValidity(isValid: false)
                return
            }
        }
        delegate?.didChangeValidity(isValid: true)
    }
    
    //set warning true for warning color
    final func setAllFieldColor(isWarningColor: Bool = false, color: UIColor ){
        for textField in textFieldCollection {
            textField.layer.borderColor = color.cgColor
        }
        showWarningColor = isWarningColor
    }
    
    //autofill textfield starting from first
    private final func autoFillTextField(with string: String) {
        remainingStrStack = string.reversed().compactMap{String($0)}
        for textField in textFieldCollection {
            if let charToAdd = remainingStrStack.popLast() {
                textField.text = String(charToAdd)
            } else {
                break
            }
        }
        checkForValidity()
        remainingStrStack = []
    }
}

extension OTPStackView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if showWarningColor {
            setAllFieldColor(color: inactiveFieldBorderColor)
            showWarningColor = false
        }
        textField.layer.borderColor = activeFIeldBorderColor.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkForValidity()
        textField.layer.borderColor = inactiveFieldBorderColor.cgColor
    }
    
    //switched bw text fields
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? OTPTextField else {
            return true
        }
        
        //when you copy paste the whole otp
        if string.count > 1 {
            textField.resignFirstResponder()
            autoFillTextField(with: string)
            return false
        } else {
            if range.length == 0 {
                if textField.nextTextField == nil {
                    textField.text? = string
                    textField.resignFirstResponder()
                } else {
                    textField.text? = string
                    textField.nextTextField?.becomeFirstResponder()
                }
                
                return false
            }
            
            return true
        }
    }
    
}
