//
//  MyPageViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/7/24.
//

import UIKit
import FirebaseAuth

class MyPageViewController: UIViewController {

    @IBOutlet weak var userInfoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userName = Auth.auth().currentUser?.displayName
        userInfoLabel.text = "\(userName!)님, 환영합니다!"
    }
    
    @IBAction func logOutClicked(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch _ as NSError {
            
        }
    }
}
