//
//  AboutViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 05/11/22.
//

import UIKit

class AboutViewController: BaseViewController {
    
    @IBOutlet weak var mentorImg: UIImageView!
    @IBOutlet weak var mentorDesignation: UILabel!
    @IBOutlet weak var mentorName: UILabel!
    @IBOutlet weak var mentorView: UIView!
    
    
    @IBOutlet weak var devOneView: UIView!
    @IBOutlet weak var devOneImg: UIImageView!
    
    
    @IBOutlet weak var devTwoView: UIView!
    @IBOutlet weak var devTwoImg: UIImageView!
    
    
    @IBOutlet weak var devThreeView: UIView!
    @IBOutlet weak var devThreeImg: UIImageView!
    
    @IBOutlet weak var devFourView: UIView!
    @IBOutlet weak var devFourImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = "About this app"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        mentorView.layer.cornerRadius = 10
        devOneView.layer.cornerRadius = 10
        devTwoView.layer.cornerRadius = 10
        devThreeView.layer.cornerRadius = 10
        devFourView.layer.cornerRadius = 10
        
        mentorImg.layer.cornerRadius = 30
        devOneImg.layer.cornerRadius = 30
        devTwoImg.layer.cornerRadius = 30
        devThreeImg.layer.cornerRadius = 30
        devFourImg.layer.cornerRadius = 30
        
        mentorView.backgroundColor = .subjectColor
        devOneView.backgroundColor = .subjectColor
        devTwoView.backgroundColor = .subjectColor
        devThreeView.backgroundColor = .subjectColor
        devFourView.backgroundColor = .subjectColor
    }
}
