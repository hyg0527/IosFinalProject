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
    
    var homeViewController = HomeViewController()
    var location = Firestore.firestore().collection("posts")
//    var postID = 1011
    var currentUser = Auth.auth().currentUser?.displayName
    var dbFirebase: DbFirebase?
    
    var departGeo: GeoPoint?
    var arriveGeo: GeoPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(choosePic))
        imageViewPic.addGestureRecognizer(imageTapGesture)
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
        imageViewPic.backgroundColor = .systemMint
        resLabel.text = ""
        departGeo = nil
        arriveGeo = nil
    }
    
    func uploadPost() { // firebase에 글 등록 함수
        guard let title = titleTextField.text, title.isEmpty == false else { return }
        guard let comment = commentTextField.text, comment.isEmpty == false else { return }
        var id = homeViewController.posts.count
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd a hh:mm"
        let time = dateFormatter.string(from: currentDate)
        
        let post = Post(id: id, user: currentUser!, time: time, title: title, comment: comment, depart: departGeo!, arrive: arriveGeo!)
        
//        homeViewController.dbFirebase?.saveChange(key: String(id), object: Post.toDict(post: post), action: .add)
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
