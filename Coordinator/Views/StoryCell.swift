//
//  StoryCell.swift
//  Coordinator
//
//  Created by Chris Moore on 4/9/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

class StoryCell: UITableViewCell {
    var showText: Bool = false
    
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
        
        let title = NSMutableAttributedString(string: story.title ?? "")
        
        if !story.domain.isEmpty {
            let domain = NSAttributedString(string: " (\(story.domain))", attributes: quietAttributes)
            title.append(domain)
        }
        
        return title
    }
    
    var story: HNStory? {
        didSet {
            guard let story = story else { return }

            let formattedPoints = NumberFormatter
                .localizedString(from: (story.score ?? 0) as NSNumber, number: .decimal)
            
            let formattedCommentCount = NumberFormatter
                .localizedString(from: (story.descendants ?? 0) as NSNumber, number: .decimal)

            titleLabel.attributedText = titleText
            storyTypeLabel.text = story.type
            pointsLabel.text = formattedPoints
            postedAtLabel.text = story.formattedAgo
            postedByLabel.text = story.by
            commentsCountLabel.text = formattedCommentCount
            
            if showText {
                bodyLabel.attributedText = story.labelText
                topConstraint.constant = 20
                titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            } else {
                bodyLabel.text = ""
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
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var onLinkTapped: ((_ url: URL) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapOnTitleGesture = UITapGestureRecognizer(target: self, action: #selector(titleWasTapped(_:)))
        titleLabel.addGestureRecognizer(tapOnTitleGesture)
        titleLabel.isUserInteractionEnabled = false
    }
    
    @objc func titleWasTapped(_ sender: UIGestureRecognizer) {
        guard let url = story?.url else { return }
        onLinkTapped?(url)
    }
}
