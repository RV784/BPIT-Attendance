//
//  SettingsViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 06/11/22.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var resetPasswordBtn: UIButton!
    @IBOutlet weak var signOut: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        resetPasswordBtn.layer.cornerRadius = 10
        signOut.layer.cornerRadius = 10
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func navigateToLoginAgain() {
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
        if let loginNavController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }
    }
    
    func checkInternet() -> Bool {
        return InternetConnectionManager.isConnectedToNetwork()
    }
    
    func showNoInternetAlter() {
        let alert = UIAlertController(title: "No Internet", message: "Your phone is not connected to Internet, Please connect and try again", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    @IBAction func resetPasswordBtnClicked(_ sender: Any) {
        if let resetPasswordVC = storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController{
            resetPasswordVC.resetPassword = true
            self.navigationController?.pushViewController(resetPasswordVC, animated: true)
        }
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Do you want to Logout?", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            if self.checkInternet() {
                self.getPostUrl() { [weak self] in
                    self?.logoutApi()
                }_: { [weak self] in
                    self?.somethingGoneWrongError()
                }
            } else {
                self.showNoInternetAlter()
            }
        }
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func somethingGoneWrongError() {
        let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    //MARK: API CALLING
    
    func logoutApi() {
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        
        guard let url = URL(string: EndPoints.logOut.description) else {
            return
        }
        
        //start loader animating
        print("______________________________")
        print(EndPoints.logOut.description)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request ,completionHandler: { [weak self] data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            
            DispatchQueue.main.async {
                //loader stop animating
            }
            
            if error != nil {
                print("inside error")
                print(error?.localizedDescription as Any)
                print("______________________________")
                DispatchQueue.main.async {
                    self?.somethingGoneWrongError()
                }
            }else{
                DispatchQueue.main.async {
                    self?.navigateToLoginAgain()
                }
            }
        })
        
        task.resume()
    }
    
    
//MARK: INTERCEPTOR
    
    func getPostUrl(_ success: @escaping () -> Void,
                 _ failure: @escaping () -> Void) {
        
       //Start loader
        guard let url = URL(string: EndPoints.getInterceptorURL.description) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            
            DispatchQueue.main.async {
                //STOP loader
            }
            
            if error != nil {
                failure()
                print("inside error")
                print(error?.localizedDescription as Any)
                print("______________________________")
                DispatchQueue.main.async {
                    self?.somethingGoneWrongError()
                }
            } else {
                
                do {
                    let d1 = try JSONDecoder().decode(InterceptorModel.self, from: data!)
                    print(d1)
                    print("______________________________")
                    
                    if let url = d1.url {
                        Api.shared.post = "\(url)/api"
                        success()
                    } else {
                        //not getting url
                        failure()
                    }
                    
                } catch (let error) {
                    //server issue handling
                    print("inside catch error of \(EndPoints.getInterceptorURL.description)")
                    print(error)
                    failure()
                }
            }
            
        })
        
        task.resume()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
