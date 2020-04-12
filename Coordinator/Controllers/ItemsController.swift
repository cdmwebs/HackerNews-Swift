//
//  ViewController.swift
//  Coordinator
//
//  Created by Chris Moore on 4/8/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

protocol ItemsControllerDelegate : class {
    func loadStory(story: Story)
    func loadComments(story: Story)
}

class ItemsController: UIViewController {
    weak var itemsDelegate: AppCoordinator?
    
    var stories: [Story] = []
    var collapseDetailViewController: Bool = true
    
    private var tableView: UITableView = UITableView()
    private let cellIdentifier = "StoryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Hacker News"
        self.view.backgroundColor = .white
        
        setupTableView()
    }
    
    func setStories(stories: [Story]) {
        self.stories = stories
        tableView.reloadData()
    }
    
    func addStory(_ story: Story) {
        if let storyIndex = stories.firstIndex(where: { $0.id == story.id }) {
            stories[storyIndex] = story
            print("updated:", story.title)
            tableView.performBatchUpdates({
                tableView.reloadRows(at: [IndexPath(row: storyIndex, section: 0)], with: .left)
            }, completion: nil)
        } else {
            stories.append(story)
            print("added:", story.title)
            tableView.performBatchUpdates({
                tableView.insertRows(at: [IndexPath(row: stories.count - 1, section: 0)], with: .automatic)
            }, completion: nil)
        }
    }
    
    func updateStory(_ story: Story) {
        guard let storyIndex = self.stories.firstIndex(where: { $0.id == story.id }) else { return }
        stories[storyIndex] = story
        
        tableView.reloadRows(at: [IndexPath(row: storyIndex, section: 0)], with: .automatic)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
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
}

extension ItemsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowNumber = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StoryCell
        cell.story = stories[rowNumber]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = self.stories[indexPath.row]
        self.collapseDetailViewController = false
        itemsDelegate?.loadComments(story: story)
    }
}
