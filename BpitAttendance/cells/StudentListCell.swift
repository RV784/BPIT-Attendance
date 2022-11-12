//
//  StudentListCell.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 21/09/22.
//

import UIKit

class StudentListCell: UICollectionViewCell {
    
    @IBOutlet weak var rollNoLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    
    deinit {
        print(#file)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
