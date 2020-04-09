//
//  ViewController.swift
//  Coordinator
//
//  Created by Chris Moore on 4/8/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

class ItemsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: ItemsControllerDelegate?
    var stories: [Story] = []
    private var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "List of Stuff"
        self.view.backgroundColor = .white
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.allowsSelection = false
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60
        tableView?.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView!)
        
        tableView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowNumber = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.story = stories[rowNumber]
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stories.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension ItemsController: TableViewCellDelegate {
    func storyTapped(story: Story) {
        delegate?.loadStory(story: story)
    }
    
    func commentsTapped(story: Story) {
        delegate?.loadComments(story: story)
    }
}
