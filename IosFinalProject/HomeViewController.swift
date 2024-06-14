//
//  ViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/3/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore().collection("posts")
    var posts: [Post] = []
    var imagePool: [String: UIImage] = [:]
    var dbFirebase: DbFirebase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostTableViewCell")
        
//        dbFirebase = DbFirebase(parentNotification: manageDatabase)
//        dbFirebase?.setQuery(from: 1, to: 10000)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPosts()
    }
    
    func manageDatabase(dict: [String: Any]?, dbAction: DbAction?) {
        let post = Post.fromDict(dict: dict!)
        if dbAction == .add {
            let post = Post.fromDict(dict: dict!)
            posts.append(post)
        }
        if dbAction == .modify {
            for i in 0 ..< posts.count { // 삭제 대상을 찾아서 선택되 row의 시티정보 수정
                if post.id == posts[i].id {
//                    posts[i] = city
//                    imagePool[city.imageName] = nil
                    break
                }
            }
//            if let indexPath = cityTableView.indexPathForSelectedRow {
//                cities[indexPath.row] = city
//            }
        }
        if dbAction == .delete {
            for i in 0..<posts.count {
                if post.id == posts[i].id {
                    posts.remove(at: i)
                    break
                }
            }
        }
        tableView.reloadData()
    }
    
    func getPosts() {
        db.order(by: "time", descending: true)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            else {
                self.posts = querySnapshot?.documents.compactMap { document -> Post? in
                    try? document.data(as: Post.self)
                } ?? []
                self.tableView.reloadData()
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let table = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        
        table.title.text = post.title
        table.comment.text = post.comment
        table.userName.text = "작성자: " + post.user
        table.time.text = post.time
        
        // 이미지를 설정하기 전에 이미지 뷰 초기화
        table.imageViewCell.image = nil
        
        let imageName = post.title + " image"
        
        // 캐시에서 이미지를 가져오기
        if let cachedImage = imagePool[imageName] {
            table.imageViewCell.image = cachedImage
        } else {
            // 이미지 다운로드
            downloadImage(imageName: imageName) { [weak self] image in
                guard let self = self else { return }
                self.imagePool[imageName] = image
                
                // 다운로드 완료 후에 올바른 셀인지 확인
                if let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
                    cell.imageViewCell.image = image
                }
            }
        }
        
        return table
    }
    
    func downloadImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
        let reference = Storage.storage().reference().child("posts").child(imageName)
        let megaByte = Int64(10 * 1024 * 1024)
        reference.getData(maxSize: megaByte) { data, error in
            completion(data != nil ? UIImage(data: data!) : nil)
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let customCell = cell as! PostTableViewCell
        customCell.contentView.layer.masksToBounds = true
        
        // 셀 사이의 간격을 설정
        let margins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        cell.contentView.frame = cell.contentView.frame.inset(by: margins)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .detailDisclosureButton
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        performSegue(withIdentifier: "showDetail", sender: self)
    }
}
