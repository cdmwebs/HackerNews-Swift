//
//  Comment.swift
//  Coordinator
//
//  Created by Chris Moore on 4/9/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation
import Firebase

class Comment: CustomStringConvertible {
    var by: String = ""
    var id: Int = 0
    var replies: [Comment] = []
    var parent: Int?
    var story: Story?
    var text: String = ""
    var timestamp: TimeInterval = 0
    var type: String = ""
    var ref: DatabaseReference?
    var depth: Int = 0
    
    var childIds: [Int] {
        let replyIds = replies.reduce([]) { (result, reply) -> [Int] in
            return result + reply.childIds
        }
        
        return [id] + replyIds
    }
    
    convenience init(snapshot: DataSnapshot) {
        let data = snapshot.value as? NSDictionary ?? [:]
        
        self.init()
        
        self.by = data["by"] as? String ?? ""
        self.id = data["id"] as? Int ?? 0
        self.text = data["text"] as? String ?? ""
        self.timestamp = data["time"] as? TimeInterval ?? 0
        self.type = data["type"] as? String ?? ""
        self.parent = data["parent"] as? Int
        
        if let kids = data["kids"] as? [Int] {
            for kid in kids {
                let reply = Comment()
                
                reply.parent = self.id
                reply.id = kid
                
                self.replies.append(reply)
            }
        }
        
        self.ref = snapshot.ref
    }

    var description: String {
        return "\(id): \(replies.count) replies, parent: \(String(describing: parent))"
    }
    
    func add(reply: Comment) {
        replies.append(reply)
        reply.parent = id
    }
    
    func search(value: Int) -> Comment? {
        if value == id { return self }
        
        for reply in replies {
            if let found = reply.search(value: id) {
                return found
            }
        }
        
        return nil
    }
    
    var postedAt: String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter.string(from: date)
    }
}
