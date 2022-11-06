//
//  ProfileViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 29/09/22.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var titleDesignation: UILabel!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var mainNameView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var profileTableView: UITableView!
    
    var profiledata = Credentials.shared.defaults.object(forKey: "ProfileData")
    var variableProfileData: ProfileModel?
    var editedPhone: String?
    var editedName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(rightHandAction))
        navigationItem.title = "My Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        baseView.addGestureRecognizer(tap)
        getProfileCall()
        mainNameView.backgroundColor = UIColor.barColor
        //        navigationController?.navigationBar.prefersLargeTitles = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        titleImage.layer.cornerRadius = 50
        
        if let urlStr = variableProfileData?.image_url {
            loadProfileImage(image_url: urlStr)
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            profileTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        profileTableView.contentInset = .zero
    }
    
    @objc func rightHandAction() {
        let alert = UIAlertController(title: "Do you want to save?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Discard", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: {action in self.savePressed()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func saveToDevice() {
        Credentials.shared.defaults.set("\(variableProfileData?.id ?? 0)", forKey: "Id")
        Credentials.shared.defaults.set("\(variableProfileData?.name ?? "")", forKey: "Name")
        Credentials.shared.defaults.set("\(variableProfileData?.email ?? "")", forKey: "Email")
        Credentials.shared.defaults.set("\(variableProfileData?.designation ?? "")", forKey: "Designation")
        Credentials.shared.defaults.set("\(variableProfileData?.phoneNumber ?? "")", forKey: "PhoneNumber")
        Credentials.shared.defaults.set("\(variableProfileData?.dateJoined ?? "")", forKey: "DateJoined")
        Credentials.shared.defaults.set(variableProfileData?.isStaff, forKey: "Staff")
        Credentials.shared.defaults.set(variableProfileData?.isActive, forKey: "Active")
        Credentials.shared.defaults.set(variableProfileData?.isSuperUser, forKey: "SuperUser")
        if let urlStr = variableProfileData?.image_url {
            loadProfileImage(image_url: urlStr)
        }
        profileTableView.reloadData()
    }
    
    func navigateToLoginAgain() {
        let alertController = UIAlertController(title: "Oops!", message: "Seems link your token expired, we'll redirect you to LogIn screen to refresh your token", preferredStyle: .alert)
        let gotoButton = UIAlertAction(title: "Go to Login Screen", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("gotoButton Pressed")
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                loginVC.tokExpMidCycle = true
                self.tabBarController?.tabBar.isHidden = true
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
        alertController.addAction(gotoButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func savePressed() {
        sendFacultyData()
    }
    
    //MARK: API CALLS
    func getProfileCall() {
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        
        guard let id = Credentials.shared.defaults.string(forKey: "Id") else {
            return
        }
        
        guard let url = URL(string: EndPoints.getProfile(id: id).description) else {
            return
        }
        
        loader.startAnimating()
        print("______________________________")
        print(EndPoints.getProfile(id: id).description)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request ,completionHandler: { [weak self] data, response, error in
            
            DispatchQueue.main.async {
                self?.loader.stopAnimating()
            }
            
            if error != nil {
                print("inside \(EndPoints.getProfile(id: id).description) erorr")
                print(error?.localizedDescription as Any)
                print("______________________________")
            }else{
                do{
                    let d1 = try JSONDecoder().decode(ProfileModel.self, from: data!)
                    DispatchQueue.main.async {
                        self?.variableProfileData = d1
                        print(self?.variableProfileData as Any)
                        print("______________________________")
                        self?.saveToDevice()
                    }
                } catch(let error) {
                    print("inside \(EndPoints.getProfile(id: id).description) catch")
                    print("inside catch \(error)")
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 401 {
                            DispatchQueue.main.async {
                                self?.navigateToLoginAgain()
                            }
                            print("token expired")
                            print("______________________________")
                        }
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func sendFacultyData() {
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            return
        }
        
        guard let id = Credentials.shared.defaults.string(forKey: "Id") else {
            return
        }
        
        loader.startAnimating()
        print("______________________________")
        print(EndPoints.getProfile(id: id).description)
        
//        guard let url = URL(string: EndPoints.editFacultyProfile.description) else {
//            return
//        }
        guard let url = URL(string: EndPoints.getProfile(id: id).description) else {
            return
        }
        
        let parameters: [String: Any] = [
            "id": Credentials.shared.defaults.integer(forKey: "Id"),
            "email": Credentials.shared.defaults.string(forKey: "Email") ?? "",
            "name": editedName ?? "",
            "phone_number": editedPhone ?? "",
            "is_staff": Credentials.shared.defaults.bool(forKey: "Staff"),
            "is_superuser": Credentials.shared.defaults.bool(forKey: "SuperUser"),
            "is_active": Credentials.shared.defaults.bool(forKey: "Active"),
            "designation": Credentials.shared.defaults.string(forKey: "Designation") ?? "",
            "date_joined": Credentials.shared.defaults.string(forKey: "DateJoined") == "" ? nil : Credentials.shared.defaults.string(forKey: "DateJoined"),
            "image_url": variableProfileData?.image_url ?? ""
        ] as Dictionary<String, Any>
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request ,completionHandler: { [weak self] data, response, error in
            
            DispatchQueue.main.async {
                self?.loader.stopAnimating()
            }
            
            if error != nil {
                print("inside erorr")
                print(error?.localizedDescription as Any)
                print("______________________________")
            }else{
                do{
                    let d1 = try JSONDecoder().decode(EditProfileResponseModel.self, from: data!)
                    print(d1)
                    DispatchQueue.main.async {
                        self?.variableProfileData = d1.data
//                        print(self?.variableProfileData as Any)
                        print("______________________________")
                        self?.saveToDevice()
                    }
                } catch(let error) {
                    print("inside \(EndPoints.getProfile(id: id).description) catch")
                    print("inside catch \(error.localizedDescription)")
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 401 {
                            print("token expired")
                            print("______________________________")
                        }
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func loadProfileImage(image_url: String) {
        print("profile image loading")
        if let url = URL(string: image_url) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data,
                      error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    print("profile image loaded")
                    self?.titleImage.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.headingLabel.text = "Name"
            cell.imgView.image = UIImage(named: "profileImg")
            cell.saveBtn.isHidden = false
            cell.txtField.isUserInteractionEnabled = true
            cell.type = .name
            if let name = Credentials.shared.defaults.string(forKey: "Name") {
                cell.txtField.text = name
                titleName.text = name
            }
            return cell
        case 1:
            cell.headingLabel.text = "Email"
            cell.txtField.text = Credentials.shared.defaults.string(forKey: "Email")
            cell.imgView.image = UIImage(named: "emailIcon")
            cell.txtField.isUserInteractionEnabled = false
            cell.saveBtn.isHidden = true
            return cell
        case 2:
            cell.headingLabel.text = "Designation"
            cell.txtField.text = Credentials.shared.defaults.string(forKey: "Designation")
            cell.imgView.image = UIImage(named: "briefCase")
            cell.txtField.isUserInteractionEnabled = false
            cell.saveBtn.isHidden = true
            titleDesignation.text = Credentials.shared.defaults.string(forKey: "Designation")
            return cell
        case 3:
            cell.headingLabel.text = "Phone Number"
            cell.saveBtn.isHidden = false
            cell.txtField.text = Credentials.shared.defaults.string(forKey: "PhoneNumber")
            cell.type = .phone
            cell.txtField.isUserInteractionEnabled = true
            cell.imgView.image = UIImage(named: "phoneIcon")
            return cell
        case 4:
            
            cell.imgView.image = UIImage(named: "dateJoined")
            cell.headingLabel.text = "Date Joined"
            cell.txtField.isUserInteractionEnabled = false
            cell.txtField.text = Credentials.shared.defaults.string(forKey: "DateJoined")
            cell.saveBtn.isHidden = true
            return cell
        case 5:
            cell.headingLabel.text = "Staff Member"
            cell.txtField.text = Credentials.shared.defaults.bool(forKey: "Staff") ? "YES" : "NO"
            cell.imgView.image = UIImage(named: "staffMember")
            cell.txtField.isUserInteractionEnabled = false
            cell.saveBtn.isHidden = true
            return cell
        case 6:
            cell.headingLabel.text = "Status"
            cell.txtField.text = Credentials.shared.defaults.bool(forKey: "Active") ? "ACTIVE" : "NOT ACTIVE"
            if Credentials.shared.defaults.bool(forKey: "Active") {
                cell.imgView.image = UIImage(named: "activeStatus")
            } else {
                cell.imgView.image = UIImage(named: "notActive")
            }
            cell.txtField.isUserInteractionEnabled = false
            cell.saveBtn.isHidden = true
            return cell
        case 7:
            cell.headingLabel.text = "Super User"
            cell.txtField.text = Credentials.shared.defaults.bool(forKey: "SuperUser") ? "YES" : "NO"
            cell.imgView.image = UIImage(named: "superUser")
            cell.imgView.layer.borderWidth = 0.3
            cell.imgView.layer.borderColor = UIColor.black.cgColor
            cell.txtField.isUserInteractionEnabled = false
            cell.saveBtn.isHidden = true
            return cell
        default:
            return UITableViewCell()
        }
    }
}


extension ProfileViewController: ProfileCellProtocol {
    func edited(cell: ProfileCell) {
        if cell.type == .phone {
            if let newNum = cell.txtField.text {
                editedPhone = newNum
            }
        } else if cell.type == .name {
            if let newName = cell.txtField.text {
                editedName = newName
            }
        }
    }
}
