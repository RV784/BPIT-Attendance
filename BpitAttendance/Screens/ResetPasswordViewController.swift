//
//  ResetPasswordViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 09/10/22.
//

import UIKit

class ResetPasswordViewController: BaseViewController {
    
    
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    var forgotPassword = false
    var firstLogin = false
    var resetPassword = false
    var otp = ""
    var email = ""
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ResetPasswordViewController.dismissKeyboard))
        baseView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ResetPasswordViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ResetPasswordViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func oldTextFieldDidChange(_ textField: UITextField) {
        
    }
    
    @objc func newtextFieldDidChange(_ textField: UITextField) {
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }
    
    @IBAction func textDidChanged(_ sender: Any) {
        if confirmPasswordTextField.text != newPasswordTextField.text {
            confirmPasswordTextField.layer.borderWidth = 0.5
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
            submitBtn.backgroundColor = .systemGray2
        } else if confirmPasswordTextField.text != "" &&
                    newPasswordTextField.text != "" &&
                    oldPasswordTextField.text != "" {
            submitBtn.backgroundColor = .link
            confirmPasswordTextField.layer.borderWidth = 0
        } else {
            submitBtn.backgroundColor = .systemGray2
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {               return
        }
        
        let bottomOfSignInBtn = submitBtn.convert(submitBtn.bounds, to: self.view).maxY
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        
        if bottomOfSignInBtn > topOfKeyboard {
            baseView.frame.origin.y = 0 - (bottomOfSignInBtn - topOfKeyboard) - keyboardSize.height*0.1
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        baseView.frame.origin.y = 0
    }
    
    func navigateToLoginAgain() {
        
        let alertController = UIAlertController(title: "Oops!", message: "Seems link your token expired, we'll redirect you to LogIn screen to refresh your token", preferredStyle: .alert)
        let gotoButton = UIAlertAction(title: "Go to Login Screen", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("gotoButton Pressed")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "ViewController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }
        alertController.addAction(gotoButton)
        self.present(alertController, animated: true, completion: nil)
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "ViewController")
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }
        alertController.addAction(backToLoginAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func successfulResetPassword() {
        let alertController = UIAlertController(title: "Password reset successful", message: "", preferredStyle: .alert)
        let confirmation = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBar")
            mainTabBarController.overrideUserInterfaceStyle = .dark
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        }
        alertController.addAction(confirmation)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSamePasswordError() {
        let alertController = UIAlertController(title: "Alert", message: "Old password and new password cannot be same", preferredStyle: .alert)
        let confirmation = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            self.oldPasswordTextField.text = ""
            self.newPasswordTextField.text = ""
            self.confirmPasswordTextField.text = ""
            self.oldPasswordTextField.becomeFirstResponder()
        }
        alertController.addAction(confirmation)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func somethingGoneWrongError() {
        let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        if checkAllErrors() {
            submitNewPassword()
        }
    }
    
    func processData(data: ResetPasswordModel) {
        if data.message != nil {
            showBackToLoginAlert()
        } else if data.token != nil {
            Credentials.shared.defaults.set(data.token, forKey: "Token")
            successfulResetPassword()
        } else if data.error?.first != nil {
            showSamePasswordError()
        }
    }
    
    //MARK: API CALLS
    func submitPassword() {
        if forgotPassword {
            oldPasswordTextField.text = ""
        }
        
        if forgotPassword {
            let params = ["current_password": oldPasswordTextField.text ?? "",
                      "new_password": newPasswordTextField.text ?? "",
                      "new_password_confirm": confirmPasswordTextField.text ?? "",
                      "password_otp": otp,
                      "forget": true,
                      "email": email
            ] as Dictionary<String, Any>
            changeFirstPassword(with: params)
        } else {
            let params  = ["current_password": oldPasswordTextField.text ?? "",
                       "new_password": newPasswordTextField.text ?? "",
                       "new_password_confirm": confirmPasswordTextField.text ?? "",
            ] as Dictionary<String, Any>
            changePassword(with: params)
        }
    }
    
    func changeFirstPassword(with params: [String: Any]) {
        startLoading()
        request(
            isToken: false,
            params: params,
            endpoint: .setNewPassword,
            requestType: .put,
            postData: nil) { [weak self] data in
                self?.stopLoading()
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(ResetPasswordModel.self, from: data)
                        self?.processData(data: response)
                        return
                    } catch let error {
                        print(error)
                    }
                }
                self?.showGenericErrorAlert()
            } _: { [weak self] error in
                self?.stopLoading()
                self?.showGenericErrorAlert()
                print("Error in Request/Response \(EndPoints.setNewPassword.description) \(String(describing: error))")
            }
    }
    
    func changePassword(with params: [String: Any]) {
        startLoading()
        request(
            isToken: true,
            params: params,
            endpoint: .setNewPassword,
            requestType: .put,
            postData: nil) { [weak self] data in
                self?.stopLoading()
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(ResetPasswordModel.self, from: data)
                        self?.processData(data: response)
                        return
                    } catch let error {
                        print(error)
                    }
                }
            } _: { [weak self] error in
                self?.stopLoading()
                print("Error in Request/Response \(EndPoints.setNewPassword.description) \(String(describing: error))")
            }
    }
    
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
            
            guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
                navigateToLoginAgain()
                return
            }
            if tok == "" {
                navigateToLoginAgain()
                return
            }
            request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        }
        
        DispatchQueue.main.async {
            self.loader.startAnimating()
        }
        
        submitBtn.setTitle("", for: .normal)
        print("______________________________")
        print(EndPoints.setNewPassword.description)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error -> Void in
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            
            DispatchQueue.main.async {
                self?.loader.stopAnimating()
                self?.submitBtn.setTitle("Submit", for: .normal)
            }
            //            print(String(data: data!, encoding: .utf8))
            if error != nil {
                print("Inside get OTP error")
                print(error?.localizedDescription as Any)
                print("______________________________")
                
                DispatchQueue.main.async {
                    self?.somethingGoneWrongError()
                }
            } else {
                do{
                    let d1 = try JSONDecoder().decode(ResetPasswordModel.self, from: data!)
                    print(d1)
                    print("______________________________")
                    DispatchQueue.main.async {
                        if d1.message != nil {
                            self?.showBackToLoginAlert()
                        } else if d1.token != nil {
                            Credentials.shared.defaults.set(d1.token, forKey: "Token")
                            self?.successfulResetPassword()
                        } else if d1.error?.first != nil {
                            self?.showSamePasswordError()
                        }
                    }
                } catch(let error) {
                    print(error.localizedDescription)
                    print("______________________________")
                    DispatchQueue.main.async {
                        self?.somethingGoneWrongError()
                    }
                }
            }
        })
        task.resume()
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    
}
