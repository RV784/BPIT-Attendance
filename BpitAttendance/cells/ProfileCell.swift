//
//  ProfileCell.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 29/09/22.
//

import UIKit

protocol ProfileCellProtocol: NSObjectProtocol {
    func edited(cell: ProfileCell)
}

class ProfileCell: UITableViewCell {
    
    var isEditingAllowed = false
    var type: cellType?
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    weak var delegate: ProfileCellProtocol?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtField.delegate = self
        baseView.layer.cornerRadius = 20
        imgView.layer.cornerRadius = 11
        baseView.layer.borderColor = UIColor.systemGray5.cgColor
        baseView.layer.borderWidth = 1
        saveBtn.titleLabel?.text = "Edit"
        saveBtn.layer.cornerRadius = 15
        
        txtField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    @IBAction func txtFieldAction(_ sender: UITextField) { }
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.edited(cell: self)
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
    
}

enum cellType: String {
    case name = "Name"
    case phone = "Phone"
}
