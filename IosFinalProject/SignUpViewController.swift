//
//  SignUpViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/7/24.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var idEmail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var pwConfirm: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signUpClicked(_ sender: UIButton) {
        guard let name = userName.text, !name.isEmpty else {
            print("사용자 이름을 입력하세요.")
            return
        }
    
        guard let email = idEmail.text, !email.isEmpty else {
            print("이메일을 입력하세요.")
            return
        }

        guard let password = password.text, !password.isEmpty else {
            print("비밀번호를 입력하세요.")
            return
        }
        
        guard let pwConfirm = pwConfirm.text, !pwConfirm.isEmpty else {
            return
        }
        
        if password == pwConfirm { // 비밀번호와 비밀번호 확인이 일치하면 회원가입 진행
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if error == nil { // 회원가입 성공
                    // 사용자 프로필 변경
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.userName.text // 사용자 이름 설정
                    changeRequest?.commitChanges(completion: { error in
                        if let error = error {
                            print("사용자 이름 업데이트 실패: \(error.localizedDescription)")
                        } else {
                            print("사용자 이름 업데이트 성공")
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
                else { // 회원가입 실패
                    print("회원가입 실패")
                }
            }
        }
    }
}
