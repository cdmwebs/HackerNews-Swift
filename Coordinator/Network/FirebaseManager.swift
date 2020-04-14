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

class FirebaseManager {
    private var database: Database?
    private var databaseRef: DatabaseReference?
    private var itemRef: DatabaseReference?
    private var commentHandles: [UInt] = []
    
    private let itemKey: String = "item"
    private var storyType: StoryType = .TopStories
    
    init() {
        configureDatabase()
        startListening()
    }
    
    // MARK: - Observers
    
    func startListening() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(startWatchingStory(_:)),
            name: .startWatchingStory,
            object: nil
        )
    }
    
    // MARK: - Network Requests
    
    private func configureDatabase() {
        database = Database.database(url: "https://hacker-news.firebaseio.com/")
        database?.isPersistenceEnabled = true
        databaseRef = database?.reference(withPath: "v0")
        
        itemRef = databaseRef?.child("item")
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
    
    
    @objc func startWatchingStory(_ notification:Notification) {
        guard let dict = notification.userInfo as? [String:Story],
            let story = dict["story"] else { return }

        for handle in commentHandles {
            itemRef?.removeObserver(withHandle: handle)
            
            if let index = commentHandles.firstIndex(of: handle) {
                commentHandles.remove(at: index)
            }
        }
        
        for comment in story.commentTree.comments {
            watchComment(comment)
        }
    }
    
    func watchComment(_ comment: Comment) {
        let commentHandle = itemRef?.child("\(comment.id)").observe(.value, with: { (commentSnapshot) in
            let comment = Comment(snapshot: commentSnapshot)
            NotificationCenter.default.post(name: .commentAdded, object: nil, userInfo: ["comment": comment])
            
            for comment in comment.replies {
                self.watchComment(comment)
            }
         })
        
        if commentHandle != nil {
            self.commentHandles.append(commentHandle!)
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
                NotificationCenter.default.post(name: .storyAdded, object: self, userInfo: ["story": story])
            })
        })
        
        topStoriesRef.queryLimited(toFirst: 50).observe(.childChanged, with: { snapshot in
            guard let storyId = snapshot.value as? Int else { return }
            let storyPath = String(storyId)
            
            self.databaseRef?.child(self.itemKey).child(storyPath).observeSingleEvent(of: .value, with: { storySnapshot in
                let story = Story(snapshot: storySnapshot)
                NotificationCenter.default.post(name: .storyUpdated, object: self, userInfo: ["story": story])
            })
        })
    }
    
    // MARK: - Cleanup
    
    deinit {
        databaseRef?.child(storyType.rawValue).removeAllObservers()
        NotificationCenter.default.removeObserver(self, name: .startWatchingStory, object: nil)
    }
}

extension Notification.Name {
    static let storyAdded = Notification.Name("storyAdded")
    static let storyUpdated = Notification.Name("storyUpdated")
    static let startWatchingStory = Notification.Name("startWatchingStory")

    static let commentAdded = Notification.Name("commentAdded")
}
