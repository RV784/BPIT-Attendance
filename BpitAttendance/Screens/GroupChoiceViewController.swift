//
//  GroupChoiceViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 24/09/22.
//

import UIKit

class GroupChoiceViewController: UIViewController {
    var batch: String = ""
    var subject: String = ""
    var subjectCode: String = ""
    var section: String = ""
    var branch: String = ""
    var isLab: Bool = false
    
    @IBOutlet weak var gTwoButton: UIButton!
    @IBOutlet weak var gOneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gOneButton.layer.cornerRadius = 13
        gTwoButton.layer.cornerRadius = 13
    }
    
    
    @IBAction func gOnePressed(_ sender: Any) {
        if let studentListVc = storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as? StudentListViewController {
            studentListVc.batch = self.batch
            studentListVc.branch = self.branch
            studentListVc.subject = self.subject
            studentListVc.section = self.section
            studentListVc.subjectCode = self.subjectCode
            studentListVc.isLab = true
            studentListVc.groupNum = 1
            self.navigationController?.pushViewController(studentListVc, animated: true)
        }
    }
    
    @IBAction func gTwoPressed(_ sender: Any) {
        if let studentListVc = storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as? StudentListViewController {
            studentListVc.batch = self.batch
            studentListVc.branch = self.branch
            studentListVc.subject = self.subject
            studentListVc.section = self.section
            studentListVc.subjectCode = self.subjectCode
            studentListVc.isLab = true
            studentListVc.groupNum = 2
            self.navigationController?.pushViewController(studentListVc, animated: true)
        }
    }
}
