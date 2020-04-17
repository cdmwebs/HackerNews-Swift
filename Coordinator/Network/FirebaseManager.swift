//
//  FirebaseManager.swift
//  Coordinator
//
//  Created by Chris Moore on 4/13/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import FirebaseDatabase
import Foundation

extension Notification.Name {
    static let storyAdded = Notification.Name("storyAdded")
    static let commentAdded = Notification.Name("commentAdded")
}

class FirebaseManager {
    var allStories: [HNStory] = []
    
    private var database: Database?
    private var databaseRef: DatabaseReference?
    private var itemRef: DatabaseReference?
    private var commentHandles: [UInt] = []
    private let decoder = JSONDecoder()
    
    private let itemKey: String = "item"
    var storyType: HNStoryType = .TopStories
    
    var stories: [HNStory] {
        get {
            allStories.filter { $0.storyType == storyType }
        }
    }
    
    init() {        
        configureDatabase()
    }
    
    // MARK: - Configuration
    
    private func configureDatabase() {
        database = Database.database(url: "https://hacker-news.firebaseio.com/")
        database?.isPersistenceEnabled = true
        databaseRef = database?.reference(withPath: "v0")
        
        itemRef = databaseRef?.child(itemKey)
    }
    
    // MARK: - Storage
    
    private func addStory(_ story:HNStory) {
        if let storyIndex = self.allStories.firstIndex(where: { $0.id == story.id }) {
            let existingComments = self.allStories[storyIndex].allComments
            self.allStories[storyIndex] = story
            self.allStories[storyIndex].allComments = existingComments
        } else {
            self.allStories.append(story)
        }
    }
    
    // MARK: - Observers
    
    func loadStories(type: HNStoryType = .TopStories, limit:UInt = 50, start:UInt = 0) {
        DispatchQueue.global().async {
            let storiesRef = self.databaseRef?.child(type.rawValue)
            let query = storiesRef?.queryLimited(toFirst: limit)
            let group = DispatchGroup()
            
            let itemHandler = { (itemSnapshot: DataSnapshot) -> Void in
                guard let data = itemSnapshot.data else { return }
                let story = try! self.decoder.decode(HNStory.self, from: data)
                story.storyType = type
                self.addStory(story)
                group.leave()
            }
            
            query?.observe(.value, with: { itemsSnapshot in
                let itemIds = itemsSnapshot.value as! [Int]
                
                for itemId in itemIds {
                    group.enter()
                    let itemPath = String(itemId)
                    
                    self.itemRef?.child(itemPath).observeSingleEvent(of: .value, with: itemHandler)
                }
                
                group.notify(queue: .main) {
                    NotificationCenter.default.post(name: .storyAdded, object: self)
                }
            })
        }
    }
    
    func loadComments(item: HNItem, story: HNStory, depth: Int = 0, group: DispatchGroup = DispatchGroup()) {
        let itemRef = self.databaseRef?.child(self.itemKey)
        
        let commentHandler = { (commentSnapshot: DataSnapshot) -> Void in
            guard let data = commentSnapshot.data else { return }
            let comment = try! self.decoder.decode(HNComment.self, from: data)
            story.addComment(comment, depth: depth)
            
            if (comment.kids?.count ?? 0) > 0 {
                self.loadComments(item: comment, story: story, depth: depth + 1, group: group)
            }
            
            group.leave()
        }
        
        if item.kids != nil {
            for itemId in item.kids! {
                group.enter()
                let itemPath = String(itemId)
                let query = itemRef?.child(itemPath)
                
                query?.observeSingleEvent(of: .value, with: commentHandler)
            }
        }
        
        group.notify(queue: .main) {
            NotificationCenter.default.post(name: .commentAdded, object: self)
        }
    }

    // MARK: - Cleanup
    
    deinit {
        databaseRef?.child(storyType.rawValue).removeAllObservers()
    }
}

extension DataSnapshot {
    var data: Data? {
        guard let value = value, !(value is NSNull) else { return nil }
        return try? JSONSerialization.data(withJSONObject: value)
    }
    
    var json: String? {
        return data?.string
    }
}

extension Data {
    var string: String? {
        return String(data: self, encoding: .utf8)
    }
}
