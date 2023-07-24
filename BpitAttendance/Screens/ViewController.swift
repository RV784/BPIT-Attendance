//
//  ViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 17/09/22.
//

import UIKit

class ViewController: BaseViewController {
    
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var deciderIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deciderView: UIView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginLoader: UIActivityIndicatorView!
    @IBOutlet weak var signInBtn: UIButton!
    
    var loginArr: [String: Any] = [:]
    var toBePopped: Bool = false
    var profileData: ProfileModel?
    var loginData: LoginModel?
    var tokExpMidCycle = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        deciderIndicator.startAnimating()
        emailTxtField.layer.cornerRadius = 12
        passwordTxtField.layer.cornerRadius = 12
        signInBtn.layer.cornerRadius = 12
        passwordTxtField.isSecureTextEntry = true
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
    }
    
    override func startLoading() {
        signInBtn.setTitle("", for: .normal)
        loginLoader.startAnimating()
    }
    
    override func stopLoading() {
        signInBtn.setTitle("Sign In", for: .normal)
        loginLoader.stopAnimating()
    }
    
    //MARK: BUSINESS LOGIC
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resetPasswordVC = storyboard.instantiateViewController(identifier: "EnterEmailViewController") as? EnterEmailViewController {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(resetPasswordVC)
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
            registerUser(email: emailTxtField.text ?? "", password: passwordTxtField.text ?? "")
        } else {
            showNoInternetAlter()
        }
    }
    
    @IBAction func textDidChanged(_ sender: Any) {
        if emailTxtField.text?.isEmpty != true && passwordTxtField.text?.isEmpty != true {
            signInBtn.layer.backgroundColor = UIColor.systemBlue.cgColor
        } else {
            signInBtn.layer.backgroundColor = UIColor.systemGray2.cgColor
        }
    }
    
    func navigate() {
        if tokExpMidCycle {
            navigationController?.popViewController(animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBar")
            mainTabBarController.overrideUserInterfaceStyle = .dark
            // This is to get the SceneDelegate object from your view controller
            // then call the change root view controller function to change to main tab bar
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        }
    }
    
    func showNoInternetAlter() {
        showGenericUIAlert(
            title: "No Internet",
            message: "Your phone is not connected to Internet, Please connect and try again",
            completion: {}
        )
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resetPasswordVC = storyboard.instantiateViewController(identifier: "ResetPasswordViewController") as? ResetPasswordViewController {
            resetPasswordVC.firstLogin = true
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(resetPasswordVC)
        }
    }
    
    func processData() {
        if let _ = loginData?.token {
            emailTxtField.text = ""
            passwordTxtField.text = ""
            Credentials.shared.defaults.set(loginData?.token, forKey: "Token")
            Credentials.shared.defaults.set(loginData?.id, forKey: "Id")
            if loginData?.isFirstLogin == true {
                navigateToResetPassword()
            } else {
                navigate()
            }
        } else {
            showGenericUIAlert(title: "Incorrect Email or Password", message: "", completion: {})
        }
    }
}

// MARK: API CALL
extension ViewController {
    func registerUser(email: String, password: String) {
        startLoading()
        let parameters: [String: Any]  = ["email" : email, "password" : password] as Dictionary<String, Any>
        request(
            isToken: false,
            params: parameters,
            endpoint: .getToken,
            requestType: .post,
            postData: nil,
            vibrateUponSuccess: true) { [weak self] data in
                self?.stopLoading()
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(LoginModel.self, from: data)
                        self?.loginData = response
                        self?.processData()
                        return
                    } catch let error {
                        print(error)
                    }
                }
                self?.showGenericErrorAlert()
            } _: { [weak self] error in
                self?.stopLoading()
                self?.showGenericErrorAlert()
                print("Error in Request/Response \(EndPoints.getToken.description) \(String(describing: error))")
            }
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
