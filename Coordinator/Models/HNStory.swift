//
//  HNStory.swift
//  Coordinator
//
//  Created by Chris Moore on 4/16/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation

enum HNStoryType: String, CaseIterable, CustomStringConvertible {
    case TopStories = "topstories"
    case AskHN = "askstories"
    case NewStories = "newstories"
    case BestStories = "beststories"
    case ShowHN = "showstories"
    case Jobs = "jobstories"
    
    var description: String {
        switch self {
        case .TopStories: return "Top Stories"
        case .AskHN: return "Ask HN"
        case .NewStories: return "New Stories"
        case .BestStories: return "Best Stories"
        case .ShowHN: return "Show HN"
        case .Jobs: return "Jobs"
        }
    }
}

class HNStory: HNItem {
    var storyType: HNStoryType = .TopStories
    var allComments: [HNComment] = []
    
    var comments: [HNComment] {
        allComments.filter { $0.isDeleted == false }
    }
    
    var domain: String {
        return url?.host ?? ""
    }
    
    func addComment(_ comment: HNComment, depth: Int? = 1) {
        if comment.parent == id {
            // This is a root level comment
            allComments.append(comment)
        } else {
            let parentIndex = allComments.firstIndex(where: { $0.id == comment.parent })
            var commentIndex = allComments.firstIndex(where: { $0.id == comment.id })
            
            if parentIndex != nil && commentIndex == nil {
                let siblingIndex = allComments.firstIndex { $0.parent == comment.parent }
                
                if siblingIndex != nil {
                    commentIndex = siblingIndex! + 1
                } else {
                    commentIndex = parentIndex! + 1
                }
                
                comment.depth = depth ?? 0
                allComments.insert(comment, at: commentIndex!)
            } else if commentIndex != nil {
                allComments[commentIndex!] = comment
            } else if parentIndex == nil {
                allComments.append(comment)
            } else {
                print("not added")
            }
        }
    }
}
