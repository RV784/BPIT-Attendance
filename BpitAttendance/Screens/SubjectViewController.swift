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
    @IBOutlet weak var noInternetView: NoInternetView!
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //How to curve specific corners of a button
        //        bottomButtonsView.layer.cornerRadius = 25
        //        logoutBtn.layer.cornerRadius = 25
        //        logoutBtn.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        //        profileBtn.layer.cornerRadius = 25
        //        profileBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        subjectCollectionView.delegate = self
        subjectCollectionView.dataSource = self
        subjectCollectionView.register(UINib(nibName: "subjectCell", bundle: nil), forCellWithReuseIdentifier: "subjectCell")
        subjectCollectionView.contentInset = UIEdgeInsets(top: CGFloat(10), left: CGFloat(10), bottom: 0, right: CGFloat(10))
        
        if checkInternet() {
            getPostUrl() { [weak self] in
                self?.getSubject()
            }_: { [weak self] in
                self?.somethingGoneWrongError()
            }
        } else {
            // show no internet Alert
            showNoInternetAlter()
        }
        
        
        navigationItem.hidesBackButton = true
        navigationItem.title = "Subjects"
        navigationController?.navigationBar.prefersLargeTitles = true
        //        noInternetView.gobackBtn.isHidden = true
        noInternetView.isHidden = true
        noInternetView.retryBtn.isHidden = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(rightHandAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: BUSINESS LOGIC
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
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        noInternetView.layer.add(animation, forKey: "shake")
        let tapticFeedback = UINotificationFeedbackGenerator()
        tapticFeedback.notificationOccurred(.success)
    }
    
    func disableEnableViews() {
        noInternetView.isHidden.toggle()
        subjectCollectionView.isHidden.toggle()
        //        bottomButtonsView.isHidden.toggle()
        shake()
    }
    
    func showNoInternetAlter() {
        let alert = UIAlertController(title: "No Internet", message: "Your phone is not connected to Internet, Please connect and try again", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func somethingGoneWrongError() {
        let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    @objc func rightHandAction() {
        if checkInternet() {
            getPostUrl() { [weak self] in
                self?.getSubject()
            }_: { [weak self] in
                self?.somethingGoneWrongError()
            }
        } else {
            showNoInternetAlter()
        }
    }
    
    func vibrate() {
        let tapticFeedback = UINotificationFeedbackGenerator()
        tapticFeedback.notificationOccurred(.success)
    }
    
    //MARK: API CALLS
    func getSubject() {
        
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        
        guard let url = URL(string: EndPoints.getSubjects.description) else {
            return
        }
        
        DispatchQueue.main.async {
            self.subjectLoader.startAnimating()
        }
        print("______________________________")
        print(EndPoints.getSubjects.description)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request ,completionHandler: { [weak self] data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            
            DispatchQueue.main.async {
                self?.subjectLoader.stopAnimating()
            }
            
            if error != nil {
                print("inside error")
                print(error?.localizedDescription as Any)
                print("______________________________")
                DispatchQueue.main.async {
                    self?.somethingGoneWrongError()
                }
            }else{
                do{
                    let d1 = try JSONDecoder().decode([SubjectListModel].self, from: data!)
                    self?.subjects = d1
                    DispatchQueue.main.async {
                        print(self?.subjects as Any)
                        print("______________________________")
                        self?.subjectCollectionView.reloadData()
                    }
                    
                } catch (let error) {
                    if let httpResponse = response as? HTTPURLResponse {
                        DispatchQueue.main.async {
                            if httpResponse.statusCode == 401 {
                                print("token expired")
                                self?.navigateToLoginAgain()
                                return
                            }
                        }
                    }
                    print(error)
                    print("______________________________")
                    DispatchQueue.main.async {
                        self?.somethingGoneWrongError()
                    }
                }
            }
        })
        task.resume()
    }
}

//MARK: INTERCEPTOR
extension SubjectViewController {
    
    func getPostUrl(_ success: @escaping () -> Void,
                    _ failure: @escaping () -> Void) {
        
        //Start loader
        subjectLoader.startAnimating()
        guard let url = URL(string: EndPoints.getInterceptorURL.description) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            
            DispatchQueue.main.async {
                //STOP loader
                self?.subjectLoader.stopAnimating()
            }
            
            if error != nil {
                failure()
                print("inside error")
                print(error?.localizedDescription as Any)
                print("______________________________")
                DispatchQueue.main.async {
                    self?.somethingGoneWrongError()
                }
            } else {
                
                do {
                    let d1 = try JSONDecoder().decode(InterceptorModel.self, from: data!)
                    print(d1)
                    print("______________________________")
                    
                    if let url = d1.url {
                        Api.shared.post = "\(url)/api"
                        success()
                    } else {
                        //not getting url
                        failure()
                    }
                    
                } catch (let error) {
                    //server issue handling
                    print("inside catch error of \(EndPoints.getInterceptorURL.description)")
                    print(error)
                    failure()
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
            if self.subjects?[indexPath.row].is_lab == true,
               let group = self.subjects?[indexPath.row].group {
                cell.labView.isHidden = false
                cell.labLabel.text = "Lab \(group)"
            }else{
                cell.labView.isHidden = true
                cell.labLabel.text = ""
            }
            cell.branch_sectionLabel.text = "\(returnBranch(branchCode: self.subjects?[indexPath.row].branch_code)) - \(self.subjects?[indexPath.row].section ?? "")"
            cell.idxPath = indexPath.row
            cell.layer.cornerRadius = 15
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = subjectCollectionView.frame.width
        return CGSize(width: width/2 - 15, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if checkInternet() {
            if let studentListVc = storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as? StudentListViewController {
                studentListVc.batch = self.subjects?[indexPath.row].batch ?? ""
                studentListVc.branch = self.subjects?[indexPath.row].branch_code ?? ""
                studentListVc.subject = self.subjects?[indexPath.row].subject_name ?? ""
                studentListVc.section = self.subjects?[indexPath.row].section ?? ""
                studentListVc.subjectCode = self.subjects?[indexPath.row].subject_code ?? ""
                
                if subjects?[indexPath.row].is_lab ?? false,
                   let group = subjects?[indexPath.row].group {
                    studentListVc.isLab = true
                    
                    if group == "G1" {
                        studentListVc.groupNum = 1
                    } else if group == "G2" {
                        studentListVc.groupNum = 2
                    }
                }
                studentListVc.navigationItem.largeTitleDisplayMode = .never
                tabBarController?.tabBar.isHidden = true
                self.navigationController?.pushViewController(studentListVc, animated: true)
            }
        } else {
            showNoInternetAlter()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let idx = indexPaths.first?[1] else {
            return UIContextMenuConfiguration()
        }
        
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            let takeAttendance = UIAction(title: "Take Attendance", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                if self.checkInternet() {
                    if let studentListVc = self.storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as? StudentListViewController {
                        studentListVc.batch = self.subjects?[idx].batch ?? ""
                        studentListVc.branch = self.subjects?[idx].branch_code ?? ""
                        studentListVc.subject = self.subjects?[idx].subject_name ?? ""
                        studentListVc.section = self.subjects?[idx].section ?? ""
                        studentListVc.subjectCode = self.subjects?[idx].subject_code ?? ""
                        
                        if self.subjects?[idx].is_lab ?? false,
                           let group = self.subjects?[idx].group {
                            studentListVc.isLab = true
                            
                            if group == "G1" {
                                studentListVc.groupNum = 1
                            } else if group == "G2" {
                                studentListVc.groupNum = 2
                            }
                        }
                        studentListVc.navigationItem.largeTitleDisplayMode = .never
                        self.tabBarController?.tabBar.isHidden = true
                        self.navigationController?.pushViewController(studentListVc, animated: true)
                    }
                } else {
                    self.showNoInternetAlter()
                }
            }
            let editLastAttendance = UIAction(title: "Edit last attendance", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                self.editLastAttendance(idx: idx)
            }
            let seeStats = UIAction(title: "See stats", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                self.seeSubjectStats(idx: idx)
            }
            return UIMenu(title: "More Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [takeAttendance ,editLastAttendance, seeStats])
        }
        return context
    }
    
    func editLastAttendance(idx: Int) {
        if let studentListVC = storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as? StudentListViewController {
            studentListVC.batch = self.subjects?[idx].batch ?? ""
            studentListVC.branch = self.subjects?[idx].branch_code ?? ""
            studentListVC.subject = self.subjects?[idx].subject_name ?? ""
            studentListVC.section = self.subjects?[idx].section ?? ""
            studentListVC.subjectCode = self.subjects?[idx].subject_code ?? ""
            studentListVC.isLab = self.subjects?[idx].is_lab ?? false
            studentListVC.isEditingPrevAttendance = true
            studentListVC.navigationItem.largeTitleDisplayMode = .never
            tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(studentListVC, animated: true)
        }
    }
    
    func checkNetwork(idx: Int) {
        if InternetConnectionManager.isConnectedToNetwork() {
            navigateToStudentList(idx: idx)
        } else {
            disableEnableViews()
        }
    }
    
    func checkInternet() -> Bool {
        return InternetConnectionManager.isConnectedToNetwork()
    }
    
    func navigateToStudentList(idx: Int) {
        if let studentListVC = storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as? StudentListViewController {
            studentListVC.batch = self.subjects?[idx].batch ?? ""
            studentListVC.branch = self.subjects?[idx].branch_code ?? ""
            studentListVC.subject = self.subjects?[idx].subject_name ?? ""
            studentListVC.section = self.subjects?[idx].section ?? ""
            studentListVC.subjectCode = self.subjects?[idx].subject_code ?? ""
            studentListVC.isLab = self.subjects?[idx].is_lab ?? false
            studentListVC.navigationItem.largeTitleDisplayMode = .never
            tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(studentListVC, animated: true)
        }
    }
    
    func seeSubjectStats(idx: Int) {
        //goto stats screen
        if let statsVC = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as? StatsViewController {
            statsVC.batch = self.subjects?[idx].batch ?? ""
            statsVC.branch = self.subjects?[idx].branch_code ?? ""
            statsVC.section = self.subjects?[idx].section ?? ""
            statsVC.subject = self.subjects?[idx].subject_code ?? ""
            
            if subjects?[idx].is_lab ?? false,
               let group = subjects?[idx].group {
                statsVC.isLab = true
                statsVC.group = group
            }
            
            statsVC.navigationItem.largeTitleDisplayMode = .never
            tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(statsVC, animated: true)
        }
    }
}

extension SubjectViewController: NoInternetProtocols {
    func onRetryPressed() {
        
    }
    
    func onGoBackPressed() {
        disableEnableViews()
    }
}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}

//extension SubjectViewController: SubjectCellProtocol {
//    func seeSubjectStats(idx: Int) {
//        //goto stats screen
//        if let statsVC = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as? StatsViewController {
//            statsVC.batch = self.subjects?[idx].batch ?? ""
//            statsVC.branch = self.subjects?[idx].branch_code ?? ""
//            statsVC.section = self.subjects?[idx].section ?? ""
//            statsVC.subject = self.subjects?[idx].subject_code ?? ""
//
//            if subjects?[idx].is_lab ?? false,
//               let group = subjects?[idx].group {
//                statsVC.isLab = true
//                statsVC.group = group
//            }
//
//            statsVC.navigationItem.largeTitleDisplayMode = .never
//            tabBarController?.tabBar.isHidden = true
//            self.navigationController?.pushViewController(statsVC, animated: true)
//        }
//    }
//
//    func editLastAttendance(idx: Int) {
//        if let studentListVC = storyboard?.instantiateViewController(withIdentifier: "StudentListViewController") as? StudentListViewController {
//            studentListVC.batch = self.subjects?[idx].batch ?? ""
//            studentListVC.branch = self.subjects?[idx].branch_code ?? ""
//            studentListVC.subject = self.subjects?[idx].subject_name ?? ""
//            studentListVC.section = self.subjects?[idx].section ?? ""
//            studentListVC.subjectCode = self.subjects?[idx].subject_code ?? ""
//            studentListVC.isLab = self.subjects?[idx].is_lab ?? false
//            studentListVC.isEditingPrevAttendance = true
//            studentListVC.navigationItem.largeTitleDisplayMode = .never
//            tabBarController?.tabBar.isHidden = true
//            self.navigationController?.pushViewController(studentListVC, animated: true)
//        }
//    }
//}

func returnBranch(branchCode: String?) -> String {
    if let code = branchCode {
        if code == "027" {
            return "CSE"
        }
        
        if code == "031" {
            return "IT"
        }
        
        if code == "028" {
            return "ECE"
        }
        
        if code == "039" {
            return "MBA"
        }
        
        if code == "017" {
            return "BBA"
        }
    }
    return "Invalid Branch"
}
