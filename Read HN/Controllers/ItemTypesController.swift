//
//  ItemTypesController.swift
//  Coordinator
//
//  Created by Chris Moore on 4/17/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

protocol ItemTypesControllerDelegate {
    func storyTypeWasSelected(_ storyType: HNStoryType)
}
class ItemTypesController: UITableViewController {
    weak var delegate: AppCoordinator?
    private var cellIdentifier = "StoryTypeCell"
    
    var dataSource = HNStoryType.allCases
    
    override func viewDidLoad() {
        self.title = "Hacker News"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].description

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyType = dataSource[indexPath.row]
        delegate?.storyTypeWasSelected(storyType.self)
    }
}
