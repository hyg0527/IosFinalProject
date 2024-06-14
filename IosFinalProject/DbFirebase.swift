//
//  DbFirebase.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/13/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class DbFirebase: Database {
    var reference = Firestore.firestore().collection("posts")
    var parentNotification: (([String : Any]?, DbAction?) -> Void)?
    var existQuery: ListenerRegistration?
    
    required init(parentNotification: (([String : Any]?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification
    }
    
    func setQuery(from: Any, to: Any) {
        if let query = existQuery {
            query.remove()
        }
        
        let query = reference.whereField("id", isGreaterThanOrEqualTo: 0).whereField("id", isLessThanOrEqualTo: 10000)
        existQuery = query.addSnapshotListener(onChangingData)
    }
    
    func saveChange(key: String, object: [String : Any], action: DbAction) {
        if action == .delete {
            reference.document(key).delete()
            return
        }
        reference.document(key).setData(object)
    }
    
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnapshot = querySnapshot else { return }
        
        if (querySnapshot.documentChanges.count == 0) {
            return
        }
        
        for documentChange in querySnapshot.documentChanges {
            let dict = documentChange.document.data()
            var action: DbAction?
            
            switch (documentChange.type) {
            case .added: action = .add
            case .modified: action = .modify
            case .removed: action = .delete
            }
            
            if let parentNotification = parentNotification { parentNotification(dict, action) }
        }
    }
}

extension DbFirebase {
    func uploadImage(imageName: String, image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        let reference = Storage.storage().reference().child("posts").child(imageName)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        reference.putData(imageData, metadata: metaData, completion: nil)
    }
    
    func downloadImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
        let reference = Storage.storage().reference().child("posts").child(imageName)
        let megaByte = Int64(10 * 1024 * 1024)
        reference.getData(maxSize: megaByte) { data, error in
            completion(data != nil ? UIImage(data: data!) : nil)
        }
    }
}
