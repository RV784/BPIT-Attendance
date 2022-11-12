//
//  StatsViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 10/11/22.
//

import UIKit
import StickyLayout

class StatsViewController: UIViewController {

    @IBOutlet weak var statsCollectionView: UICollectionView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var monthButton: UIBarButtonItem!
    
    let stickyConfig = StickyLayoutConfig(stickyRowsFromTop: 1,
                                    stickyRowsFromBottom: 0,
                                    stickyColsFromLeft: 1,
                                    stickyColsFromRight: 0)
    var batch: String = ""
    var branch: String = ""
    var subject: String = ""
    var section: String = ""
    var group: String = ""
    var isLab = false
    var month = 0
    var statData: StatsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statsCollectionView.delegate = self
        statsCollectionView.dataSource = self
        statsCollectionView.register(UINib(nibName: "StatsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StatsCollectionViewCell")
        statsCollectionView.bounces = false
        
        let layOut = StickyLayout(stickyConfig: stickyConfig)
        statsCollectionView.collectionViewLayout = layOut
        
        navigationItem.title = "Attendance Stats"
        navigationController?.navigationBar.prefersLargeTitles = false
        statsCollectionView.contentInset = UIEdgeInsets(top: CGFloat(0), left: CGFloat(0), bottom: 0, right: CGFloat(0))
        
        if let monthInt = Calendar.current.dateComponents([.month], from: Date()).month {
            month = monthInt
        }
        
        let jan = UIAction(title: "January", image: UIImage(systemName: "person.fill")) { [weak self] (action) in
            self?.month = 1
            self?.getStats()
        }
        
        let feb = UIAction(title: "Feburary", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 2
            self?.getStats()
        }
        
        let mar = UIAction(title: "March", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 3
            self?.getStats()
        }
        
        let apr = UIAction(title: "April", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 4
            self?.getStats()
        }
        
        let may = UIAction(title: "May", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 5
            self?.getStats()
        }
        
        let jun = UIAction(title: "June", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 6
            self?.getStats()
        }
        
        let jul = UIAction(title: "July", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 7
            self?.getStats()
        }
        
        let aug = UIAction(title: "August", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 8
            self?.getStats()
        }
        
        let sep = UIAction(title: "September", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 9
            self?.getStats()
        }
        
        let oct = UIAction(title: "October", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 10
            self?.getStats()
        }
        
        let nov = UIAction(title: "November", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 11
            self?.getStats()
        }
        
        
        let dec = UIAction(title: "December", image: UIImage(systemName: "person.badge.plus")) { [weak self] (action) in
            self?.month = 12
            self?.getStats()
        }
        
        let menu = UIMenu(title: "More Options", options: .displayInline, children: [jan , feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec])
        
        monthButton.menu = menu
        getStats()
    }
    
    @IBAction func monthButtonClicked(_ sender: Any) {
        
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
    
    func somethingGoneWrongError() {
        let alert = UIAlertController(title: "Alert", message: "Something went wrong, please try again later", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }

    func getDate(dateTime: String) -> String {
        let date = dateTime.components(separatedBy: " ")
        if !date.isEmpty {
            return date[0]
        }
        return ""
    }
    
    func showNoDataAlert() {
        let alert = UIAlertController(title: "Alert", message: "No attendance stats available for this month", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in self.okPressed()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func okPressed() {
        
    }
}

extension StatsViewController {
    //MARK: API CALLS
    
    func getStats() {
        guard let tok = Credentials.shared.defaults.string(forKey: "Token") else {
            navigateToLoginAgain()
            return
        }
        if tok == "" {
            navigateToLoginAgain()
            return
        }
        
        var request: URLRequest
        
        if isLab {
            
            guard let url = URL(string: EndPoints.getStats(batch: batch, branch: branch, subject: subject, section: section, month: month, groupNo: group).description) else {
                return
            }
            request = URLRequest(url: url)
            print(EndPoints.getStats(batch: batch, branch: branch, subject: subject, section: section, month: month, groupNo: group).description)
            
        } else {
            guard let url = URL(string: EndPoints.getStats(batch: batch, branch: branch, subject: subject, section: section, month: month, groupNo: "").description) else {
                return
            }
            request = URLRequest(url: url)
            print(EndPoints.getStats(batch: batch, branch: branch, subject: subject, section: section, month: month, groupNo: "").description)
        }
        
        //start loader
        loader.startAnimating()
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(tok)", forHTTPHeaderField: "Authorization")
        
        print("______________________________")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            
            DispatchQueue.main.async {
                //stop loader
                self?.loader.stopAnimating()
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
                    let d1 = try JSONDecoder().decode(StatsModel.self, from: data!)

                    
                    DispatchQueue.main.async {
                        print(d1)
                        print("______________________________")
                        DispatchQueue.main.async {
                            self?.statData = d1
                            self?.statsCollectionView.reloadData()
                            if d1.columns == nil {
                                self?.showNoDataAlert()
                            }
                        }
                    }
                } catch {
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
}

extension StatsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = statData?.columns?.count {
            return count + 1
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCollectionViewCell", for: indexPath) as? StatsCollectionViewCell {
            
            cell.selectedBackgroundView?.backgroundColor = .clear
            
            if indexPath.section == 0 && indexPath.row != indexPath.section {
                if indexPath.row - 1 >= 0 {
                    // dates and rows
                    if let dateTime = statData?.columns?[indexPath.row - 1] {
                        cell.myLabel.text = getDate(dateTime: dateTime)
                        cell.myLabel.textColor = .label
                    }
                    cell.backgroundColor = .gray
                }
            } else if indexPath.row == 0 && indexPath.row != indexPath.section {
                if indexPath.section - 1 >= 0 {
                    //names and sections
                    cell.backgroundColor = .systemGray3
                    if let name = statData?.student_data?[indexPath.section-1].name {
                        cell.myLabel.text = "\(indexPath.section). \(name)"
                        cell.myLabel.textColor = .label
                    }
                }
            } else {
                cell.backgroundColor = .black
                if indexPath.section - 1 >= 0 && indexPath.row - 1 >= 0 {
                    if let attdance = statData?.student_data?[indexPath.section - 1].attendance_data?[indexPath.row - 1] {
                        cell.myLabel.text = "\(attdance)"
                        if attdance == 0 {
                            cell.myLabel.textColor = .red
                        } else {
                            cell.myLabel.textColor = .label
                        }
                    }
                }
            }

            if indexPath.row == indexPath.section && indexPath.row == 0 {
                cell.backgroundColor = .barColor
                cell.myLabel.text = "Names"
                cell.myLabel.textColor = .label
            }
            
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 115, height: 25)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let count = statData?.student_data?.count {
            return count + 1
        }
        return 1
    }
    
}


