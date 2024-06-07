//
//  ViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/3/24.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    @IBOutlet weak var userInfoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        userInfoLabel.text = Auth.auth().currentUser?.displayName
    }

}

