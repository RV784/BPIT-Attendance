//
//  StudentListViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 21/09/22.
//

import UIKit

class StudentListViewController: UIViewController {
    
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
                getLastAttendanceStudents(batch: self.batch, subject: self.subject, section: self.section, branch: self.branch, isLab: false, subjectCode: self.subjectCode)
            } else {
                showNoInternetAlter()
            }
        } else {
            if checkInternet() {
                getStudents(batch: self.batch, subject: self.subject, section: self.section, branch: self.branch, isLab: self.isLab, groupNum: self.groupNum, subjectCode: self.subjectCode)
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
                                                                          class_roll_number: item.class_roll_number ?? "",
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
//        if checkConnection() {
//            if isEditingPrevAttendance {
//                sendLastStudents()
//            } else {
//                sendStudents()
//            }
//        } else {
//            disableEnableViews()
////        }
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
        
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        
        guard let url = URL(string: EndPoints.sendAttendance.description) else {
            return
        }
        
        submitBtn.setTitle("", for: .normal)
        attendanceSubmitLoader.startAnimating()
        
        print("______________________________")
        print(EndPoints.sendAttendance.description)
        
        let recordData = try? JSONEncoder().encode(self.studentRecord)
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = recordData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error -> Void in
            
            DispatchQueue.main.async {
                self?.submitBtn.setTitle("Submit", for: .normal)
                self?.attendanceSubmitLoader.stopAnimating()
            }
            
            if error != nil {
                print("inside error")
                print(error?.localizedDescription as Any)
                print("______________________________")
                DispatchQueue.main.async {
                    self?.somethingGoneWrongError()
                }
            } else {
                do {
                    let d1 = try JSONDecoder().decode(SubmitAttendanceResponseModel.self, from: data!)
                    print(d1)
                    if d1.msg == nil {
                        DispatchQueue.main.async {
                            print("token expired")
                            self?.navigateToLoginAgain()
                        }
                        return
                    }
                    if self?.isLab ?? false {
                        DispatchQueue.main.async {
                            self?.vibrate()
                            self?.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.vibrate()
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                    print("----------------------------")
                } catch (let error) {
                    if let httpResponse = response as? HTTPURLResponse {
                        DispatchQueue.main.async {
                            if httpResponse.statusCode == 401 {
                                print("token expired")
                                self?.navigateToLoginAgain()
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
    
    func sendLastStudents() {
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        
        guard let url = URL(string: EndPoints.sendLastAttendance.description) else {
            return
        }
        
        submitBtn.setTitle("", for: .normal)
        attendanceSubmitLoader.startAnimating()
        
        print("______________________________")
        print(EndPoints.sendLastAttendance.description)
        
        let recordData = try? JSONEncoder().encode(self.lastRecordData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = recordData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error -> Void in
            
            DispatchQueue.main.async {
                self?.submitBtn.setTitle("Submit", for: .normal)
                self?.attendanceSubmitLoader.stopAnimating()
            }
            
            if error != nil {
                print("inside error")
                print(error?.localizedDescription as Any)
                print("______________________________")
                DispatchQueue.main.async {
                    self?.somethingGoneWrongError()
                }
            } else {
                do {
                    let d1 = try JSONDecoder().decode(SubmitAttendanceResponseModel.self, from: data!)
                    print(d1)
                    print("______________________________")
                    if d1.msg == nil {
                        DispatchQueue.main.async {
                            print("token expired")
                            self?.navigateToLoginAgain()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self?.vibrate()
                        self?.navigationController?.popViewController(animated: true)
                    }
                } catch (let error){
                    if let httpResponse = response as? HTTPURLResponse {
                        DispatchQueue.main.async {
                            if httpResponse.statusCode == 401 {
                                print("token expired")
                                self?.navigateToLoginAgain()
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
    
    func getStudents(batch: String, subject: String, section: String, branch: String, isLab: Bool, groupNum: Int, subjectCode: String) {
        
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        
        var request: URLRequest
        print("______________________________")
        if isLab {
            guard let url = URL(string: EndPoints.getGroupSpecificStudents(batch: batch, branch: branch, subject: subjectCode, section: section, groupNo: groupNum).description) else {
                return
            }
            request = URLRequest(url: url)
            print(EndPoints.getGroupSpecificStudents(batch: batch, branch: branch, subject: subjectCode, section: section, groupNo: groupNum).description)
        } else {
            guard let url = URL(string: EndPoints.getAllStudents(batch: batch, branch: branch, subject: subjectCode, section: section).description) else {
                return
            }
            request = URLRequest(url: url)
            print(EndPoints.getAllStudents(batch: batch, branch: branch, subject: subjectCode, section: section).description)
        }
        
        studentLoader.startAnimating()
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
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
                    let d1 = try JSONDecoder().decode([StudentListModel].self, from: data!)
                    self?.students = d1
                    DispatchQueue.main.async {
                        print(self?.students as Any)
                        print("______________________________")
                        self?.prepareRecordData()
                    }
                    
                } catch(let error) {
                    if let httpResponse = response as? HTTPURLResponse {
                        DispatchQueue.main.async {
                            if httpResponse.statusCode == 401 {
                                print("token expired")
                                self?.navigateToLoginAgain()
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
    
    func getLastAttendanceStudents(batch: String, subject: String, section: String, branch: String, isLab: Bool, subjectCode: String) {
        
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        
        self.studentLoader.startAnimating()
        
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
                cell.rollNoLabel.text = self.lastAttendanceStudents?[indexPath.row].class_roll_number ?? ""
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
                let classRollNo = UIAction(title: "ClassRoll No: \(self.lastAttendanceStudents?[index].class_roll_number ?? "")", image: UIImage(), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
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
