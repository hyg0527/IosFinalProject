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
    var isShowKeyboard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        warningLabel.isHidden = true
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTapGesture)
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = idTextField.text, !email.isEmpty else {
            self.warningLabel.isHidden = false
            self.warningLabel.text = "이메일을 입력하세요."
            return
        }

        guard let password = pwTextField.text, !password.isEmpty else {
            self.warningLabel.isHidden = false
            self.warningLabel.text = "비밀번호를 입력하세요."
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error == nil { // 로그인 성공
                self.warningLabel.isHidden = true
                self.resetLabel()
                self.performSegue(withIdentifier: "goToMain", sender: self)
            } else { // 로그인 실패
                self.warningLabel.isHidden = false
            }
        }
    }
    
    @IBAction func signUpClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "register", sender: self)
    }
    
    func resetLabel() {
        idTextField.text = ""
        pwTextField.text = ""
        warningLabel.text = ""
    }
}

extension LoginViewController {
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { notification in
            if self.isShowKeyboard == false {
                self.isShowKeyboard = true
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { notification in
            self.isShowKeyboard = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
