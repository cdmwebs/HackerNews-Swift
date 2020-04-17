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
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    var onLinkTapped: ((_ url: URL) -> Void)?
    
    var comment: HNComment? {
        didSet {
            guard let comment = comment else { return }
            
            commentText.attributedText = comment.labelText
            timeLabel.text = comment.formattedAgo
            parentLabel.text = comment.by
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commentText.textContainer.lineFragmentPadding = 0
        commentText.textContainerInset = .zero
        commentText.delegate = self
    }
}

extension CommentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if interaction == .invokeDefaultAction {
            self.onLinkTapped?(URL)
            return false
        } else {
            return true
        }
    }
}
