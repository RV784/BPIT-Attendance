//
//  subjectCell.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 20/09/22.
//

import UIKit

protocol SubjectCellProtocol: AnyObject {
    func editLastAttendance(idx: Int)
    func seeSubjectStats(idx: Int)
}

class subjectCell: UICollectionViewCell {
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var labLabel: UILabel!
    @IBOutlet weak var branch_sectionLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    var idxPath = 0
    weak var delegate: SubjectCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.layer.cornerRadius = 8
        
        let usersItem = UIAction(title: "Edit Last Attendance", image: UIImage(systemName: "person.fill")) { [weak self] (action) in
            //edit last attendance
            self?.delegate?.editLastAttendance(idx: self?.idxPath ?? 0)
        }
        
        let addUserItem = UIAction(title: "See Statistics", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            //see stats
            self?.delegate?.seeSubjectStats(idx: self?.idxPath ?? 0)
        }
        
        let menu = UIMenu(title: "More Options", options: .displayInline, children: [usersItem , addUserItem])
        
        menuBtn.menu = menu
        menuBtn.showsMenuAsPrimaryAction = true
        
        baseView.backgroundColor = UIColor.subjectColor
        
        menuBtn.layer.cornerRadius = 5
        
        menuBtn.setTitle("", for: .normal)
        menuBtn.setTitle("", for: .selected)
    }
    
    func config(idx: Int) {
        self.idxPath = idx
    }
}
