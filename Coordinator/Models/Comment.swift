//
//  Comment.swift
//  Coordinator
//
//  Created by Chris Moore on 4/9/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation

struct Comment {
    var parent: Story?
    var text: String = ""
    var author: String = ""
    var time: Int = 0
    var id: Int = 0
}
