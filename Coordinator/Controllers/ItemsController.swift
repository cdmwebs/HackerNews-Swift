//
//  ViewController.swift
//  Coordinator
//
//  Created by Chris Moore on 4/8/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

protocol ItemsControllerDelegate : class {
    func loadComments(story: HNStory)
}

class ItemsController: UIViewController {
    weak var itemsDelegate: AppCoordinator?
    
    var dataSource: FirebaseManager?
    var collapseDetailViewController: Bool = true
    
    private var tableView: UITableView = UITableView()
    private let cellIdentifier = "StoryCell"
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\(dataSource?.stories.count ?? 0) Stories"
        self.view.backgroundColor = .white
        
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(addStory), name: .storyAdded, object: nil)
    }
    
    @objc func addStory(notification: NSNotification) {
        if let story = notification.userInfo as? [String:Int] {
            let storyId = story["storyId"]
            let storyIndex = dataSource?.stories.firstIndex { $0.id == storyId }
            
            tableView.insertRows(at: [IndexPath(row: storyIndex!, section: 0)], with: .automatic)
        } else {
            tableView.reloadData()
        }
        
        
    }
    
    @objc func reloadData() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        let nib = UINib.init(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .storyAdded, object: nil)
    }
}

extension ItemsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowNumber = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StoryCell
        
        cell.story = dataSource?.stories[rowNumber]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.stories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let story = dataSource?.stories[indexPath.row] {
            itemsDelegate?.loadComments(story: story)
            self.collapseDetailViewController = false
        }
    }
}
