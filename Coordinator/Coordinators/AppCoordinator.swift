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
    
    let barTintColor: UIColor = UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 1.0)
    let barTextColor: UIColor = .white
    
    func start() {
        let vc = ItemsController()
        vc.delegate = self
        
        navController = UINavigationController(rootViewController: vc)
        navController?.navigationBar.barTintColor = barTintColor
        navController?.navigationBar.tintColor = barTextColor
        navController?.navigationBar.titleTextAttributes = [
            .foregroundColor: barTextColor
        ]
    }
    
    func loadStory(story: Story) {
        let url = URL(string: story.url)!
        let vc = SFSafariViewController(url: url)
        navController?.present(vc, animated: true, completion: nil)
        vc.preferredBarTintColor = barTintColor
        vc.preferredControlTintColor = barTextColor
    }
    
    func loadComments(story: Story) {
        let url = URL(string: "https://news.ycombinator.com/item?id=\(story.id)")!
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
