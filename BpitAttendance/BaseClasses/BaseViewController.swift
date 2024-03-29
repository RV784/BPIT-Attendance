//
//  BaseViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 31/05/23.
//

import UIKit

class BaseViewController: UIViewController {

    var activityView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
    }
    
    func startLoading() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.hidesWhenStopped = true
        activityView?.center = view.center
        view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func stopLoading() {
        activityView?.removeFromSuperview()
        activityView?.stopAnimating()
    }
    
    func tokenExpired() {
        routeToLoginScreen(with: nil)
    }
    
    func routeToLoginScreen(with email: String?) {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            loginVC.tokExpMidCycle = true
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    func showGenericUIAlert(title: String = "BPIT", message: String, completion: @escaping (() -> Void), buttonTitle: String = "Ok") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showGenericErrorAlert() {
        let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func giveHapticFeedback() {
        let tapticFeedback = UINotificationFeedbackGenerator()
        tapticFeedback.notificationOccurred(.success)
    }
    
    func request(isToken: Bool,
                 params: [String: Any]? = nil,
                 endpoint: EndPoints,
                 requestType: RequestType,
                 postData: Data?,
                 vibrateUponSuccess: Bool,
                 _ success: @escaping (Data?) -> Void,
                 _ failure: @escaping (Error?) -> Void) {
        
        APIManager.shared.request (
            isToken: isToken,
            params: params,
            endpoint: endpoint,
            requestType: requestType,
            postData: postData) { [weak self] data, response in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 401,
                   isToken {
                    print("token expired")
                    self?.tokenExpired()
                    
                    // TRY TO MAKE A PIPELINE HERE
                    failure(nil)
                } else {
                    if vibrateUponSuccess {
                        self?.giveHapticFeedback()
                    }
                    success(data)
                }
            } _: { error in
                failure(error)
            }
    }
}
