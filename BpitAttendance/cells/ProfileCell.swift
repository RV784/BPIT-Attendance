//
//  ProfileCell.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 29/09/22.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.layer.cornerRadius = 25
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 0.5
        imgView.layer.cornerRadius = 20
        saveBtn.layer.cornerRadius = 15
        saveBtn.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
