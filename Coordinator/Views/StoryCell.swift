//
//  StoryCell.swift
//  Coordinator
//
//  Created by Chris Moore on 4/9/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

protocol StoryCellDelegate : class {
    func storyTapped(story: Story)
    func commentsTapped(story: Story)
}

class StoryCell: UITableViewCell {
    var delegate: StoryCellDelegate?
    
    var showText: Bool = false {
        didSet {
            guard showText == true  else { return }
            
            bodyLabel.attributedText = formattedText(story?.text ?? "")
        }
    }
    
    var commentCount: Int = 0 {
        didSet {
            let formattedCommentCount = NumberFormatter
                .localizedString(from: (commentCount) as NSNumber, number: .decimal)
            
            commentsCountLabel.text = formattedCommentCount
        }
    }
    
    var titleText: NSAttributedString {
        guard let story = story else { return NSAttributedString(string: "") }
        
        let quietAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .light),
            NSAttributedString.Key.foregroundColor: UIColor.systemGray2
        ]
        
        let title = NSMutableAttributedString(string: story.title)
        
        if !story.domain.isEmpty {
            let domain = NSAttributedString(string: " (\(story.domain))", attributes: quietAttributes)
            title.append(domain)
        }
        
        return title
    }
    
    var story: Story? {
        didSet {
            guard let story = story else { return }

            let formattedPoints = NumberFormatter
                .localizedString(from: (story.points) as NSNumber, number: .decimal)
            
            let formattedCommentCount = NumberFormatter
                .localizedString(from: (story.commentTree.comments.count) as NSNumber, number: .decimal)
            
            let dateFormatter = DateComponentsFormatter()
            dateFormatter.allowedUnits = [.month, .day, .hour, .minute]
            dateFormatter.unitsStyle = .abbreviated
            let postedAgo = Date(timeIntervalSince1970: story.timestamp).distance(to: Date())
            let formattedAgo = dateFormatter.string(from: postedAgo)
            
            titleLabel.attributedText = titleText
            storyTypeLabel.text = story.type
            pointsLabel.text = formattedPoints
            postedAtLabel.text = "\(String(formattedAgo!)) ago"
            postedByLabel.text = story.by
            commentsCountLabel.text = formattedCommentCount
            
            if showText == true {
                bodyLabel.attributedText = formattedText(story.text)
                bodyLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize - 2)
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var storyTypeLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var postedAtLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    @objc func storyTapped(sender: Any?) {
        delegate?.storyTapped(story: story!)
    }
    
    @objc func commentsTapped(sender: Any?) {
        delegate?.commentsTapped(story: story!)
    }
    
    func formattedText(_ text: String) -> NSAttributedString {
        let formattedBody = String(
            format: "<style>body { font-family: '-apple-system', 'HelveticaNeue'; font-size: \(UIFont.systemFontSize - 2) }</style><body><span>%@</span></body>",
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
