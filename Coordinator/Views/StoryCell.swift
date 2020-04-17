//
//  StoryCell.swift
//  Coordinator
//
//  Created by Chris Moore on 4/9/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

protocol StoryCellDelegate : class {
    func storyTapped(story: HNStory)
    func commentsTapped(story: HNStory)
}

class StoryCell: UITableViewCell {
    var delegate: StoryCellDelegate?
    
    var showText: Bool = false {
        didSet {
            guard showText == true else { return }
            bodyLabel.attributedText = story?.formattedText
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
            
            if showText == true {
                bodyLabel.attributedText = story.formattedText
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
}
