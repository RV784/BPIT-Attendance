//
//  EnterEmailViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 10/10/22.
//

import UIKit

class EnterEmailViewController: UIViewController {

    @IBOutlet weak var otpStackView: UIStackView!
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var emailOtpStackView: UIStackView!
    @IBOutlet weak var enterEmailField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    var otpViewIsVisible = false
    var reponse: ForgotPasswordEmailResponseModel?
    private var textFieldsCollection: [OTPTextField] = []
    private var remainingStrStack: [String] = []
    private var ifOtp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
        addOTPFields(numberOfFields: 6)
        navigationItem.title = "Enter email"
        enterEmailField.delegate = self
        submitBtn.layer.cornerRadius = 12
        let tap = UITapGestureRecognizer(target: self, action: #selector(EnterEmailViewController.dismissKeyboard))
        baseView.addGestureRecognizer(tap)
        submitBtn.setTitle("Submit", for: .normal)
        otpStackView.isHidden = true
        messageLabel.text = "Enter your registered email"
        messageLabel.textColor = .systemGray2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func toggleAll() {}
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        if !ifOtp {
            if enterEmailField.text == "" {
                enterEmailField.layer.borderColor = UIColor.red.cgColor
                enterEmailField.layer.borderWidth = 0.5
                enterEmailField.layer.cornerRadius = 1
                return
            }
            
            if checkConnection() {
                emailOtpStackView.removeArrangedSubview(OTPStackView())
                getOTP(email: enterEmailField.text ?? "")
            }
        } else {
            autoLogin()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func checkConnection() -> Bool {
        return InternetConnectionManager.isConnectedToNetwork()
    }
    
    private func setupStackView() {
        otpStackView.backgroundColor = .clear
        otpStackView.isUserInteractionEnabled = true
        otpStackView.translatesAutoresizingMaskIntoConstraints = false
        otpStackView.contentMode = .center
        otpStackView.spacing = 8
        otpStackView.distribution = .fillEqually
    }

    func setupTextField(_ textField: OTPTextField) {
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        otpStackView.addArrangedSubview(textField)
        textField.widthAnchor.constraint(equalToConstant: otpStackView.frame.height).isActive = true
        textField.centerYAnchor.constraint(equalTo: otpStackView.centerYAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: otpStackView.heightAnchor).isActive = true
        textField.backgroundColor = .systemGray2
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = false
        textField.layer.cornerRadius = 5
        textField.keyboardType = .numberPad
        textField.autocorrectionType = .yes
        textField.textContentType = .oneTimeCode
    }

    func addOTPFields(numberOfFields: Int) {
        for i in 0..<numberOfFields {
            let field = OTPTextField()
            setupTextField(field)
            textFieldsCollection.append(field)
            i != 0 ? (field.previousTextField = textFieldsCollection[i-1]) : (field.previousTextField = nil)
            i != 0 ? (textFieldsCollection[i-1].nextTextField = field) : ()
        }
    }
    
    private func autoFillTextField(with string: String) {
        for i in 0..<textFieldsCollection.count {
            if i < string.count {
                let index = string.index(string.startIndex, offsetBy: i)
                textFieldsCollection[i].text = String(string[index])
            } else {
                return
            }
        }
        autoLogin()
    }
    
    private func getOtp() -> String {
        var otp = ""
        for i in 0..<textFieldsCollection.count {
            if textFieldsCollection[i].text == "" {
                //show enter otp correctly
                showWrongOTPAlert(message: "Please enter OTP correctly")
                return ""
            } else {
                otp += textFieldsCollection[i].text ?? ""
            }
        }
        return otp
    }
    
    private func autoLogin() {
        if getOtp() != "" {
            verifyOTP(otp: getOtp(), email: enterEmailField.text ?? "")
        }
    }
    
    private func showWrongOTPAlert(message: String = "Entered OTP is incorrect") {
        for i in 0..<textFieldsCollection.count {
            textFieldsCollection[i].text = ""
        }
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] action in
            switch action.style {
            case .default:
                for fields in self?.textFieldsCollection ?? [] {
                    fields.text = ""
                }
                self?.textFieldsCollection[0].becomeFirstResponder()
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            @unknown default:
                print("default")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func navigateToResetPassword() {
        let otp = getOtp()
        if let resetPasswordVC = storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController,
           otp != "" {
            resetPasswordVC.forgotPassword = true
            resetPasswordVC.otp = otp
            resetPasswordVC.email = enterEmailField.text ?? ""
            self.navigationController?.pushViewController(resetPasswordVC, animated: true)
        }
    }
}

//MARK: API CALLS
extension EnterEmailViewController {
    
    func getOTP(email: String) {
        loader.startAnimating()
        submitBtn.setTitle("", for: .normal)
        let parameters: [String: Any] = ["email": email] as Dictionary<String, Any>
        
        guard let url = URL(string: EndPoints.forgotPassword.description) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                self.submitBtn.setTitle("Submit", for: .normal)
                //stop loader
                self.loader.stopAnimating()
            }
            if error != nil {
                print("Inside get OTP error")
                print(error?.localizedDescription as Any)
            } else {
                do{
                    let d1 = try JSONDecoder().decode(ForgotPasswordEmailResponseModel.self, from: data!)
                    DispatchQueue.main.async {
                        if let message = d1.message {
                            DispatchQueue.main.async {
                                //show OTP boxes
                                if message != "Invalid Email" {
                                    self.ifOtp = true
                                    self.submitBtn.setTitle("Verify OTP", for: .normal)
                                    self.otpStackView.isHidden = false
                                    self.textFieldsCollection[0].becomeFirstResponder()
                                    self.messageLabel.text = message
                                } else {
                                    self.messageLabel.text = message
                                }
                            }
                            print(message)
                        } else {
                            //show wrong email alert
                            print("Wrong email alert")
                        }
                    }
                } catch(let error) {
                    print(error.localizedDescription)
                }
            }
        })
        task.resume()
    }
    
