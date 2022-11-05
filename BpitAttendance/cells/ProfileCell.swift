//
//  ProfileCell.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 29/09/22.
//

import UIKit

protocol ProfileCellProtocol {
    func editOrSave(isSave: Bool)
}

class ProfileCell: UITableViewCell {
    
    var isEditingAllowed = false
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtField.delegate = self
        baseView.layer.cornerRadius = 20
        imgView.layer.cornerRadius = 15
        baseView.layer.borderColor = UIColor.systemGray5.cgColor
        baseView.layer.borderWidth = 1
        saveBtn.titleLabel?.text = "save"
    }
    
    @IBAction func editBtnClicked(_ sender: Any) {
        txtField.becomeFirstResponder()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


//TODO: send faculty data all at once
extension ProfileCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}

enum profileType: String {
    case name = "Name"
    case phone = "Phone"
}
