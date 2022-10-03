//
//  NoInternetView.swift
//  BpitAttendance
//
//  Created by Rajat Verma on 30/09/22.
//

import UIKit

protocol NoInternetProtocols {
    func onRetryPressed()
    func onGoBackPressed()
}

@IBDesignable
class NoInternetView: UIView {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var gobackBtn: UIButton!
    @IBOutlet weak var intrernetImgView: UIImageView!
    var delegate: NoInternetProtocols?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xyz()
        
        intrernetImgView.layer.cornerRadius = 100
        gobackBtn.layer.cornerRadius = 10
        retryBtn.layer.cornerRadius = 10
        mainView.layer.cornerRadius = 15
        mainView.layer.borderWidth = 0.5
        mainView.layer.borderColor = UIColor.gray.cgColor
    }
    
    @IBAction func retryBtnClicked(_ sender: Any) {
        delegate?.onRetryPressed()
    }
    
    @IBAction func goBackBtnClicked(_ sender: Any) {
        delegate?.onGoBackPressed()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    
    func xyz() {
        Bundle.main.loadNibNamed("NoInternetView", owner: self)
        addSubview(mainView)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
