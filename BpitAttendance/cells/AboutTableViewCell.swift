//
//  AboutTableViewCell.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 03/06/23.
//

import UIKit

class AboutTableViewCell: UITableViewCell {

    struct ViewModel {
        var name: String
        var profileImage: UIImage?
        var designationText: String
        var linkdnURL: String?
    }
    
    @IBOutlet var baseView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var designationLabel: UILabel!
    
    private var linkdnURL: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        baseView.layer.cornerRadius = 15
        baseView.backgroundColor = .subjectColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ data: AboutTableViewCell.ViewModel) {
        nameLabel.text = data.name
        profileImage.image = data.profileImage
        designationLabel.text = data.designationText
        profileImage.layer.cornerRadius = 10
        linkdnURL = data.linkdnURL
        
        layoutSubviews()
    }
    
}
