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
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var labLabel: UILabel!
    @IBOutlet weak var branch_sectionLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var labView: UIView!
    
    var idxPath = 0
    weak var delegate: SubjectCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        labView.layer.cornerRadius = 8
        baseView.layer.cornerRadius = 15
        baseView.backgroundColor = UIColor.subjectColor
    }
    
    func config(idx: Int) {
        self.idxPath = idx
    }
}
