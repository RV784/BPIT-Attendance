//
//  AboutViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 05/11/22.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var mentorImg: UIImageView!
    @IBOutlet weak var mentorDesignation: UILabel!
    @IBOutlet weak var mentorName: UILabel!
    @IBOutlet weak var mentorView: UIView!
    @IBOutlet weak var titleView: UIView!
    
    
    @IBOutlet weak var devOneView: UIView!
    @IBOutlet weak var devOneImg: UIImageView!
    
    
    @IBOutlet weak var devTwoView: UIView!
    @IBOutlet weak var devTwoImg: UIImageView!
    
    
    @IBOutlet weak var devThreeView: UIView!
    @IBOutlet weak var devThreeImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "About this app"
        navigationController?.navigationBar.prefersLargeTitles = true
        titleView.backgroundColor = UIColor.barColor
        
        mentorView.layer.cornerRadius = 10
        devOneView.layer.cornerRadius = 10
        devTwoView.layer.cornerRadius = 10
        devThreeView.layer.cornerRadius = 10
        
        mentorImg.layer.cornerRadius = 30
        devOneImg.layer.cornerRadius = 30
        devTwoImg.layer.cornerRadius = 30
        devThreeImg.layer.cornerRadius = 30
        
        mentorView.backgroundColor = .subjectColor
        devOneView.backgroundColor = .subjectColor
        devTwoView.backgroundColor = .subjectColor
        devThreeView.backgroundColor = .subjectColor
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