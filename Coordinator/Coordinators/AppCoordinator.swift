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
        startObservingDatabase(type: "askstories")
        
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

    private func startObservingDatabase(type: String = "topstories") {
        let topStoriesRef = database.child(type)

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
        detailController?.setStory(story)
        fetchComments(commentIds: story.kids)
        
        if splitController?.isCollapsed == true {
            splitController?.showDetailViewController(detailController!, sender: self)
            DispatchQueue.main.async {
                self.detailController?.tableView.setContentOffset(.zero, animated: true)
                self.detailController?.tableView.reloadData()
             }
        }
        
        self.commentsGroup.notify(queue: .main) {
            self.detailController?.refreshComments()
        }
    }
}

