//
//  AppCoordinator.swift
//  Coordinator
//
//  Created by Chris Moore on 4/8/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import SafariServices
import UIKit

class AppCoordinator {
    private let firebaseManager = FirebaseManager()
    private var storyType: StoryType = .AskHN
    
    var splitController: UISplitViewController?
    
    private var masterNavController: UINavigationController?
    private var itemsController: ItemsController?
    private var detailNavController: UINavigationController?
    private var detailController: DetailController?
    private var collapseDetailViewController: Bool = true
    
    let barTintColor: UIColor = UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 1.0)
    let barTextColor: UIColor = .white
    
    func start() {
        startListening()
        configureDetailController()
        configureMasterController()
        configureSplitViewController()
    }
    
    private func startListening() {
        firebaseManager.delegate = self
        
        DispatchQueue.global(qos: .background).async {
            self.firebaseManager.startObservingDatabase()
        }
    }
    
    private func configureDetailController() {
        detailController = DetailController()
        detailController?.title = "Detail"
        
        detailNavController = UINavigationController(rootViewController: detailController!)
        detailNavController?.navigationBar.barTintColor = barTintColor
        detailNavController?.navigationBar.tintColor = barTextColor
        detailNavController?.navigationBar.titleTextAttributes = [
            .foregroundColor: barTextColor
        ]
    }
    
    private func configureMasterController() {
        itemsController = ItemsController()
        itemsController?.itemsDelegate = self
        
        masterNavController = UINavigationController(rootViewController: itemsController!)
        masterNavController?.navigationBar.barTintColor = barTintColor
        masterNavController?.navigationBar.tintColor = barTextColor
        masterNavController?.navigationBar.titleTextAttributes = [
            .foregroundColor: barTextColor
        ]
    }
    
    private func configureSplitViewController() {
        splitController = UISplitViewController()
        splitController?.delegate = self
        splitController?.preferredDisplayMode = .allVisible
        
        detailController?.navigationItem.leftBarButtonItem = splitController?.displayModeButtonItem
        detailController?.navigationItem.leftItemsSupplementBackButton = true
        
        splitController?.maximumPrimaryColumnWidth = CGFloat(splitController?.view.bounds.size.width ?? 250)
        splitController?.preferredPrimaryColumnWidthFraction = 0.35
        splitController!.viewControllers = [masterNavController!, detailNavController!]
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
        if detailController?.story?.id != story.id {
            detailController?.setStory(story)
            
            DispatchQueue.global(qos: .background).async {
                let commentIds = story.commentTree.comments.map { $0.id }
                self.firebaseManager.fetchComments(commentIds: commentIds)
            }
        }
        
        if splitController?.isCollapsed == true {
            splitController?.showDetailViewController(detailController!, sender: self)
        }
    }
}

extension AppCoordinator: FirebaseDelegate {
    func onStoryAdded(_ story: Story) {
        itemsController?.addStory(story)
    }

    func onStoryUpdated(_ story: Story) {
        itemsController?.updateStory(story)
    }
    
    func onCommentAdded(_ comment: Comment) {
        let newCommentIndex = detailController?.story?.commentTree.addComment(comment)
        print("adding", comment.id)
        detailController?.addComment(comment, at: newCommentIndex)
    }
    
    func onCommentUpdated(_ comment: Comment) {
        
    }
    
    func onInitialCommentLoad(comments: [Comment]) {
        // detailController?.setComments(comments)
    }
}
