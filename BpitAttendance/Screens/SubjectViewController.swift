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
    @IBOutlet weak var subjectCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subjectCollectionView.delegate = self
        subjectCollectionView.dataSource = self
        subjectCollectionView.register(UINib(nibName: "subjectCell", bundle: nil), forCellWithReuseIdentifier: "subjectCell")
        subjectCollectionView.contentInset = UIEdgeInsets(top: CGFloat(20), left: CGFloat(10), bottom: 0, right: CGFloat(10))
        getSubject()
        
        navigationItem.hidesBackButton = true
        navigationItem.title = "Subjects"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func createModule() -> SubjectViewController? {
        let storyBoard = UIStoryboard(name: "SubjectViewController", bundle: nil)
        if let controller = storyBoard.instantiateInitialViewController() as? SubjectViewController {
            return controller
        }
        return nil
    }

    func navigateToLoginAgain() {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController{
            self.navigationController?.popToViewController(loginVC, animated: true)
        }
    }
    
    func getSubject(){
        
        var request = URLRequest(url: URL(string: EndPoints.getSubjects.description)!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(Credentials.shared.token)", forHTTPHeaderField: "Authorization")
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
                        print(self?.subjects as Any)
                        self?.subjectCollectionView.reloadData()
                    }
                    
                } catch(let error) {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 401 {
                            DispatchQueue.main.async {
                                self?.navigateToLoginAgain()
                            }
                            print("token expired")
                        }
                    }
                }
            }
        })
        
        task.resume()
    }
}

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
