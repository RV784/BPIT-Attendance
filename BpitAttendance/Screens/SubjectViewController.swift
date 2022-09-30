//
//  SubjectViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 18/09/22.
//

import UIKit

class SubjectViewController: UIViewController {
    var arr: [Any] = []
    var subjects: [SubjectListModel]?
    var profileDetails: ProfileModel?
    @IBOutlet weak var subjectCollectionView: UICollectionView!
    @IBOutlet weak var subjectLoader: UIActivityIndicatorView!
    @IBOutlet weak var bottomButtonsView: UIView!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var profileBtn: UIButton!
    
//MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButtonsView.layer.cornerRadius = 25
        logoutBtn.layer.cornerRadius = 25
        logoutBtn.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        profileBtn.layer.cornerRadius = 25
        profileBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        subjectCollectionView.delegate = self
        subjectCollectionView.dataSource = self
        subjectCollectionView.register(UINib(nibName: "subjectCell", bundle: nil), forCellWithReuseIdentifier: "subjectCell")
        subjectCollectionView.contentInset = UIEdgeInsets(top: CGFloat(10), left: CGFloat(10), bottom: 0, right: CGFloat(10))
        getSubject()
        
        navigationItem.hidesBackButton = true
        navigationItem.title = "Subjects"
    }
    
//MARK: BUSINESS LOGIC
    @IBAction func logoutBtnClicked(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Do you want to Logout?", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                UIAlertAction in
                NSLog("OK Pressed")
            Credentials.shared.defaults.set("", forKey: "Token")
            Credentials.shared.defaults.set("", forKey: "Name")
            Credentials.shared.defaults.set("", forKey: "Email")
            Credentials.shared.defaults.set("", forKey: "Designation")
            Credentials.shared.defaults.set("", forKey: "PhoneNumber")
            Credentials.shared.defaults.set("", forKey: "DateJoined")
            Credentials.shared.defaults.set(false, forKey: "Staff")
            Credentials.shared.defaults.set(false, forKey: "Active")
            Credentials.shared.defaults.set(false, forKey: "SuperUser")
            self.navigateToLoginAgain()
            }
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func profileBtnClicked(_ sender: Any) {
        navigateToProfilePage()
    }
    
    func navigateToProfilePage() {
        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController{
            
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func navigateToLoginAgain() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
  
//MARK: API CALLS
    func getSubject(){
        subjectLoader.startAnimating()
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        var request = URLRequest(url: URL(string: EndPoints.getSubjects.description)!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request ,completionHandler: { [weak self] data, response, error in
            
            if error != nil {
                print("inside error")
                print(error?.localizedDescription as Any)
            }else{
                do{
                    let d1 = try JSONDecoder().decode([SubjectListModel].self, from: data!)
                    self?.subjects = d1
                    DispatchQueue.main.async {
                        self?.subjectLoader.stopAnimating()
                        print(self?.subjects as Any)
                        self?.subjectCollectionView.reloadData()
                    }
                    
                } catch(let error) {
                    if let httpResponse = response as? HTTPURLResponse {
                        self?.subjectLoader.stopAnimating()
                        if httpResponse.statusCode == 401 {
                            print("token expired")
                        }
                    }
                }
            }
        })
        
        task.resume()
    }
}


//MARK: UICollectionViewDelegate UICollectionViewDataSource UICollectionViewDelegateFlowLayout
extension SubjectViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.subjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = subjectCollectionView.dequeueReusableCell(withReuseIdentifier: "subjectCell", for: indexPath) as? subjectCell {
            
            cell.subjectLabel.text = self.subjects?[indexPath.row].subject_name
            cell.sectionLabel.text = "Semester \(self.subjects?[indexPath.row].semester ?? 0)"
            if self.subjects?[indexPath.row].is_lab == true {
                cell.labLabel.text = "Lab"
            }else{
                cell.labLabel.text = ""
            }
            cell.branch_sectionLabel.text = "\(self.subjects?[indexPath.row].branch_code ?? "") - \(self.subjects?[indexPath.row].section ?? "")"
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = subjectCollectionView.frame.width
        return CGSize(width: width/2 - 15, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.subjects?[indexPath.row].is_lab ?? false {
            if let groupChoiceVc = storyboard?.instantiateViewController(withIdentifier: "GroupChoiceViewController") as? GroupChoiceViewController {
                groupChoiceVc.batch = self.subjects?[indexPath.row].batch ?? ""
                groupChoiceVc.branch = self.subjects?[indexPath.row].branch_code ?? ""
                groupChoiceVc.subject = self.subjects?[indexPath.row].subject_code ?? ""
                groupChoiceVc.section = self.subjects?[indexPath.row].section ?? ""
                groupChoiceVc.subjectCode = self.subjects?[indexPath.row].subject_name ?? ""
                groupChoiceVc.isLab = true
                self.navigationController?.pushViewController(groupChoiceVc, animated: true)
            }
        } else {
            if let studentListVc = storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as? StudentListViewController {
                studentListVc.batch = self.subjects?[indexPath.row].batch ?? ""
                studentListVc.branch = self.subjects?[indexPath.row].branch_code ?? ""
                studentListVc.subject = self.subjects?[indexPath.row].subject_code ?? ""
                studentListVc.section = self.subjects?[indexPath.row].section ?? ""
                studentListVc.subjectCode = self.subjects?[indexPath.row].subject_name ?? ""
                studentListVc.isLab = self.subjects?[indexPath.row].is_lab ?? false
                self.navigationController?.pushViewController(studentListVc, animated: true)
            }
        }
    }
}
