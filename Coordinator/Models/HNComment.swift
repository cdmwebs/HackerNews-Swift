//
//  HNComment.swift
//  Coordinator
//
//  Created by Chris Moore on 4/16/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation

class HNComment: HNItem {
    var depth: Int = 0
    var parent: Int = 0
    
    private enum CodingKeys: String, CodingKey { case parent }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        parent = try values.decode(Int.self, forKey: .parent)
    }
}
