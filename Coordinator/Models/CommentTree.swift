//
//  CommentTree.swift
//  Coordinator
//
//  Created by Chris Moore on 4/14/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation

class CommentTree {
    var storyId: Int
    var comments: [Comment]
    
    init(comments: [Comment]) {
        if comments.count > 0 {
            self.storyId = comments[0].parent ?? 0
        } else {
            self.storyId = 0
        }
        
        self.comments = []
        
        for comment in comments {
            addComment(comment)
        }
    }
    
    func at(index: Int) -> Comment? {
        guard comments.indices.contains(index) else { return nil }
        return comments[index]
    }
    
    @discardableResult func addComment(_ comment: Comment) -> [Int?:String?] {
        guard comment.parent != nil else { return [:] }
        let parentIndex = comments.firstIndex(where: { $0.id == comment.parent })
        var commentIndex = comments.firstIndex(where: { $0.id == comment.id })
        var action = ""
        
        if comment.parent == storyId && commentIndex == nil {
            comment.depth = 0
            comments.append(comment)
            action = "add"
            commentIndex = comments.count - 1
        } else if comment.parent == storyId && commentIndex != nil {
            comments[commentIndex!] = comment
            action = "update"
        } else if parentIndex != nil && commentIndex == nil {
            let parent = comments[parentIndex!]
            
            // Get the position of the reply
            let offset = parent.replies.firstIndex(where: { $0.id == comment.id })
            
            if offset != nil {
                commentIndex = parentIndex! + (offset! + 1)
            } else {
                // Couldn't find it
                commentIndex = parentIndex! + 1
            }
            
            comment.depth = parent.depth + 1
            comments.insert(comment, at: commentIndex!)
            action = "add"
        } else if commentIndex != nil {
            comments[commentIndex!] = comment
            action = "update"
        }
        
        return [commentIndex:action]
    }
    
    private func nestComments(comments: [Comment], parentId: Int, level: Int = 0) -> [Comment] {
        let parents = comments.filter { $0.parent == parentId }
        
        return parents.map { (comment) -> Comment in
            let replies = nestComments(comments: self.comments, parentId: comment.id, level: level + 1)
            
            comment.depth = level
            comment.replies = replies

            return comment
        }
    }
}
