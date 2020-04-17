//
//  DetailController.swift
//  Coordinator
//
//  Created by Chris Moore on 4/10/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import SafariServices
import UIKit

class DetailController: UIViewController {
    private let commentCellIdentifier = "CommentCell"
    private let headerCellIdentifier = "StoryCell"
    private var isLoadingComments: Bool = true
    
    var story: HNStory?
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        configureTableview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: .commentAdded, object: nil)
    }
    
    func configureTableview() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        let headerNib = UINib(nibName: headerCellIdentifier, bundle: nil)
        tableView.register(headerNib, forCellReuseIdentifier: headerCellIdentifier)
        
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(loadingNib, forCellReuseIdentifier: "LoadingCell")
        
        let commentNib = UINib(nibName: commentCellIdentifier, bundle: nil)
        tableView.register(commentNib, forCellReuseIdentifier: commentCellIdentifier)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(reloadTableManually), for: .valueChanged)
    }
    
    func setStory(_ story: HNStory) {
        if story.id != self.story?.id {
            isLoadingComments = true
            self.story = story
            tableView?.reloadData()
        }
    }
    
    @objc func reloadTable(notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.isLoadingComments = false
        }
    }
    
    @objc func reloadTableManually() {
        tableView.refreshControl?.endRefreshing()
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self, name: .commentAdded, object: nil)
    }
}

extension DetailController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return isLoadingComments ? 1 : (story?.comments.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && !isLoadingComments {
            let cell = cell as! CommentCell
            cell.leadingConstraint.constant = CGFloat(cell.comment?.depth ?? 0) * 12
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Comments" : ""
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as! StoryCell
            guard let story = story else { return cell }
            cell.showText = true
            cell.onLinkTapped = self.handleURL
            cell.titleLabel.isUserInteractionEnabled = true
            cell.story = story
            return cell
        default:
            if isLoadingComments {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingCell
                cell.activityIndicator.startAnimating()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: commentCellIdentifier) as! CommentCell
                guard let comment = story?.comments[indexPath.row] else { return cell }
                
                cell.comment = comment
                cell.onLinkTapped = self.handleURL
                return cell
            }
        }
    }
}

extension DetailController {
    func handleURL(_ url: URL) {
        let webViewController = SFSafariViewController.init(url: url)
        self.present(webViewController, animated: true, completion: nil)
    }
}
