//
//  Story.swift
//  Coordinator
//
//  Created by Chris Moore on 4/6/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Story {
    var ref: DatabaseReference?
    var title: String = "This is an example title."
    var id: Int = 0
    var url: String = "https://www.example.com"
    var kids: [Int] = []
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
    
    init (snapshot: DataSnapshot) {
        let data = snapshot.value as? NSDictionary ?? [:]
        
        title = data["title"] as? String ?? ""
        id = data["id"] as? Int ?? 0
        url = data["url"] as? String ?? ""
        kids = data["kids"] as? [Int] ?? []
        points = data["score"] as? Int ?? 0
        timestamp = data["time"] as? TimeInterval ?? 0
        by = data["by"] as? String ?? ""
        type = data["type"] as? String ?? ""
        text = data["text"] as? String ?? ""
        
        ref = snapshot.ref
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
