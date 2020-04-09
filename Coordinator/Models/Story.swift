//
//  Story.swift
//  Coordinator
//
//  Created by Chris Moore on 4/8/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation

class Story {
    var ID: Int = 0
    var commentsCount: Int = 1256
    var domain: String = "www.example.com"
    var title: String = ""
    
    init(ID: Int, commentsCount: Int, domain: String?, title: String) {
        self.ID = ID
        self.commentsCount = commentsCount
        self.domain = domain ?? ""
        self.title = title
    }
}
