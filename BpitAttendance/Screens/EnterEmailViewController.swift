//
//  EnterEmailViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 10/10/22.
//

import UIKit

class EnterEmailViewController: UIViewController {

    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var enterEmailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Enter email"
        // Do any additional setup after loading the view.
        otpView.isHidden = false
        otpView.addSubview(OTPStackView())
    }
}
