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
    
    @IBOutlet weak var bottomBtnViews: UIView!
    @IBOutlet weak var attendanceSubmitLoader: UIActivityIndicatorView!
    @IBOutlet weak var studentLoader: UIActivityIndicatorView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var studentCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        studentCollectionView.dataSource = self
        studentCollectionView.delegate = self
        print(self.batch)
        print(self.subject)
        print(self.subjectCode)
        print(self.branch)
        print(self.isLab)
        print(self.groupNum)
        print("_-------------------")
        getStudents(batch: self.batch, subject: self.subjectCode, section: self.section, branch: self.branch, isLab: self.isLab, groupNum: self.groupNum, subjectCode: self.subject)
        studentCollectionView.register(UINib(nibName: "StudentListCell", bundle: nil), forCellWithReuseIdentifier: "StudentListCell")
        studentCollectionView.contentInset = UIEdgeInsets(top: CGFloat(10), left: CGFloat(10), bottom: 0, right: CGFloat(10))
        submitBtn.layer.cornerRadius = 25
        navigationItem.backButtonTitle = ""
        navigationItem.title = "Students"
        studentRecord = RecordData(record: [])
        //        print(subjectCode)
        //        print(subject)
        //        print(batch)
        navigationItem.backButtonTitle = ""
        bottomBtnViews.layer.cornerRadius = 25
        submitBtn.layer.cornerRadius = 25
        submitBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func prepareRecordData() {
        for item in self.students ?? [] {
            studentRecord?.record.append(RecordData.studentData(status: false, enrollment_number: item.enrollment_number ?? "", subject: self.subject, batch: self.batch))
        }
        print(students?.count as Any)
        print(studentRecord?.record.count as Any)
        self.studentCollectionView.reloadData()
    }
    
    
    @IBAction func submitBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "\(self.count) Students Present", message: "Do you want to submit Attendance ?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in self.yesPressed()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func yesPressed() {
        sendStudents()
    }
    
    func sendStudents(){
        submitBtn.setTitle("", for: .normal)
        attendanceSubmitLoader.startAnimating()
        let recordData = try? JSONEncoder().encode(self.studentRecord)
        var request = URLRequest(url: URL(string: EndPoints.sendAttendance.description)!)
        request.httpMethod = "POST"
        request.httpBody = recordData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(Credentials.shared.token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                print(response as Any)
                DispatchQueue.main.async {
                    self.submitBtn.setTitle("", for: .normal)
                    self.attendanceSubmitLoader.stopAnimating()
                    
                    let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                    for aViewController in viewControllers {
                        if aViewController is SubjectViewController {
                            self.navigationController!.popToViewController(aViewController, animated: true)
                        }
                    }
                }
            } catch {
                print("error")
            }
        })
        
        task.resume()
    }
    
    func getStudents(batch: String, subject: String, section: String, branch: String, isLab: Bool, groupNum: Int, subjectCode: String){
        self.studentLoader.startAnimating()
        var request: URLRequest
        if isLab {
            request = URLRequest(url: URL(string: EndPoints.getGroupSpecificStudents(batch: batch, branch: branch, subject: subject, section: section, groupNo: groupNum).description)!)
        } else {
            request = URLRequest(url: URL(string: EndPoints.getAllStudents(batch: batch, branch: branch, subject: subjectCode, section: section).description)!)
        }
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(Credentials.shared.token)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
            if error != nil {
                self?.studentLoader.startAnimating()
                print("inside error")
                print(error?.localizedDescription ?? "")
            }else{
                do{
                    let d1 = try JSONDecoder().decode([StudentListModel].self, from: data!)
                    self?.students = d1
                    print(self?.students?.count ?? 0)
                    DispatchQueue.main.async {
                        self?.studentLoader.stopAnimating()
                        self?.prepareRecordData()
                    }
                    
                } catch(let error) {
                    self?.studentLoader.stopAnimating()
                    print("do catch error", error)
                }
            }
        })
        task.resume()
    }
}

extension StudentListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.studentRecord?.record.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudentListCell", for: indexPath) as? StudentListCell {
            cell.rollNoLabel.text = self.students?[indexPath.row].class_roll_number
            cell.nameLabel.text = self.students?[indexPath.row].name
            if self.studentRecord?.record[indexPath.row].status ?? false {
                cell.backgroundColor = UIColor.systemGreen
            } else {
                cell.backgroundColor = UIColor.systemYellow
            }
            cell.layer.cornerRadius = 20
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width/2 - 15, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCell = collectionView.cellForItem(at: indexPath)
        
        if studentRecord?.record[indexPath.row].status ?? true {
            studentRecord?.record[indexPath.row].status = false
            selectedCell?.backgroundColor = UIColor.systemYellow
            count = count - 1
        } else {
            studentRecord?.record[indexPath.row].status = true
            count = count + 1
            selectedCell?.backgroundColor = UIColor.systemGreen
        }
        countLabel.text = "\(count)"
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(index: indexPath.row)
    }
    
    func configureContextMenu(index: Int) -> UIContextMenuConfiguration{
        
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
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
        return context
        
    }
    
}
