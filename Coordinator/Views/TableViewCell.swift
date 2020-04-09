//
//  TableViewCell.swift
//  Coordinator
//
//  Created by Chris Moore on 4/8/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate : class {
    func storyTapped(story: Story)
    func commentsTapped(story: Story)
}

class TableViewCell: UITableViewCell {
    var delegate: TableViewCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let domainLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 25, width: 300, height: 20))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    let commentCountLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 110, y: 25, width: 40, height: 20))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    var story: Story? {
        didSet {
            titleLabel.text = story?.title
            domainLabel.text = story?.domain
            
            let formattedText = NumberFormatter
                .localizedString(from: (story?.commentsCount ?? 0) as NSNumber, number: .decimal)
            commentCountLabel.text = formattedText
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutCell() {
        titleLabel.text = "Default Title"
        domainLabel.text = "www.example.com"
        commentCountLabel.text = "0"
        
        let commentBubble = UIImageView(image: UIImage(systemName: "bubble.left"))
        commentBubble.frame = CGRect(x: 110, y: 0, width: 20, height: 20)
        commentBubble.tintColor = .systemGray
        
        let leftStack = UIStackView()
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.axis = .vertical
        leftStack.spacing = 5
        leftStack.addArrangedSubview(titleLabel)
        leftStack.addArrangedSubview(domainLabel)
        leftStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(storyTapped(sender:))))
        
        let rightStack = UIStackView()
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.axis = .vertical
        rightStack.spacing = 5
        rightStack.alignment = .center
        rightStack.addArrangedSubview(commentBubble)
        rightStack.addArrangedSubview(commentCountLabel)
        rightStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commentsTapped(sender:))))
        
        let outerStack = UIStackView()
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        outerStack.axis = .horizontal
        outerStack.spacing = 5
        
        outerStack.addArrangedSubview(leftStack)
        outerStack.addArrangedSubview(rightStack)
        
        addSubview(outerStack)
        
        outerStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        outerStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        outerStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        outerStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        
        leftStack.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.80).isActive = true
    }

    @objc func storyTapped(sender: UIStackView?) {
        delegate?.storyTapped(story: story!)
    }
    
    @objc func commentsTapped(sender: UIStackView?) {
        delegate?.commentsTapped(story: story!)
    }
}
