//
//  MyPageViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/7/24.
//

import UIKit
import FirebaseAuth

class MyPageViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userInfoLabel: UILabel!
    
    var user = Auth.auth().currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoShow()
    }
    
    func infoShow() {
        let userName = user?.displayName
        userInfoLabel.text = "\(userName!)님, 환영합니다!"
        
        let emailAddress = user?.email
        emailLabel.text = emailAddress
    }
    
    @IBAction func logOutClicked(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } 
        catch _ as NSError {
            print("로그아웃 오류")
        }
    }
}
