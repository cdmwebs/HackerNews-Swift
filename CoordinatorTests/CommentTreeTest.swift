//
//  CommentTreeTest.swift
//  CoordinatorTests
//
//  Created by Chris Moore on 4/14/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import XCTest
@testable import Coordinator

class CommentTreeTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Example Comment Tree
    //
    // Index | ID | Parent | Depth | Text
    // ---------------------------------------------------------------------
    //     0 |  1 |      0 |     0 | This is a top level comment
    //     1 |  2 |      1 |     1 |   - I'm replying to the top level comment
    //     2 |  3 |      2 |     2 |     - I'm a reply to a reply
    //
    func testExample() throws {
        let secondLevelReply = Comment()
        secondLevelReply.text = "I'm a reply to a reply"
        secondLevelReply.id = 3
        
        let firstLevelReply = Comment()
        firstLevelReply.text = "I'm replying to the top level parent"
        firstLevelReply.id = 2
        
        let parentComment = Comment()
        parentComment.text = "This is a top level comment"
        parentComment.id = 1
        parentComment.parent = 0
        
        firstLevelReply.parent = 1
        firstLevelReply.replies = [secondLevelReply]
        secondLevelReply.parent = 2
        
        parentComment.replies = [firstLevelReply]
        
        let commentList = [
            parentComment,
            firstLevelReply,
            secondLevelReply
        ]
        
        let tree = CommentTree(comments: commentList)
        
        XCTAssertEqual(3, parentComment.childIds.count)
        XCTAssertEqual(3, tree.comments.count)
        XCTAssertEqual(0..<3, tree.indices)
        
        XCTAssertEqual(firstLevelReply.id, tree.at(index: 1)?.id)
    }
}
