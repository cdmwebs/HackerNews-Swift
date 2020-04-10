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
            
            titleLabel.attributedText = titleText
            domainLabel.text = "Ask HN | \(formattedPoints) pts | \(story.by) | 10h"
            
            let formattedText = NumberFormatter
                .localizedString(from: (story.commentsCount) as NSNumber, number: .decimal)
            commentsCountLabel.text = formattedText
        }
    }
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    override func awakeFromNib() {
       super.awakeFromNib()
       bindActions()
    }
    
    private func bindActions() {
        leftView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(storyTapped(sender:)))
        )
        
        rightView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(commentsTapped(sender:)))
        )
    }
    
    @objc func storyTapped(sender: Any?) {
        delegate?.storyTapped(story: story!)
    }
    
    @objc func commentsTapped(sender: Any?) {
        delegate?.commentsTapped(story: story!)
    }
}