    func verifyOTP(otp: String, email: String) {
        loader.startAnimating()
        submitBtn.setTitle("", for: .normal)
        
        let parameters: [String: Any] = ["email": email, "otp": otp] as Dictionary<String, Any>
        
        guard let url = URL(string: EndPoints.verifyOTP.description) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                self.submitBtn.setTitle("Verify OTP", for: .normal)
                //stop loader
                self.loader.stopAnimating()
            }
            if error != nil {
                print("Inside get OTP error")
                print(error?.localizedDescription as Any)
            } else {
                do{
                    let d1 = try JSONDecoder().decode(OtpResponseModel.self, from: data!)
                    DispatchQueue.main.async {
                        if let message = d1.msg {
                            print(message)
                            self.navigateToResetPassword()
                        } else {
                            //show wrong email alert
                            print("Wrong email alert")
                            DispatchQueue.main.async {
                                self.showWrongOTPAlert()
                            }
                            
                        }
                    }
                } catch(let error) {
                    print(error.localizedDescription)
                }
            }
        })
        task.resume()
    }
}

//MARK: UITextFieldDelegate
extension EnterEmailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? OTPTextField else { return true }
        
        //will handle quickBar text
        //QuickBar calls shouldChangeCharactersIn two times, first case in which range.length = 0 and then for adding string (range.length = 1)
        if string.count == 0 && range.length != 1 {
            return false
        }
        
        if string.count > 1 {
            textField.resignFirstResponder()
            autoFillTextField(with: string)
            return false
        } else {
            if range.length == 0 {
                if textField.text != "" {
                    textField.nextTextField?.text = string
                    textField.nextTextField?.becomeFirstResponder()
                    if textField.nextTextField?.nextTextField == nil {
                        textField.nextTextField?.resignFirstResponder()
                        autoLogin()
                    }
                    return false
                } else {
                    textField.text? = string
                }
                return false
            }
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let textField = textField as? OTPTextField else { return }

        //otp is filled in order
        if textField.previousTextField != nil && textField.text == "" {
            textField.resignFirstResponder()
            textField.previousTextField?.becomeFirstResponder()
        }
    }
}
