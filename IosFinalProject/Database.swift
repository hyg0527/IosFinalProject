//
//  Database.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/13/24.
//

import Foundation

enum DbAction {
    case add, modify, delete
}

protocol Database {
    init(parentNotification: (([String: Any]?, DbAction?) -> Void)?)
    
    func setQuery(from: Any, to: Any)
    
    func saveChange(key: String, object: [String: Any], action: DbAction)
}
