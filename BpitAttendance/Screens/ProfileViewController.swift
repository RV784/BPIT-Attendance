//
//  ProfileViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 29/09/22.
//

import UIKit

class ProfileViewController: UIViewController {

    var profiledata = Credentials.shared.defaults.object(forKey: "ProfileData")
    @IBOutlet weak var profileTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        print("in profile page")
        print(profiledata)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(rightHandAction))
    }
    @objc
    func rightHandAction() {
        print("right bar button action")
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell {
                cell.headingLabel.text = "Name"
                if let name = Credentials.shared.defaults.string(forKey: "Name") {
                    cell.txtField.text = name
                }
                return cell
            }
        case 1:
            if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell {
                cell.headingLabel.text = "Email"
                cell.txtField.text = Credentials.shared.defaults.string(forKey: "Email")
                cell.imgView.image = UIImage(named: "emailIcon")
                return cell
            }
        case 2:
            if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell {
                cell.headingLabel.text = "Designation"
                cell.txtField.text = Credentials.shared.defaults.string(forKey: "Designation")
                cell.imgView.image = UIImage(named: "briefCase")
                return cell
            }
        case 3:
            if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell {
                cell.headingLabel.text = "Phone Number"
                cell.txtField.text = Credentials.shared.defaults.string(forKey: "PhoneNumber")
                cell.imgView.image = UIImage(named: "phoneIcon")
                return cell
            }
        case 4:
            if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell {
                cell.headingLabel.text = "Date Joined"
                cell.txtField.text = Credentials.shared.defaults.string(forKey: "DateJoined")
                return cell
            }
        case 5:
            if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell {
                cell.headingLabel.text = "Staff Member"
                cell.txtField.text = Credentials.shared.defaults.bool(forKey: "Staff") ? "YES" : "NO"
                cell.imgView.image = UIImage(named: "staffMember")
                return cell
            }
        case 6:
            if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell {
                cell.headingLabel.text = "Status"
                cell.txtField.text = Credentials.shared.defaults.bool(forKey: "Active") ? "ACTIVE" : "NOT ACTIVE"
                if Credentials.shared.defaults.bool(forKey: "Active") {
                    cell.imgView.image = UIImage(named: "activeStatus")
                } else {
                    cell.imgView.image = UIImage(named: "notActive")
                }
                return cell
            }
        case 7:
            if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell {
                cell.headingLabel.text = "Super User"
                cell.txtField.text = Credentials.shared.defaults.bool(forKey: "SuperUser") ? "YES" : "NO"
                cell.imgView.image = UIImage(named: "superUser")
                cell.imgView.layer.borderWidth = 0.3
                cell.imgView.layer.borderColor = UIColor.black.cgColor
                return cell
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
}
