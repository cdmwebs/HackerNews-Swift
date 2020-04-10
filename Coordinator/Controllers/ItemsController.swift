//
//  ViewController.swift
//  Coordinator
//
//  Created by Chris Moore on 4/8/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit
import Firebase

class ItemsController: UIViewController {
    weak var delegate: ItemsControllerDelegate?
    
    private var databaseURL =  "https://hacker-news.firebaseio.com/"
    private var database: DatabaseReference!
    private var databaseHandle: DatabaseHandle!
    private var concurrentQueue: DispatchQueue!
    
    private var stories: [Story] = []
    
    private var tableView: UITableView = UITableView()
    private let cellIdentifier = "StoryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Hacker News"
        self.view.backgroundColor = .white
        
        setupTableView()
        setupFirebase()
        startObservingDatabase()
    }
    
    private func setupFirebase() {
        database = Database.database(url: databaseURL).reference(withPath: "v0")
        concurrentQueue = DispatchQueue.init(label: "concurrentQueue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
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
    
    // MARK: - Network Requests

    func startObservingDatabase() {
        concurrentQueue.async {
            let query = self.database.child("topstories").queryLimited(toFirst: 50)
            
            self.databaseHandle = query.observe(.value, with: { (snapshot) in
                for child in snapshot.children {
                    let childSnapshot = child as! DataSnapshot
                    guard let storyId = childSnapshot.value as? Int else { return }
                    
                    self.database.child("item").child("\(storyId)").observeSingleEvent(of: .value, with: { (storySnapshot) in
                        let item = Story(snapshot: storySnapshot)
                        
                        if let storyIndex = self.stories.firstIndex(where: { $0.id == item.id }) {
                            self.stories[storyIndex] = item
                        } else {
                            self.stories.append(item)
                        }

                        self.tableView.reloadData()
                        self.title = "\(self.stories.count) Stories"
                    })
                }
            }) { (error) in
                print(error)
            }
        }
    }

    // MARK: - Cleanup

    deinit {
        database.child("topstories").removeObserver(withHandle: databaseHandle)
    }
}

extension ItemsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowNumber = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StoryCell
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

extension ItemsController: StoryCellDelegate {
    func storyTapped(story: Story) {
        delegate?.loadStory(story: story)
    }
    
    func commentsTapped(story: Story) {
        delegate?.loadComments(story: story)
    }
}
