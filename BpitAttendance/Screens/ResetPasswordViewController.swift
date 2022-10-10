//
//  ResetPasswordViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 09/10/22.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 12
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        oldPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        confirmPasswordTextField.addTarget(self, action: #selector(ResetPasswordViewController.textFieldDidChange(_:)),
                                  for: .editingChanged)
        oldPasswordTextField.addTarget(self, action: #selector(ResetPasswordViewController.oldTextFieldDidChange(_:)),
                                  for: .editingChanged)
        newPasswordTextField.addTarget(self, action: #selector(ResetPasswordViewController.newtextFieldDidChange(_:)),
                                  for: .editingChanged)
        
    }
    
    @objc func oldTextFieldDidChange(_ textField: UITextField) {
        
    }
    
    @objc func newtextFieldDidChange(_ textField: UITextField) {
        
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if confirmPasswordTextField.text != newPasswordTextField.text {
            confirmPasswordTextField.layer.borderWidth = 0.5
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
        } else {
            confirmPasswordTextField.layer.borderWidth = 0
        }
    }
    
    func fillAllFieldsErrpr() {
        let alert = UIAlertController(title: "Please fill all fields", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func matchPasswordError() {
        let alert = UIAlertController(title: "Confirmed and New password should match", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func checkAllErrors() -> Bool {
        if confirmPasswordTextField.text == "" || newPasswordTextField.text == "" || oldPasswordTextField.text == "" {
            fillAllFieldsErrpr()
            return false
        }
        
        if confirmPasswordTextField.text != newPasswordTextField.text {
            matchPasswordError()
            return false
        }
        
        
        return true
    }
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        if checkAllErrors() {
            
        }
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    
}
