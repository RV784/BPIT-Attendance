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
    var forgotPassword = false
    var otp = ""
    var email = ""
    
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
        if forgotPassword {
            oldPasswordTextField.isHidden = true
        }
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
    
    func fillAllFieldsError() {
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
        if forgotPassword {
            if confirmPasswordTextField.text == "" || newPasswordTextField.text == "" {
                return false
            }
        } else {
            if confirmPasswordTextField.text == "" || newPasswordTextField.text == "" || oldPasswordTextField.text == "" {
                fillAllFieldsError()
                return false
            }
        }
        
        if confirmPasswordTextField.text != newPasswordTextField.text {
            matchPasswordError()
            return false
        }
        
        return true
    }
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        if checkAllErrors() {
            submitNewPassword()
        }
    }
    
    //MARK: API CALLS
    func submitNewPassword() {
//        loader.startAnimating()
        submitBtn.setTitle("", for: .normal)
        if forgotPassword {
            oldPasswordTextField.text = ""
        }
        let parameters: [String: Any] = ["current_password": oldPasswordTextField.text,
                                         "new_password": newPasswordTextField.text,
                                         "new_password_confirm": confirmPasswordTextField.text,
                                         "password_otp": otp,
                                         "email": email
        ] as Dictionary<String, Any>
        
        guard let url = URL(string: EndPoints.setNewPassword.description) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            DispatchQueue.main.async {
//                self.loader.stopAnimating()
                self.submitBtn.setTitle("Submit", for: .normal)
                //stop loader
            }
            print(String(data: data!, encoding: .utf8))
            if error != nil {
                print("Inside get OTP error")
                print(error?.localizedDescription)
            } else {
                do{
//                    let d1 = try JSONDecoder().decode(ForgotPasswordEmailResponseModel.self, from: data!)
//                    DispatchQueue.main.async {
//                        if let message = d1.message {
//                            DispatchQueue.main.async {
//                                //show OTP boxes
//                                if message != "Invalid Email" {
//                                    self.ifOtp = true
//                                    self.submitBtn.setTitle("Verify OTP", for: .normal)
//                                    self.otpStackView.isHidden = false
//                                    self.textFieldsCollection[0].becomeFirstResponder()
//                                    self.messageLabel.text = message
//                                } else {
//                                    self.messageLabel.text = message
//                                }
//                            }
//                            print(message)
//                        } else {
//                            //show wrong email alert
//                            print("Wrong email alert")
//                        }
//                    }
                } catch(let error) {
                    print(error.localizedDescription)
                }
            }
        })
        task.resume()
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    
}
