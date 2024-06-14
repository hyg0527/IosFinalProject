//
//  Post.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/13/24.
//

import Foundation

struct Post: Codable {
    var id: Int
    var user: String
    var time: String
    var title: String
    var comment: String
    
    init(id: Int, user: String, time: String, title: String, comment: String) {
        self.id = id
        self.user = user
        self.time = time
        self.title = title
        self.comment = comment
    }
}

extension Post {
    static func toDict(post: Post) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["id"] = post.id
        dict["user"] = post.user
        dict["time"] = post.time
        dict["title"] = post.title
        dict["comment"] = post.comment
//        dict["imageName"] = city.imageName

        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> Post {
        
        let id = dict["id"] as! Int
        let user = dict["user"] as! String
        let time = dict["time"] as! String
        let title = dict["title"] as! String
        let comment = dict["comment"] as! String
//        let imageName = dict["imageName"] as! String

        return Post(id: id, user: user, time: time, title: title, comment: comment)
    }
}
