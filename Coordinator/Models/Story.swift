//
//  Story.swift
//  Coordinator
//
//  Created by Chris Moore on 4/6/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Story {
    var ref: DatabaseReference?
    var title: String = "This is an example title."
    var id: Int = 0
    var url: String = "https://www.example.com"
    var comments: [Comment] = []
    var points: Int = 0
    var timestamp: TimeInterval = 0
    var by: String = ""
    var type: String = ""
    var text: String = ""
    
    var domain: String {
        get {
            URL(string: url)?.host ?? ""
        }
    }
    
    convenience init(snapshot: DataSnapshot) {
        let data = snapshot.value as? NSDictionary ?? [:]
        
        self.init()
        
        self.title = data["title"] as? String ?? ""
        self.id = data["id"] as? Int ?? 0
        self.url = data["url"] as? String ?? ""

        self.points = data["score"] as? Int ?? 0
        self.timestamp = data["time"] as? TimeInterval ?? 0
        self.by = data["by"] as? String ?? ""
        self.type = data["type"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        
        if let kids = data["kids"] as? [Int] {
            for kid in kids {
                let comment = Comment()
                comment.id = kid
                comment.story = self
                comment.position = 0
                
                self.comments.append(comment)
            }
        }
        
        self.ref = snapshot.ref
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
