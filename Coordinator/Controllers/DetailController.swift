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
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        configureTableview()
        NotificationCenter.default.addObserver(self, selector: #selector(onCommentAdded(_:)), name: .commentAdded, object: nil)
    }
    
    func configureTableview() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        let headerNib = UINib(nibName: headerCellIdentifier, bundle: nil)
        tableView.register(headerNib, forCellReuseIdentifier: headerCellIdentifier)
    }
    
    func setStory(_ story: Story) {
        if story.id != self.story?.id {
            self.story = story
            tableView?.reloadData()
        }
    }
    
    @objc func onCommentAdded(_ notification: Notification) {
        guard let dict = notification.userInfo as? [String:Comment],
            let comment = dict["comment"] else { return }

            self.story?.commentTree.addComment(comment)
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
        return section == 0 ? 1 : (story?.totalCommentCount ?? 0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Comments" : ""
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        switch indexPath.section {
            case 0: return 0
            default:
                guard let story = story,
                      let comment = story.commentTree.at(index: indexPath.row) else { return 0 }
                return comment.depth
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) as! StoryCell
            guard let story = story else { return cell }
            
            cell.story = story
            cell.commentCount = story.totalCommentCount
            cell.showText = true
            cell.bodyLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellIdentifier) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: commentCellIdentifier)
        
        guard let comment = story?.commentTree.at(index: indexPath.row) else { return cell }
        
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
            documentAttributes: nil
        )
        
        let additionalAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label,
        ]
        let range = NSRange(location: 0, length: attributedText?.length ?? 0)
        
        attributedText?.addAttributes(additionalAttributes, range: range)
        
        return attributedText ?? NSAttributedString()
    }
}
