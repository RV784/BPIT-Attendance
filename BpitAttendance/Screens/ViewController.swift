//
//  ViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 17/09/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var deciderIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deciderView: UIView!
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginLoader: UIActivityIndicatorView!
    @IBOutlet weak var signInBtn: UIButton!
    var loginArr: [String: Any] = [:]
    var toBePopped: Bool = false
    var profileData: ProfileModel?
    var loginData: LoginModel?
 
//MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        deciderIndicator.startAnimating()
        emailTxtField.layer.cornerRadius = 12
        passwordTxtField.layer.cornerRadius = 12
        signInBtn.layer.cornerRadius = 12
        passwordTxtField.isSecureTextEntry = true
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        let forgotTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.forgotPassword))
        baseView.addGestureRecognizer(tap)
        forgotPasswordLabel.addGestureRecognizer(forgotTap)
        forgotPasswordLabel.isUserInteractionEnabled = true
        deciderView.isHidden = true
        if Credentials.shared.defaults.string(forKey: "Token") != "" {
            deciderView.isHidden = true
            navigate()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
//MARK: BUSINESS LOGIC
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {               return
            }
        
        let bottomOfSignInBtn = signInBtn.convert(signInBtn.bounds, to: self.view).maxY
        let topOfKeyboard = self.view.frame.height - keyboardSize.height

        if bottomOfSignInBtn > topOfKeyboard {
            baseView.frame.origin.y = 0 - (bottomOfSignInBtn - topOfKeyboard) - keyboardSize.height*0.1
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        baseView.frame.origin.y = 0
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @objc func forgotPassword() {
        if let enterEmailVC = storyboard?.instantiateViewController(withIdentifier: "EnterEmailViewController") as? EnterEmailViewController{
            self.navigationController?.pushViewController(enterEmailVC, animated: true)
        }
    }
    
    @IBAction func signInBtnClicked(_ sender: Any) {
        if(emailTxtField.text == ""){
            emailTxtField.layer.borderColor = UIColor.red.cgColor
            emailTxtField.layer.borderWidth = 0.5
            emailTxtField.layer.cornerRadius = 1
            return
        }else if(passwordTxtField.text == ""){
            passwordTxtField.layer.borderColor = UIColor.red.cgColor
            passwordTxtField.layer.borderWidth = 0.5
            passwordTxtField.layer.cornerRadius = 4
            return
        }
        //        print(emailTxtField.text)
        //        print(passwordTxtField.text)
        if checkConnection() {
            register(email: emailTxtField.text!, password: passwordTxtField.text!)
        } else {
            showNoInternetAlter()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func navigate(){
            if let subjectVC = storyboard?.instantiateViewController(withIdentifier: "SubjectViewController") as? SubjectViewController{
                
                self.navigationController?.pushViewController(subjectVC, animated: true)
            }
    }
    
    func showNoInternetAlter() {
        let alert = UIAlertController(title: "No Internet", message: "Your phone is not connected to Internet, Please connect and try again", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func serverDownError() {
        let alert = UIAlertController(title: "Server is facing some issues, Please try again later", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func notCorrectCredentials() {
        let alert = UIAlertController(title: "Incorrect Email or Password", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func saveToDevice() {
        Credentials.shared.defaults.set("\(profileData?.name ?? "")", forKey: "Name")
        Credentials.shared.defaults.set("\(profileData?.email ?? "")", forKey: "Email")
        Credentials.shared.defaults.set("\(profileData?.designation ?? "")", forKey: "Designation")
        Credentials.shared.defaults.set("\(profileData?.phoneNumber ?? "")", forKey: "PhoneNumber")
        Credentials.shared.defaults.set("\(profileData?.dateJoined ?? "")", forKey: "DateJoined")
        Credentials.shared.defaults.set(profileData?.isStaff, forKey: "Staff")
        Credentials.shared.defaults.set(profileData?.isActive, forKey: "Active")
        Credentials.shared.defaults.set(profileData?.isSuperUser, forKey: "SuperUser")
    }
    
    func checkConnection() -> Bool {
        return InternetConnectionManager.isConnectedToNetwork()
    }
    
    func navigateToResetPassword() {
        if let resetPasswordVC = storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController{
            
            self.navigationController?.pushViewController(resetPasswordVC, animated: true)
        }
    }
    
    
// MARK: API CALL
    func register(email: String, password: String){
        signInBtn.setTitle("", for: .normal)
        self.loginLoader.startAnimating()
        let parameters: [String: Any]  = ["email" : email, "password" : password] as Dictionary<String, Any>
        
        var request = URLRequest(url: URL(string: EndPoints.getToken.description)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            DispatchQueue.main.async {
                self.loginLoader.stopAnimating()
            }
            
            if error != nil {
                print("inside get profile erorr")
                print(error?.localizedDescription)
            } else {
                do {
                    let d1 = try JSONDecoder().decode(LoginModel.self, from: data!)
//                    print(d1.token)
                    DispatchQueue.main.async {
                        self.loginData = d1
                        if self.loginData?.token == nil {
                            self.signInBtn.setTitle("Sign In", for: .normal)
                            self.notCorrectCredentials()
                        } else {
                            
                            self.emailTxtField.text = ""
                            self.passwordTxtField.text = ""
                            self.signInBtn.setTitle("Sign In", for: .normal)
                            self.loginLoader.stopAnimating()
                            Credentials.shared.defaults.set(self.loginData?.token, forKey: "Token")
                            self.getProfileCall()
                            
                            if self.loginData?.isFirstLogin ?? false {
                                self.navigateToResetPassword()
                            } else {
                                self.navigate()
                            }
                        }
                    }
                } catch {
                    //server issue handling
                    DispatchQueue.main.async {
                        self.signInBtn.setTitle("Sign In", for: .normal)
                        self.serverDownError()
                    }
                    print(error.localizedDescription)
                }
            }
        })
        
        task.resume()
    }
    
    func getProfileCall() {
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            return
        }
        print("inside getPrifle")
        var request = URLRequest(url: URL(string: EndPoints.getProfile.description)!)
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request ,completionHandler: { [weak self] data, response, error in
            if error != nil {
                print("inside error")
                print(error?.localizedDescription as Any)
            }else{
                do{
                    let d1 = try JSONDecoder().decode(ProfileModel.self, from: data!)
                    print(d1)
                    self?.profileData = d1
                    DispatchQueue.main.async {
//                        Credentials.shared.defaults.set(self?.profileData, forKey: "ProfileData")
                        self?.saveToDevice()
                    }
                } catch(let error) {
                    print("inside catch \(error)")
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 401 {
                            print("token expired")
                        }
                    }
                }
            }
        })

        task.resume()
    }
}


//MARK: UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if emailTxtField.text != "" && passwordTxtField.text != "" {
            signInBtn.layer.backgroundColor = UIColor.systemBlue.cgColor
        } else {
            signInBtn.layer.backgroundColor = UIColor.systemGray2.cgColor
        }
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if emailTxtField.text != "" && passwordTxtField.text != "" {
            signInBtn.layer.backgroundColor = UIColor.systemBlue.cgColor
        } else {
            signInBtn.layer.backgroundColor = UIColor.systemGray2.cgColor
        }
        
        return true
    }
    
}

