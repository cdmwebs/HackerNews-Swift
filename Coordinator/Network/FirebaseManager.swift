//
//  FirebaseManager.swift
//  Coordinator
//
//  Created by Chris Moore on 4/13/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Firebase
import Foundation

enum StoryType: String, CustomStringConvertible {
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

protocol FirebaseDelegate: class {
    func onStoryAdded(_ story: Story)
    func onStoryUpdated(_ story: Story)
    func onCommentAdded(_ comment: Comment)
    func onCommentUpdated(_ comment: Comment)
    func onInitialCommentLoad(comments: [Comment])
}

class FirebaseManager {
    private var database: Database?
    private var databaseRef: DatabaseReference?
    
    private let itemKey: String = "item"
    private var storyType: StoryType = .TopStories
    
    weak var delegate: FirebaseDelegate?
    
    init() {
        configureDatabase()
    }
    
    // MARK: - Network Requests
    
    private func configureDatabase() {
        database = Database.database(url: "https://hacker-news.firebaseio.com/")
        database?.isPersistenceEnabled = true
        databaseRef = database?.reference(withPath: "v0")
    }
    
    func loadInitialItems(type: StoryType = .TopStories) {
        guard let topStoriesRef = databaseRef?.child(type.rawValue) else { return }
        
        topStoriesRef.observe(.value, with: { snapshot in
            // This returns the n top story IDs
            // Let's convert that in to an array and query for these item IDs.
            let postIds = snapshot.value as? [Int] ?? []
            
            self.initialLoad(itemIds: postIds, completion: { snapshots, _ in
                for snapshot in snapshots {
                    let story = Story(snapshot: snapshot)
                    self.delegate?.onStoryAdded(story)
                }
            })
            
            topStoriesRef.removeAllObservers()
        })
    }
    
    func initialLoad(itemIds: [Int], limit: Int = 50, completion: @escaping ([DataSnapshot], Error?) -> Void) {
        guard let itemsRef = databaseRef?.child(itemKey) else { return }
        var tempItems = [DataSnapshot]()
        
        let queue = DispatchGroup()
        
        for (index, itemId) in itemIds.enumerated() {
            if index >= limit { break }
            
            queue.enter()
            
            itemsRef.child(String(itemId)).observeSingleEvent(of: .value, with: { snapshot in
                tempItems.append(snapshot)
                queue.leave()
            })
        }
        
        queue.notify(queue: .main) {
            completion(tempItems, nil)
        }
    }
    
    func fetchComments(commentIds: [Int]) {
        var replyIds = [Int]()
        
        initialLoad(itemIds: commentIds, limit: 250) { snapshots, _ in
            for snapshot in snapshots {
                let comment = Comment(snapshot: snapshot)
                replyIds.append(contentsOf: comment.replies.map { $0.id })
                self.delegate?.onCommentAdded(comment)
            }
            
            if replyIds.count > 0 {
                self.fetchComments(commentIds: replyIds)
            }
        }
    }
    
    // MARK: - Pending
    
    func startObservingDatabase(type: StoryType = .TopStories) {
        guard let topStoriesRef: DatabaseReference = databaseRef?.child(type.rawValue) else { return }
        
        topStoriesRef.queryLimited(toFirst: 50).observe(.childAdded, with: { snapshot in
            guard let storyId = snapshot.value as? Int else { return }
            let storyPath = String(storyId)
            
            self.databaseRef?.child(self.itemKey).child(storyPath).observeSingleEvent(of: .value, with: { storySnapshot in
                let story = Story(snapshot: storySnapshot)
                self.delegate?.onStoryAdded(story)
            })
        })
        
        topStoriesRef.queryLimited(toFirst: 50).observe(.childChanged, with: { snapshot in
            guard let storyId = snapshot.value as? Int else { return }
            let storyPath = String(storyId)
            
            self.databaseRef?.child(self.itemKey).child(storyPath).observeSingleEvent(of: .value, with: { storySnapshot in
                let story = Story(snapshot: storySnapshot)
                self.delegate?.onStoryUpdated(story)
            })
        })
    }
    
    // MARK: - Cleanup
    
    deinit {
        databaseRef?.child(storyType.rawValue).removeAllObservers()
    }
}
