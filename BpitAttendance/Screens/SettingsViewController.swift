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
    
    @IBAction func resetPasswordBtnClicked(_ sender: Any) {
        if let resetPasswordVC = storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController{
            self.navigationController?.pushViewController(resetPasswordVC, animated: true)
        }
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Do you want to Logout?", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            self.logoutApi()
        }
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
            
            DispatchQueue.main.async {
                //loader stop animating
            }
            
            if error != nil {
                print("inside error")
                print(error?.localizedDescription as Any)
                print("______________________________")
            }else{
                DispatchQueue.main.async {
                    self?.navigateToLoginAgain()
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
