//
//  LoginViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/7/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        warningLabel.isHidden = true
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = idTextField.text, !email.isEmpty else {
            print("이메일을 입력하세요.")
            return
        }

        guard let password = pwTextField.text, !password.isEmpty else {
            print("비밀번호를 입력하세요.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error == nil { // 로그인 성공
                self.warningLabel.isHidden = true
                self.performSegue(withIdentifier: "goToMain", sender: self)
            } else { // 로그인 실패
                self.warningLabel.isHidden = false
            }
        }
    }
    
    @IBAction func signUpClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "register", sender: self)
    }
}
