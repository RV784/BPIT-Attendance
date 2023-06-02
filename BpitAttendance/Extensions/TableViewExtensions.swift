//
//  TableViewExtensions.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 03/06/23.
//

import UIKit

extension UITableView {
    
    func register(type: UITableViewCell.Type) {
        let className = String(describing: type)
        register(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: className)
    }
    
    func registerHeaderFooter(_ type: UITableViewHeaderFooterView.Type) {
        let className = String(describing: type)
        register(UINib(nibName: className, bundle: nil), forHeaderFooterViewReuseIdentifier: className)
    }
    
    func dequeueReusableCell<T>(_ type: T.Type) -> T? {
        let className = String(describing: type)
        return dequeueReusableCell(withIdentifier: className) as? T
    }
    
    func dequeueReusableHeaderFooterView<T>(_ type: T.Type) -> T? {
        let className = String(describing: type)
        return dequeueReusableHeaderFooterView(withIdentifier: className) as? T
    }
    
    func removeTableFooter() {
        self.tableFooterView = nil
    }
}
