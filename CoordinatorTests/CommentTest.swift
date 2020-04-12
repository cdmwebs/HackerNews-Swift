//
//  CommentTest.swift
//  CoordinatorTests
//
//  Created by Chris Moore on 4/11/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import XCTest
@testable import Coordinator

class CommentTest: XCTestCase {
    var emptyComment: Comment = Comment()

    func testAddReply() throws {
        emptyComment.id = 1000
        
        let reply = Comment()
        reply.id = 10001
        
        emptyComment.add(reply: reply)
        
        XCTAssertEqual(1, emptyComment.replies.count)
        XCTAssertEqual(1000, reply.parent)
    }
}
