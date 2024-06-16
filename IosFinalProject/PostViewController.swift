//
//  PostViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/7/24.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class PostViewController: UIViewController {

    @IBOutlet weak var resLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var imageViewPic: UIImageView!
    
    var isShowKeyboard = false
    var location = Firestore.firestore().collection("posts")
    var currentUser = Auth.auth().currentUser?.displayName
    
    var departGeo: GeoPoint?
    var arriveGeo: GeoPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTapGesture)
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(choosePic))
        imageViewPic.addGestureRecognizer(imageTapGesture)
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func goToMapPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    
    @IBAction func postPressed(_ sender: UIButton) {
        uploadPost()
        resetPostView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap",
           let destinationVC = segue.destination as? MapViewController {
            destinationVC.coordDelegate = self
        }
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
    
    func resetPostView() { // 리셋 함수
        titleTextField.text = ""
        commentTextField.text = ""
        imageViewPic.image = nil
        imageViewPic.backgroundColor = .systemGray3
        resLabel.text = ""
        departGeo = nil
        arriveGeo = nil
    }
    
    func uploadPost() { // firebase에 글 등록 함수
        guard let title = titleTextField.text, title.isEmpty == false else { return }
        guard let comment = commentTextField.text, comment.isEmpty == false else { return }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd a hh:mm"
        let time = dateFormatter.string(from: currentDate)
        
        let post = Post(user: currentUser!, time: time, title: title, comment: comment, depart: departGeo!, arrive: arriveGeo!)

        location.document(time).setData(Post.toDict(post: post))
        
        uploadImage(imageName: title + " image", image: imageViewPic.image!)
    }
    
    func uploadImage(imageName: String, image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        let reference = Storage.storage().reference().child("posts").child(imageName)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        reference.putData(imageData, metadata: metaData, completion: nil)
    }
}

extension PostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        imageViewPic.image = image
        imageViewPic.backgroundColor = .clear
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PostViewController: SendCoordinate {
    func convertCoordinate(coord:  CLLocationCoordinate2D) -> GeoPoint {
        return GeoPoint(latitude: coord.latitude, longitude: coord.longitude)
    }
    
    func sendCord(depart: CLLocationCoordinate2D, arrive: CLLocationCoordinate2D) {
        resLabel.text = "경로 설정 완료"
        
        // GeoPoint를 CLLocationCoordinate2D로 변환
        departGeo = convertCoordinate(coord: depart)
        arriveGeo = convertCoordinate(coord: arrive)
    }
}

extension PostViewController {
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
