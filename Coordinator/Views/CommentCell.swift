//
//  DetailCell.swift
//  Coordinator
//
//  Created by Chris Moore on 4/10/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var parentLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    var comment: HNComment? {
        didSet {
            guard let comment = comment else { return }
            
            commentLabel.attributedText = comment.labelText
            timeLabel.text = comment.formattedAgo
            parentLabel.text = comment.by
        }
    }
}
