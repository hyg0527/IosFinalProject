//
//  Post.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/13/24.
//

import Foundation
import FirebaseFirestore

struct Post: Codable {
    var user: String
    var time: String
    var title: String
    var comment: String
    var depart: GeoPoint
    var arrive: GeoPoint
    
    init(user: String, time: String, title: String, comment: String, depart: GeoPoint, arrive: GeoPoint) {
        self.user = user
        self.time = time
        self.title = title
        self.comment = comment
        self.depart = depart
        self.arrive = arrive
    }
}

extension Post {
    static func toDict(post: Post) -> [String: Any]{
        var dict = [String: Any]()
        
        dict["user"] = post.user
        dict["time"] = post.time
        dict["title"] = post.title
        dict["comment"] = post.comment
        dict["depart"] = post.depart
        dict["arrive"] = post.arrive

        return dict
    }
    
    static func fromDict(dict: [String: Any]) -> Post {
        let user = dict["user"] as! String
        let time = dict["time"] as! String
        let title = dict["title"] as! String
        let comment = dict["comment"] as! String
        let depart = dict["depart"] as! GeoPoint
        let arrive = dict["arrive"] as! GeoPoint
        
        return Post(user: user, time: time, title: title, comment: comment, depart: depart, arrive: arrive)
    }
}
