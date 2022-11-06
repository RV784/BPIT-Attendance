//
//  ResetPasswordViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 09/10/22.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    var forgotPassword = false
    var firstLogin = false
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
        
        navigationItem.title = "Reset Password"
        navigationController?.navigationBar.prefersLargeTitles = true
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
    
    func navigateToLoginAgain() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    func showBackToLoginAlert() {
        let alertController = UIAlertController(title: "Password reset successful, Please now log in with your new Password", message: "", preferredStyle: .alert)
        let backToLoginAction = UIAlertAction(title: "Back to Login", style: UIAlertAction.Style.default) {
                UIAlertAction in
                NSLog("OK Pressed")
            Credentials.shared.defaults.set("", forKey: "Token")
            Credentials.shared.defaults.set("", forKey: "Name")
            Credentials.shared.defaults.set("", forKey: "Email")
            Credentials.shared.defaults.set("", forKey: "Designation")
            Credentials.shared.defaults.set("", forKey: "PhoneNumber")
            Credentials.shared.defaults.set("", forKey: "DateJoined")
            Credentials.shared.defaults.set(false, forKey: "Staff")
            Credentials.shared.defaults.set(false, forKey: "Active")
            Credentials.shared.defaults.set(false, forKey: "SuperUser")
            self.navigateToLoginAgain()
            }
        alertController.addAction(backToLoginAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func successfulResetPassword() {
        let alertController = UIAlertController(title: "Password reset successful, Please now log in with your new Password", message: "", preferredStyle: .alert)
        let confirmation = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                UIAlertAction in
                NSLog("OK Pressed")
            Credentials.shared.defaults.set("", forKey: "Token")
            Credentials.shared.defaults.set("", forKey: "Name")
            Credentials.shared.defaults.set("", forKey: "Email")
            Credentials.shared.defaults.set("", forKey: "Designation")
            Credentials.shared.defaults.set("", forKey: "PhoneNumber")
            Credentials.shared.defaults.set("", forKey: "DateJoined")
            Credentials.shared.defaults.set(false, forKey: "Staff")
            Credentials.shared.defaults.set(false, forKey: "Active")
            Credentials.shared.defaults.set(false, forKey: "SuperUser")
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(confirmation)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        if checkAllErrors() {
            submitNewPassword()
        }
    }
    
    //MARK: API CALLS
    func submitNewPassword() {
        
        if forgotPassword {
            oldPasswordTextField.text = ""
        }
        
        guard let url = URL(string: EndPoints.setNewPassword.description) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if forgotPassword {
            let parameters: [String: Any] = ["current_password": oldPasswordTextField.text ?? "",
                                             "new_password": newPasswordTextField.text ?? "",
                                             "new_password_confirm": confirmPasswordTextField.text ?? "",
                                             "password_otp": otp,
                                             "forget": true,
                                             "email": email
            ] as Dictionary<String, Any>
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        } else {
            let parameters: [String: Any] = ["current_password": oldPasswordTextField.text ?? "",
                                             "new_password": newPasswordTextField.text ?? "",
                                             "new_password_confirm": confirmPasswordTextField.text ?? "",
            ] as Dictionary<String, Any>
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        
        loader.startAnimating()
        submitBtn.setTitle("", for: .normal)
        print("______________________________")
        print(EndPoints.setNewPassword.description)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error -> Void in
            
            DispatchQueue.main.async {
                self?.loader.stopAnimating()
                self?.submitBtn.setTitle("Submit", for: .normal)
            }
            
            if error != nil {
                print("Inside get OTP error")
                print(error?.localizedDescription as Any)
                print("______________________________")
            } else {
                do{
                    let d1 = try JSONDecoder().decode(ResetPasswordModel.self, from: data!)
                    print(d1)
                    print("______________________________")
                    DispatchQueue.main.async {
                        if d1.message != nil {
                            self?.showBackToLoginAlert()
                        } else if d1.token != nil {
                            self?.successfulResetPassword()
                        }
                    }
                } catch(let error) {
                    print(error.localizedDescription)
                    print("______________________________")
                }
            }
        })
        task.resume()
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    
}
