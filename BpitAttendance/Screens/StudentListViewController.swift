//
//  StudentListViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 21/09/22.
//

import UIKit

class StudentListViewController: BaseViewController {
    
    var color: UIColor = UIColor.yellow
    var isAbsent: Bool = false
    var batch: String = ""
    var subject: String = ""
    var subjectCode: String = ""
    var section: String = ""
    var branch: String = ""
    var isLab: Bool = false
    var groupNum: Int = 1
    var students: [StudentListModel]?
    var studentRecord: RecordData?
    var count: Int = 0
    var checkAll = true
    var isEditingPrevAttendance = false
    
    var lastAttendanceStudents: [LastAttendanceStudentModel]?
    var lastRecordData: LastAttendanceModel?
    
    var submitResponse: SubmitAttendanceResponseModel?
    
    @IBOutlet weak var dynamicStudentCounter: UILabel!
    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var bottomBtnViews: UIView!
    @IBOutlet weak var attendanceSubmitLoader: UIActivityIndicatorView!
    @IBOutlet weak var studentLoader: UIActivityIndicatorView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var studentCollectionView: UICollectionView!
    
    deinit {
        print(#file)
    }
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        studentCollectionView.dataSource = self
        studentCollectionView.delegate = self
        noInternetView.delegate = self
        if isEditingPrevAttendance {
            if checkInternet() {
//                getLastAttendanceStudents(batch: batch , subject: subject , section: section , branch: branch , isLab: false, subjectCode: subjectCode )
                getLastAttendanceStudentsNew(batch: batch , subject: subject , section: section , branch: branch , isLab: false, subjectCode: subjectCode )
            } else {
                showNoInternetAlter()
            }
        } else {
            if checkInternet() {
                getStudents(batch: batch , subject: subject , section: section , branch: branch , isLab: isLab , groupNum: groupNum , subjectCode: subjectCode )
            } else {
                showNoInternetAlter()
            }
        }
        studentCollectionView.register(UINib(nibName: "StudentListCell", bundle: nil), forCellWithReuseIdentifier: "StudentListCell")
        studentCollectionView.contentInset = UIEdgeInsets(top: CGFloat(10), left: CGFloat(10), bottom: 0, right: CGFloat(10))
        submitBtn.layer.cornerRadius = 25
        navigationItem.backButtonTitle = ""
        navigationItem.title = "Students"
        studentRecord = RecordData(record: [])
        lastRecordData = LastAttendanceModel(record: [])
        navigationItem.backButtonTitle = ""
        bottomBtnViews.layer.cornerRadius = 25
        submitBtn.layer.cornerRadius = 25
        let toggleAll = UIBarButtonItem(title: "Check All", style: .plain, target: self, action: #selector(toggleAll))
        let attributes: [NSAttributedString.Key : Any] = [ .font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.link]
        toggleAll.setTitleTextAttributes(attributes, for: .normal)
        dynamicStudentCounter.text = "\(count)"
        self.navigationItem.rightBarButtonItem = toggleAll
        noInternetView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func startLoading() {
        submitBtn.setTitle("", for: .normal)
        attendanceSubmitLoader.startAnimating()
    }
    
    override func stopLoading() {
        submitBtn.setTitle("Submit", for: .normal)
        attendanceSubmitLoader.stopAnimating()
    }
    
    @objc func toggleAll() {
        
        if isEditingPrevAttendance {
            if lastRecordData?.record.count != nil {
                for i in 0..<(lastRecordData?.record.count)! {
                    lastRecordData?.record[i].status = checkAll
                }
                if checkAll {
                    count = (lastRecordData?.record.count)!
                    dynamicStudentCounter.text = "\(count)"
                } else {
                    count = 0
                    dynamicStudentCounter.text = "\(count)"
                }
                checkAll.toggle()
                studentCollectionView.reloadData()
            }
        } else {
            if studentRecord?.record.count != nil {
                for i in 0..<(studentRecord?.record.count)! {
                    studentRecord?.record[i].status = checkAll
                }
                if checkAll {
                    count = (studentRecord?.record.count)!
                    dynamicStudentCounter.text = "\(count)"
                } else {
                    count = 0
                    dynamicStudentCounter.text = "0"
                }
                checkAll.toggle()
                studentCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: BUSINESS LOGIC
    func prepareRecordData() {
        let date = dateFormatter()
        for item in self.students ?? [] {
            studentRecord?.record.append(RecordData.studentData(status: false,
                                                                enrollment_number: item.enrollment_number ?? "",
                                                                subject: self.subjectCode,
                                                                batch: self.batch,
                                                                date: date))
        }
        self.studentCollectionView.reloadData()
    }
    
    func prepareLastRecordData() {
        //        let date = dateFormatter()
        for item in self.lastAttendanceStudents ?? [] {
            lastRecordData?.record.append(LastAttendanceModel.studentData(id: item.id ?? 0,
                                                                          enrollment_number: item.enrollment_number ?? "",
                                                                          batch: item.batch ?? "",
                                                                          name: item.name ?? "",
                                                                          status: item.status ?? true,
                                                                          class_roll_number: item.class_roll_number ?? -1,
                                                                          date: item.date ?? "",
                                                                          subject: item.subject ?? ""))
        }
        self.studentCollectionView.reloadData()
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
    
    func vibrate() {
        let tapticFeedback = UINotificationFeedbackGenerator()
        tapticFeedback.notificationOccurred(.success)
    }
    
    
    func yesPressed() {
        if checkInternet() {
            if isEditingPrevAttendance {
                sendLastStudents()
            } else {
                sendStudents()
            }
        } else {
            showNoInternetAlter()
        }
    }
    
    func showNoInternetAlter() {
        let alert = UIAlertController(title: "No Internet", message: "Your phone is not connected to Internet, Please connect and try again", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func disableEnableViews() {
        noInternetView.isHidden.toggle()
        studentCollectionView.isHidden.toggle()
        bottomBtnViews.isHidden.toggle()
        shake()
    }
    
    func dateFormatter() -> String {
        //        Date().description(with: .current)  //  Tuesday, February 5, 2019 at 10:35:01 PM Brasilia Summer Time"
        let dateString = Date().iso8601withFractionalSeconds   //  "2019-02-06T00:35:01.746Z"
        
        if let date = dateString.iso8601withFractionalSeconds {
            //            date.description(with: .current) // "Tuesday, February 5, 2019 at 10:35:01 PM Brasilia Summer Time"
            return date.iso8601withFractionalSeconds       //  "2019-02-06T00:35:01.746Z\n"
        }
        return ""
    }
    
    func updateCounter() {
        if lastAttendanceStudents?.count != nil {
            for i in 0..<(lastAttendanceStudents?.count)! {
                if lastAttendanceStudents?[i].status ?? false {
                    count = count + 1
                }
            }
            dynamicStudentCounter.text = "\(count)"
        }
    }
    
    func navigateToLoginAgain() {
        let alertController = UIAlertController(title: "Oops!", message: "Seems link your token expired, we'll redirect you to LogIn screen to refresh your token", preferredStyle: .alert)
        let gotoButton = UIAlertAction(title: "Go to Login Screen", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("gotoButton Pressed")
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                loginVC.tokExpMidCycle = true
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
        alertController.addAction(gotoButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showNoDataAlert() {
        let alert = UIAlertController(title: "Alert", message: "No last attendance stats available", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in self.okPressed()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkInternet() -> Bool {
        return InternetConnectionManager.isConnectedToNetwork()
    }
    
    func somethingGoneWrongError() {
        let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    @objc func okPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "\(self.count) Students Present", message: "Do you want to submit Attendance ?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in self.yesPressed()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: API CALLS
    func sendStudents() {
        startLoading()
        request(
            isToken: true,
            endpoint: .sendAttendance,
            requestType: .post,
            postData: try? JSONEncoder().encode(self.studentRecord),
            vibrateUponSuccess: true) { [weak self] data in
                self?.stopLoading()
                if let data = data {
                    do {
                        _ = try JSONDecoder().decode(SubmitAttendanceResponseModel.self, from: data)
                        self?.navigationController?.popViewController(animated: true)
                        return
                    } catch let error {
                        print(error)
                    }
                }
                self?.showGenericErrorAlert()
            } _: { [weak self] error in
                self?.stopLoading()
                self?.showGenericErrorAlert()
                print("Error in Request/Response \(EndPoints.sendAttendance.description) \(String(describing: error))")
            }
    }
    
    func sendLastStudents() {
        startLoading()
        request(
            isToken: true,
            endpoint: .sendLastAttendance,
            requestType: .patch,
            postData: try? JSONEncoder().encode(self.lastRecordData),
            vibrateUponSuccess: true) { [weak self] data in
                self?.stopLoading()
                if let data = data {
                    do {
                        _ = try JSONDecoder().decode(SubmitAttendanceResponseModel.self, from: data)
                        self?.navigationController?.popViewController(animated: true)
                        return
                    } catch let error {
                        print(error)
                    }
                }
                self?.showGenericErrorAlert()
            } _: { [weak self] error in
                self?.stopLoading()
                self?.showGenericErrorAlert()
                print("Error in Request/Response \(EndPoints.sendLastAttendance.description) \(String(describing: error))")
            }
    }
    
    func getStudents(batch: String, subject: String, section: String, branch: String, isLab: Bool, groupNum: Int, subjectCode: String) {
        
        var endPoint: EndPoints
        
        if isLab {
            endPoint = EndPoints.getGroupSpecificStudents(batch: batch, branch: branch, subject: subjectCode, section: section, groupNo: groupNum)
        } else {
            endPoint = EndPoints.getGroupSpecificStudents(batch: batch, branch: branch, subject: subjectCode, section: section, groupNo: groupNum)
        }
        studentLoader.startAnimating()
        request(
            isToken: true,
            endpoint: endPoint,
            requestType: .get,
            postData: nil,
            vibrateUponSuccess: false) { [weak self] data in
                self?.studentLoader.stopAnimating()
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode([StudentListModel].self, from: data)
                        self?.students = response
                        self?.prepareRecordData()
                        return
                    } catch let error {
                        print(error)
                    }
                }
                self?.showGenericErrorAlert()
            } _: { [weak self] error in
                self?.studentLoader.stopAnimating()
                self?.showGenericErrorAlert()
                print("Error in Request/Response \(endPoint.description) \(String(describing: error))")
            }
    }
    
    func getLastAttendanceStudents(batch: String, subject: String, section: String, branch: String, isLab: Bool, subjectCode: String) {
        
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        
        DispatchQueue.main.async {
            self.studentLoader.startAnimating()
        }
        
        print("______________________________")
        print(EndPoints.getLastAttendanceStudents(batch: batch, branch: branch, subject: subjectCode, section: section).description)
        var request: URLRequest
        
        guard let url = URL(string: EndPoints.getLastAttendanceStudents(batch: batch, branch: branch, subject: subjectCode, section: section).description) else {
            return
        }
        
        request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            
            DispatchQueue.main.async {
                self?.studentLoader.stopAnimating()
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
                    let d1 = try JSONDecoder().decode([LastAttendanceStudentModel].self, from: data!)
                    self?.lastAttendanceStudents = d1
                    DispatchQueue.main.async {
                        self?.updateCounter()
                        self?.prepareLastRecordData()
                        print(d1)
                        print("______________________________")
                    }
                    
                } catch(let error) {
                    if let httpResponse = response as? HTTPURLResponse {
                        DispatchQueue.main.async {
                            if httpResponse.statusCode == 401 {
                                print("token expired")
                                self?.navigateToLoginAgain()
                                return
                            } else {
                                self?.showNoDataAlert()
                            }
                        }
                    }
                    print(error)
                    print("______________________________")
                }
            }
        })
        task.resume()
    }
    
    func getLastAttendanceStudentsNew(batch: String, subject: String, section: String, branch: String, isLab: Bool, subjectCode: String) {
        studentLoader.startAnimating()
        
        request(
            isToken: true,
            endpoint: .getLastAttendanceStudents(batch: batch, branch: branch, subject: subjectCode, section: section),
            requestType: .get,
            postData: nil,
            vibrateUponSuccess: false) { [weak self] data in
                self?.studentLoader.stopAnimating()
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode([LastAttendanceStudentModel].self, from: data)
                        self?.lastAttendanceStudents = response
                        self?.updateCounter()
                        self?.prepareLastRecordData()
                        return
                    } catch let error {
                        print(error)
                    }
                }
                self?.showGenericErrorAlert()
            } _: { [weak self] error in
                self?.studentLoader.stopAnimating()
                self?.showGenericErrorAlert()
                self?.showGenericErrorAlert()
                print("Error in Request/Response \(EndPoints.getLastAttendanceStudents(batch: batch, branch: branch, subject: subjectCode, section: section).description) \(String(describing: error))")
            }
    }
}


// MARK: UICollectionViewDelegate UICollectionViewDataSource UICollectionViewDelegateFlowLayout
extension StudentListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isEditingPrevAttendance {
            return self.lastRecordData?.record.count ?? 0
        }
        return self.studentRecord?.record.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudentListCell", for: indexPath) as? StudentListCell {
            
            if isEditingPrevAttendance {
                cell.rollNoLabel.text = "\(self.lastAttendanceStudents?[indexPath.row].class_roll_number ?? -1)"
                cell.nameLabel.text = self.lastAttendanceStudents?[indexPath.row].name ?? ""
                if self.lastRecordData?.record[indexPath.row].status ?? false {
                    cell.backgroundColor = UIColor.systemGreen
                } else {
                    cell.backgroundColor = UIColor.systemYellow
                }
            } else {
                cell.rollNoLabel.text = self.students?[indexPath.row].class_roll_number
                cell.nameLabel.text = self.students?[indexPath.row].name
                if self.studentRecord?.record[indexPath.row].status ?? false {
                    cell.backgroundColor = UIColor.systemGreen
                } else {
                    cell.backgroundColor = UIColor.systemYellow
                }
            }
            
            cell.layer.cornerRadius = 20
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2 - 15, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)
        
        if isEditingPrevAttendance {
            if lastRecordData?.record[indexPath.row].status ?? true {
                lastRecordData?.record[indexPath.row].status = false
                selectedCell?.backgroundColor = UIColor.systemYellow
                count = count - 1
            } else {
                lastRecordData?.record[indexPath.row].status = true
                selectedCell?.backgroundColor = UIColor.systemGreen
                count = count + 1
            }
        } else {
            if studentRecord?.record[indexPath.row].status ?? true {
                studentRecord?.record[indexPath.row].status = false
                selectedCell?.backgroundColor = UIColor.systemYellow
                count = count - 1
            } else {
                studentRecord?.record[indexPath.row].status = true
                count = count + 1
                selectedCell?.backgroundColor = UIColor.systemGreen
            }
        }
        
        
        dynamicStudentCounter.text = "\(count)"
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(index: indexPath.row)
    }
    
    func configureContextMenu(index: Int) -> UIContextMenuConfiguration {
        
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            if self.isEditingPrevAttendance {
                let name = UIAction(title: "Name: \(self.lastAttendanceStudents?[index].name ?? "")", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                }
                let enrollmentNo = UIAction(title: "Enrollment No: \(self.lastAttendanceStudents?[index].enrollment_number ?? "")", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                }
                let classRollNo = UIAction(title: "ClassRoll No: \(self.lastAttendanceStudents?[index].class_roll_number ?? -1)", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                }
                
                return UIMenu(title: "Student Details", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [name ,enrollmentNo, classRollNo])
                
            } else {
                let name = UIAction(title: "Name: \(self.students?[index].name ?? "")", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                }
                let enrollmentNo = UIAction(title: "Enrollment No: \(self.students?[index].enrollment_number ?? "")", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                }
                let classRollNo = UIAction(title: "ClassRoll No: \(self.students?[index].class_roll_number ?? "")", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                }
                let specificAttendance = UIAction(title: "Attendance: \(self.students?[index].attendance_count ?? 0)", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                }
                
                return UIMenu(title: "Student Details", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [name ,enrollmentNo, classRollNo, specificAttendance])
            }
            return UIMenu()
        }
        return context
    }
}

extension StudentListViewController: NoInternetProtocols {
    func onRetryPressed() {
        disableEnableViews()
        yesPressed()
    }
    
    func onGoBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}
