//
//  Comment.swift
//  Coordinator
//
//  Created by Chris Moore on 4/9/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    var by: String?
    var id: Int = 0
    var kids: [Int] = []
    var parent: Int?
    var text: String = ""
    var timestamp: TimeInterval = 0
    var type: String = ""
    var ref: DatabaseReference?
    var replies: [Comment] = []
    
    init (snapshot: DataSnapshot) {
        let data = snapshot.value as? NSDictionary ?? [:]
        
        by = data["by"] as? String ?? ""
        id = data["id"] as? Int ?? 0
        kids = data["kids"] as? [Int] ?? []
        parent = data["parent"] as? Int ?? 0
        text = data["text"] as? String ?? ""
        timestamp = data["time"] as? TimeInterval ?? 0
        type = data["type"] as? String ?? ""
        
        ref = snapshot.ref
    }
}
