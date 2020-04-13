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
    private let headerCellIdentifier = "StoryCell"
    
    var story: Story?
    var comments: [Comment] = []
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        configureTableview()
    }
    
    func configureTableview() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        let headerNib = UINib.init(nibName: headerCellIdentifier, bundle: nil)
        tableView.register(headerNib, forCellReuseIdentifier: headerCellIdentifier)
    }
    
    func setStory(_ story:Story) {
        if story.id != self.story?.id {
            self.story = story
            self.comments = story.comments
            self.tableView?.reloadData()
        }
    }
    
    func setComments(_ comments: [Comment]) {
        self.comments.removeAll()
        tableView.reloadData()
        
        for comment in comments {
            addComment(comment)
        }
        
        DispatchQueue.main.async {
            print("reloading table data:", comments.count)
            self.tableView.reloadData()
        }
    }
    
    func addComments(_ comments: [Comment]) {
        for comment in comments {
            addComment(comment)
        }
        
        if comments.count > 0 {
            print("added comments:", comments.count)
            tableView.reloadData()
        }
    }
    
    func addComment(_ comment: Comment) {
        var commentIndex: Int?
        
        if isParentComment(comment) {
            comment.position = 0
            commentIndex = comments.firstIndex(where: { $0.id == comment.id })
            story?.comments.append(comment)
            if commentIndex != nil {
                comments[commentIndex!] = comment
            }
        } else if comment.parent != nil {
            var inserted = false
            
            if let parentIndex = comments.firstIndex(where: { $0.id == comment.parent }) {
                let parent = comments[parentIndex]
                comment.position = parent.position + 1
                parent.add(reply: comment)
                
                if parentIndex < comments.count - 1 {
                    for n in (parentIndex + 1)...(comments.count - 1) {
                        if comments[n].position <= parent.position {
                            comments.insert(comment, at: n)
                            commentIndex = n
                            inserted = true
                            break
                        }
                    }
                }
            }
            
            if !inserted {
                comments.append(comment)
                commentIndex = comments.endIndex
                inserted = true
            }
        }
    }
    
    private func isParentComment(_ comment: Comment) -> Bool {
        return story?.id == comment.parent
    }
    
    private func allCommentsCount() -> Int {
        return comments.compactMap { $0.allIds }.count
    }
}

extension DetailController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : allCommentsCount()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Comments" : ""
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        guard indexPath.section == 1 else { return 0 }
        
        let comment = comments[indexPath.row]
        return comment.position
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as! StoryCell
            guard let story = story else { return cell }
            
            cell.story = story
            cell.commentCount = allCommentsCount()
            cell.showText = true
            cell.bodyLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellIdentifier) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: commentCellIdentifier)
        
        let comment = comments[indexPath.row]
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.month, .day, .hour, .minute]
        dateFormatter.unitsStyle = .abbreviated
        let postedAgo = Date(timeIntervalSince1970: comment.timestamp).distance(to: Date())
        let formattedAgo = dateFormatter.string(from: postedAgo)
        
        cell.textLabel?.attributedText = formattedText(comment.text)
        cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "- posted by \(String(describing: comment.by)) \(String(formattedAgo!)) ago"
        cell.indentationWidth = 20
        return cell
    }
    
    func formattedText(_ text: String) -> NSAttributedString {
        let formattedBody = String(
            format: "<style>body { font-family: '-apple-system', 'HelveticaNeue'; font-size: \(UIFont.systemFontSize) }</style><body><span>%@</span></body>",
            text
        )
        
        let attributedText = try? NSMutableAttributedString(
            data: formattedBody.data(using: .utf8, allowLossyConversion: false)!,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue,
            ],
            documentAttributes: nil)
        
        let additionalAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label
        ]
        let range = NSRange(location: 0, length: attributedText?.length ?? 0)
        
        attributedText?.addAttributes(additionalAttributes, range: range)
        
        return attributedText ?? NSAttributedString()
    }
}
