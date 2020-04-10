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

class AppCoordinator {
    private var databaseURL = "https://hacker-news.firebaseio.com/"
    private var database: DatabaseReference!
    private var commentsGroup = DispatchGroup()
    private var storiesGroup = DispatchGroup()
    
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
        startObservingDatabase()
        
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
        splitController?.preferredDisplayMode = .automatic
        splitController!.viewControllers = [masterNavController!, detailNavController!]
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
        database = Database.database(url: databaseURL).reference(withPath: "v0")
    }
    
    // MARK: - Network Requests

    private func startObservingDatabase() {
        let topStoriesRef = database.child("topstories")

        topStoriesRef.observe(.childAdded, with: { (snapshot) in
            self.storiesGroup.enter()
            self.fetchStory(snapshot: snapshot, event: "added")
            
            self.storiesGroup.notify(queue: .main) {
                print("stories fetched. reloading.")
                self.itemsController?.tableView.reloadData()
            }
        })
        
        topStoriesRef.observe(.childChanged, with: { (snapshot) in
            self.fetchStory(snapshot: snapshot, event: "changed")
        })
    }
    
    private func fetchStory(snapshot: DataSnapshot, event: String) {
        let storyId = snapshot.value as! Int
        
        self.database.child("item").child("\(storyId)").observeSingleEvent(of: .value, with: { (storySnapshot) in
            let story = Story(snapshot: storySnapshot)
            
            if event == "added" {
                self.itemsController?.addStory(story)
                self.storiesGroup.leave()
            } else {
                self.itemsController?.updateStory(story)
            }
        })
    }
    
    private func fetchComments(commentIds: [Int]) {
        commentsGroup.enter()
        for commentId in commentIds {
            commentsGroup.enter()
            self.database.child("item").child("\(commentId)").observeSingleEvent(of: .value, with: { (commentSnapshot) in
                let comment = Comment(snapshot: commentSnapshot)
                self.fetchComments(commentIds: comment.kids)
                self.detailController?.addComment(comment)
                self.commentsGroup.leave()
            })
        }
        
        commentsGroup.leave()
    }
    
    // MARK: - Cleanup
    
    deinit {
        database.child("topstories").removeAllObservers()
    }
}

extension AppCoordinator: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension AppCoordinator: ItemsControllerDelegate {
    func loadStory(story: Story) {}
    
    func loadComments(story: Story) {
        fetchComments(commentIds: story.kids)
        detailController?.setStory(story)
        
        if splitController?.isCollapsed == true {
            splitController?.showDetailViewController(detailController!, sender: self)
        }
        
        self.commentsGroup.notify(queue: .main) {
            self.detailController?.refreshComments()
        }
    }
}

protocol ItemsControllerDelegate : class {
    func loadStory(story: Story)
    func loadComments(story: Story)
}
