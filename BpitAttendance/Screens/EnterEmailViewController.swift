//
//  EnterEmailViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 10/10/22.
//

import UIKit

class EnterEmailViewController: UIViewController {

    @IBOutlet var baseView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var emailOtpStackView: UIStackView!
    @IBOutlet weak var enterEmailField: UITextField!
    var otpViewIsVisible = false
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Enter email"
        enterEmailField.delegate = self
        submitBtn.layer.cornerRadius = 12
        let tap = UITapGestureRecognizer(target: self, action: #selector(EnterEmailViewController.dismissKeyboard))
        baseView.addGestureRecognizer(tap)
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        if enterEmailField.text == "" {
            enterEmailField.layer.borderColor = UIColor.red.cgColor
            enterEmailField.layer.borderWidth = 0.5
            enterEmailField.layer.cornerRadius = 1
            return
        }
        
        emailOtpStackView.addArrangedSubview(OTPStackView())
        if checkConnection() {
            getOTP(email: enterEmailField.text ?? "")
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func checkConnection() -> Bool {
        return InternetConnectionManager.isConnectedToNetwork()
    }
}

//MARK: API CALLS
extension EnterEmailViewController {
    
    func getOTP(email: String) {
        
    }
}

//MARK: UITextFieldDelegate
extension EnterEmailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == enterEmailField {
            if ((textField.text?.isEmpty) != nil) {
                textField.layer.borderWidth = 0
            }
        }
    }
}
