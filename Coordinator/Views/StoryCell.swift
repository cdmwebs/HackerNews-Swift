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
                .localizedString(from: (story.kids.count) as NSNumber, number: .decimal)
            
            titleLabel.attributedText = titleText
            storyTypeLabel.text = story.type
            pointsLabel.text = formattedPoints
            postedAtLabel.text = story.postedAt
            postedByLabel.text = story.by
            commentsCountLabel.text = formattedCommentCount
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
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
}
