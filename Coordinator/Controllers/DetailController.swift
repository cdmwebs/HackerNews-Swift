//
//  DetailController.swift
//  Coordinator
//
//  Created by Chris Moore on 4/10/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

class DetailController: UIViewController {
    private let commentCellIdentifier = "CommentCell"
    
    var story: Story?
    var comments: [Comment] = []

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        let nib = UINib.init(nibName: commentCellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: commentCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TitleCell")
    }
    
    func setStory(_ story:Story) {
        self.story = story
        self.comments = []
    }
    
    func setComments(_ comments:[Comment]){
        self.comments = comments
        refreshComments()
    }
    
    func addComment(_ comment: Comment) {
        comments.append(comment)
    }
    
    func refreshComments() {
        print("refreshing comments: \(comments.count) comments")
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func formattedText(_ text: String) -> NSAttributedString {
        var attributedText: NSAttributedString?
        
        let formattedBody = String(format: "<style>body { font-family: '-apple-system', 'HelveticaNeue'; font-size: \(UIFont.systemFontSize) }</style><body><span>%@</span></body>", text)

        attributedText = try? NSAttributedString(
            data: formattedBody.data(using: .utf8, allowLossyConversion: false)!,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        
        guard attributedText != nil else { return NSAttributedString() }
        return attributedText!
    }
}

extension DetailController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return story?.text != "" ? 2 : 1
        } else {
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Story"
        } else {
            return "Comments"
        }
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return indexPath.section * 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell")!
            cell.textLabel?.numberOfLines = 0

            if indexPath.row == 0 {
                cell.textLabel?.text = story?.title ?? "Title"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            } else {
                cell.textLabel?.attributedText = formattedText(story?.text ?? "")
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellIdentifier) as! CommentCell
        let comment = comments[indexPath.row]
        
        cell.commentLabel.attributedText = formattedText(comment.text)
        cell.commentIdLabel.text = "\(comment.id)"
        cell.parentLabel.text = "\(comment.parent)"
        
        return cell
    }
}
