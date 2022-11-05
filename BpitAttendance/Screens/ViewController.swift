//
//  ViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 17/09/22.
//

import UIKit

protocol LoginViewControllerProtocol {
    func reloadData(isLogin: Bool)
}

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
    var tokExpMidCycle = false
    var delegate: LoginViewControllerProtocol?
 
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
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.reloadData(isLogin: tokExpMidCycle)
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
        if let enterEmailVC = storyboard?.instantiateViewController(withIdentifier: "EnterEmailViewController") as? EnterEmailViewController {
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
        if checkConnection() {
            register(email: emailTxtField.text!, password: passwordTxtField.text!)
        } else {
            showNoInternetAlter()
        }
    }
    
    func navigate() {
        if tokExpMidCycle {
            navigationController?.popViewController(animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBar")
                
                // This is to get the SceneDelegate object from your view controller
                // then call the change root view controller function to change to main tab bar
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
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
}

// MARK: API CALL
extension ViewController {
    func register(email: String, password: String) {
        
        guard let url = URL(string: EndPoints.getToken.description) else {
            return
        }
        
        signInBtn.setTitle("", for: .normal)
        self.loginLoader.startAnimating()
        print("______________________________")
        print(EndPoints.getToken.description)
        
        let parameters: [String: Any]  = ["email" : email, "password" : password] as Dictionary<String, Any>
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error -> Void in
            
            DispatchQueue.main.async {
                self?.loginLoader.stopAnimating()
            }
            
            if error != nil {
                print("inside error")
                print(error?.localizedDescription as Any)
                print("______________________________")
            } else {
                do {
                    let d1 = try JSONDecoder().decode(LoginModel.self, from: data!)
                    print(d1)
                    print("______________________________")
                    DispatchQueue.main.async {
                        self?.loginData = d1
                        if self?.loginData?.token == nil {
                            self?.signInBtn.setTitle("Sign In", for: .normal)
                            self?.notCorrectCredentials()
                        } else {
                            
                            self?.emailTxtField.text = ""
                            self?.passwordTxtField.text = ""
                            self?.signInBtn.setTitle("Sign In", for: .normal)
                            self?.loginLoader.stopAnimating()
                            Credentials.shared.defaults.set(self?.loginData?.token, forKey: "Token")
                            Credentials.shared.defaults.set(self?.loginData?.id, forKey: "Id")
//                            self?.getProfileCall()
                            
                            if self?.loginData?.isFirstLogin ?? false {
                                self?.navigateToResetPassword()
                            } else {
                                self?.navigate()
                            }
                        }
                    }
                } catch (let err) {
                    //server issue handling
                    print("inside catch error of \(EndPoints.getToken.description)")
                    print(err)
                }
            }
        })
        
        task.resume()
    }
    
    func getProfileCall() {
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            return
        }
        
        guard let id = Credentials.shared.defaults.string(forKey: "Id") else {
            return
        }
        
        guard let url = URL(string: EndPoints.getProfile(id: id).description) else {
            return
        }
        
        print("______________________________")
        print(EndPoints.getProfile(id: id).description)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request ,completionHandler: { [weak self] data, response, error in
            
            if error != nil {
                print("inside \(EndPoints.getProfile(id: id).description) erorr")
                print(error?.localizedDescription as Any)
                print("______________________________")
            }else{
                do{
                    let d1 = try JSONDecoder().decode(ProfileModel.self, from: data!)
                    print(d1)
                    DispatchQueue.main.async {
                        self?.profileData = d1
                        print(self?.profileData as Any)
                        print("______________________________")
                        self?.saveToDevice()
                    }
                } catch(let error) {
                    print("inside \(EndPoints.getProfile(id: id).description) catch")
                    print("inside catch \(error)")
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 401 {
                            print("token expired")
                            print("______________________________")
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


extension UINavigationController {
    func popToSpecificViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
          popToViewController(vc, animated: animated)
        }
      }
    
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
          let vc = viewControllers[viewControllers.count - viewsToPop - 1]
          popToViewController(vc, animated: animated)
        }
      }
}
