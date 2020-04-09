//
//  AppCoordinator.swift
//  Coordinator
//
//  Created by Chris Moore on 4/8/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit
import SafariServices

class AppCoordinator: ItemsControllerDelegate {
    var navController: UINavigationController?
    var stories: [Story] = [
        Story(ID: 1, commentsCount: 255, domain: "www.example.com", title: "Example"),
        Story(ID: 2, commentsCount: 25, domain: "www.duckduckgo.com", title: "Duck Duck Go"),
        Story(ID: 3, commentsCount: 1255, domain: "www.knowndecimal.com", title: "Known Decimal"),
        Story(ID: 4, commentsCount: 55, domain: "www.homebuyer.ai", title: "Homebuyer"),
        Story(ID: 5, commentsCount: 5, domain: "news.ycombinator.com", title: "Hacker News"),
    ]
    
    let barTintColor: UIColor = UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 1.0)
    let barTextColor: UIColor = .white
    
    func start() {
        let vc = ItemsController()
        vc.delegate = self
        vc.stories = stories
        
        navController = UINavigationController(rootViewController: vc)
        navController?.navigationBar.barTintColor = barTintColor
        navController?.navigationBar.tintColor = barTextColor
        navController?.navigationBar.titleTextAttributes = [
            .foregroundColor: barTextColor
        ]
    }
    
    func loadStory(story: Story) {
        let url = URL(string: "https://\(story.domain)")!
        let vc = SFSafariViewController(url: url)
        navController?.present(vc, animated: true, completion: nil)
        vc.preferredBarTintColor = barTintColor
        vc.preferredControlTintColor = barTextColor
    }
    
    func loadComments(story: Story) {
        let url = URL(string: "https://news.ycombinator.com/item?id=22814860")!
        let vc = SFSafariViewController(url: url)
        navController?.present(vc, animated: true, completion: nil)
        vc.preferredBarTintColor = barTintColor
        vc.preferredControlTintColor = barTextColor
    }
}

protocol ItemsControllerDelegate : class {
    func loadStory(story: Story)
    func loadComments(story: Story)
}
