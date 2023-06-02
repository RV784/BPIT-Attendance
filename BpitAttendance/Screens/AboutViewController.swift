//
//  AboutViewController.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 05/11/22.
//

import UIKit

class AboutViewController: BaseViewController {
    @IBOutlet var aboutAppTableView: UITableView!
    
    private var aboutAppData: [AboutTableViewCell.ViewModel] = [] {
        didSet {
            aboutAppTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        aboutAppTableView.delegate = self
        aboutAppTableView.dataSource = self
        aboutAppTableView.register(type: AboutTableViewCell.self)
        
        navigationItem.title = "About this app"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        makeData()
    }
    
    private func makeData() {
        var data: [AboutTableViewCell.ViewModel] = []
        
        // Achal Kaushik
        data.append(.init(
            name: "Prof. Achal Kaushik",
            profileImage: UIImage(named: "achalSir"),
            designationText: "HOD (Computer Science)")
        )
        
        // Rajat Verma
        data.append(.init(
            name: "Rajat Verma",
            profileImage: UIImage(named: "rajat"),
            designationText: "Mobile App Developer (iOS)")
        )
        
        // Shubham Jindal
        data.append(.init(
            name: "Shubham Jindal",
            profileImage: UIImage(named: "jindal"),
            designationText: "Backend Developer")
        )
        
        // Nishant Mittal
        data.append(.init(
            name: "Nishant Mittal",
            profileImage: UIImage(named: "nishant"),
            designationText: "Mobile App Developer (Android)")
        )
        
        // Mohak Sharma
        data.append(.init(
            name: "Mohak Sharma",
            profileImage: UIImage(named: "mohak"),
            designationText: "Web Developer")
        )
        
        aboutAppData = data
    }
}

extension AboutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        aboutAppData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(AboutTableViewCell.self) {
            cell.config(aboutAppData[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        86
    }
}
