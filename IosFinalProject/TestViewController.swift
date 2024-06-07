//
//  TestViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/7/24.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func buttonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "test", sender: self)
    }
}
