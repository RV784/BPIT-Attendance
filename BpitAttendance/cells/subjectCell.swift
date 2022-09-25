//
//  subjectCell.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 20/09/22.
//

import UIKit

class subjectCell: UICollectionViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var labLabel: UILabel!
    @IBOutlet weak var branch_sectionLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.layer.cornerRadius = 8
    }


}
