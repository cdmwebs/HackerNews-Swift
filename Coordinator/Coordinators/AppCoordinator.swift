//
//  AppCoordinator.swift
//  Coordinator
//
//  Created by Chris Moore on 4/8/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit
import Firebase
import SafariServices

enum StoryType: String {
    case top = "topstories"
    case ask = "askstories"
    case new = "newstories"
    case best = "beststories"
    case show = "showstories"
    case job = "jobstories"
}

class AppCoordinator {
    private var databaseURL = "https://hacker-news.firebaseio.com/"
    private var database: DatabaseReference!
    
    var splitController: UISplitViewController?
    private var masterNavController: UINavigationController?
    private var detailNavController: UINavigationController?
    private var detailController: DetailController?
    private var itemsController: ItemsController?
    private var collapseDetailViewController: Bool = true
    
    let barTintColor: UIColor = UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 1.0)
    let barTextColor: UIColor = .white
    
    func start() {
        setupFirebase()
        //startObservingDatabase(type: .top)
        
        itemsController = ItemsController()
        itemsController?.itemsDelegate = self
        
        masterNavController = UINavigationController(rootViewController: itemsController!)
        masterNavController?.navigationBar.barTintColor = barTintColor
        masterNavController?.navigationBar.tintColor = barTextColor
        masterNavController?.navigationBar.titleTextAttributes = [
            .foregroundColor: barTextColor
        ]
        
        detailController = DetailController()
        detailController?.title = "Detail"
        
        detailNavController = UINavigationController(rootViewController: detailController!)
        detailNavController?.navigationBar.barTintColor = barTintColor
        detailNavController?.navigationBar.tintColor = barTextColor
        detailNavController?.navigationBar.titleTextAttributes = [
            .foregroundColor: barTextColor
        ]
        
        splitController = UISplitViewController()
        splitController?.delegate = self
        splitController?.preferredDisplayMode = .allVisible
        detailController?.navigationItem.leftBarButtonItem = splitController?.displayModeButtonItem
        detailController?.navigationItem.leftItemsSupplementBackButton = true
        splitController?.maximumPrimaryColumnWidth = CGFloat(splitController?.view.bounds.size.width ?? 250)
        splitController?.preferredPrimaryColumnWidthFraction = 0.35
        splitController!.viewControllers = [masterNavController!, detailNavController!]
        
        DispatchQueue.global(qos: .background).async {
            self.loadInitialItems()
        }
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
        database = Database.database(url: databaseURL).reference(withPath: "v0")
    }
    
    // MARK: - Network Requests

    private func loadInitialItems(type: StoryType = .top) {
        let topStoriesRef = database.child(type.rawValue)
        let itemsRef = database.child("item")
        
        topStoriesRef.observe(.value, with: { (snapshot) in
            // This returns the n top story IDs
            // Let's convert that in to an array and query for these item IDs.
            let postIds = snapshot.value as? [Int] ?? []
            
            for (index, postId) in postIds.enumerated() {
                if index >= 49 { break }
                
                itemsRef.child(String(postId)).observe(.value, with: { (storySnapshot) in
                    let story = Story(snapshot: storySnapshot)
                    
                    DispatchQueue.main.async {
                        self.itemsController?.addStory(story)
                    }
                })
            }
            
            topStoriesRef.removeAllObservers()
        })
    }
    
    private func startObservingDatabase(type: StoryType = .top) {
        let topStoriesRef = database.child(type.rawValue)

        topStoriesRef.observe(.childAdded, with: { (snapshot) in
            guard let storyId = snapshot.value as? Int else { return }
            let storyPath = String(storyId)
            
            self.database.child("item").child(storyPath).observeSingleEvent(of: .value, with: { (storySnapshot) in
                let story = Story(snapshot: storySnapshot)
                self.itemsController?.addStory(story)
            })
        })
        
        topStoriesRef.observe(.childChanged, with: { (snapshot) in
            guard let storyId = snapshot.value as? Int else { return }
            let storyPath = String(storyId)
            
            self.database.child("item").child(storyPath).observeSingleEvent(of: .value, with: { (storySnapshot) in
                let story = Story(snapshot: storySnapshot)
                self.itemsController?.updateStory(story)
            })
        })
    }
    
    private func fetchComments(commentIds: [Int]) {
        for commentId in commentIds {
            self.database.child("item").child("\(commentId)").observeSingleEvent(of: .value, with: { (commentSnapshot) in
                let comment = Comment(snapshot: commentSnapshot)
                self.fetchComments(commentIds: comment.replies.map { $0.id })
                self.detailController?.addComment(comment)
            })
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        database.child("topstories").removeAllObservers()
    }
}

extension AppCoordinator: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let navigationController = primaryViewController as? UINavigationController,
            let controller = navigationController.topViewController as? ItemsController
        else {
            return true
        }

        return controller.collapseDetailViewController
    }
}

extension AppCoordinator: ItemsControllerDelegate {
    func loadStory(story: Story) {}
    
    func loadComments(story: Story) {
        detailController?.setStory(story)
        DispatchQueue.global(qos: .background).async {
            self.fetchComments(commentIds: story.comments.map { $0.id })
        }
        
        if splitController?.isCollapsed == true {
            splitController?.showDetailViewController(detailController!, sender: self)
        }
    }
}

