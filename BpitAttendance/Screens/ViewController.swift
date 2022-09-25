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
    var token: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        signInBtn.layer.cornerRadius = 25
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func navigate(){
        if let subjectVC = storyboard?.instantiateViewController(withIdentifier: "SubjectViewController") as? SubjectViewController{
            subjectVC.token = self.token
            self.navigationController?.pushViewController(subjectVC, animated: true)
        }
    }
    
    @IBAction func signInBtnClicked(_ sender: Any) {
        if(emailTxtField.text == ""){
            let alert = UIAlertController(title: "Enter email", message: "", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return
        }else if(passwordTxtField.text == ""){
            let alert = UIAlertController(title: "Enter password", message: "", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return
        }
        print(emailTxtField.text)
        print(passwordTxtField.text)
        
        register(email: emailTxtField.text!, password: passwordTxtField.text!)
        
        
    }
    
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
//            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                if(json["token"] == nil){
                    print("No good")
                }else{
                    self.loginArr = json
                                    print(self.loginArr["token"])
                    DispatchQueue.main.async {
                        self.signInBtn.setTitle("Sign In", for: .normal)
                        self.loginLoader.stopAnimating()
                        self.token = self.loginArr["token"] as! String
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

extension ViewController: UITextFieldDelegate {
    
}
