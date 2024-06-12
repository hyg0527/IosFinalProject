//
//  PostViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/7/24.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var imageViewPic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(choosePic))
        imageViewPic.addGestureRecognizer(imageTapGesture)
    }
    
    @IBAction func postPressed(_ sender: UIBarButtonItem) {
        resetPostView()
    }
    
    @objc func choosePic(sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
        } else {
            imagePickerController.sourceType = .savedPhotosAlbum
        }
        
        imagePickerController.sourceType = .savedPhotosAlbum
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func resetPostView() {
        titleTextField.text = ""
        commentTextField.text = ""
        imageViewPic.image = nil
    }
}

extension PostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        imageViewPic.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
