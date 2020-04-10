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
        Story(ID: 1, commentsCount: 255, domain: "www.example.com", title: "Example of a really long, really boring title that should span multiple lines.", by: "cdmwebs", points: 122),
        Story(ID: 2, commentsCount: 25, domain: "www.duckduckgo.com", title: "Duck Duck Go", by: "anonymous", points: 1),
        Story(ID: 3, commentsCount: 125335, domain: "www.knowndecimal.com", title: "Known Decimal", by: "user321", points: 255),
        Story(ID: 4, commentsCount: 55, domain: "www.homebuyer.ai", title: "Homebuyer", by: "jack", points: 1250),
        Story(ID: 5, commentsCount: 5, domain: "news.ycombinator.com", title: "Hacker News", by: "patio11", points: 222),
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
