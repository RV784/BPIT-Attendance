//
//  ViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 17/09/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginLoader: UIActivityIndicatorView!
    @IBOutlet weak var signInBtn: UIButton!
    var loginArr: [String: Any] = [:]
    var toBePopped: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        signInBtn.layer.cornerRadius = 15
        passwordTxtField.isSecureTextEntry = true
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func navigate(){
            if let subjectVC = storyboard?.instantiateViewController(withIdentifier: "SubjectViewController") as? SubjectViewController{
                
                self.navigationController?.pushViewController(subjectVC, animated: true)
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
        register(email: emailTxtField.text!, password: passwordTxtField.text!)
    }
    
    func notCorrectCredentials() {
        let alert = UIAlertController(title: "Incorrect Email or Password", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
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
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                if(json["token"] == nil){
                    print("No good")
                    DispatchQueue.main.async {
                        self.loginLoader.stopAnimating()
                        self.signInBtn.setTitle("Sign In", for: .normal)
                        self.notCorrectCredentials()
                    }
                    
                }else if json["detail"] != nil {
                    print("invalid Token error")
                }
                else{
                    self.loginArr = json
                    //                    print(self.loginArr["token"])
                    DispatchQueue.main.async {
                        self.signInBtn.setTitle("Sign In", for: .normal)
                        self.loginLoader.stopAnimating()
                        Credentials.shared.token = self.loginArr["token"] as! String
                        self.navigate()
                    }
                }
            } catch {
                print("error")
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
    
}

