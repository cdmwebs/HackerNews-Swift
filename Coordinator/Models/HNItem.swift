//
//  HNItem.swift
//  Coordinator
//
//  Created by Chris Moore on 4/16/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation
import UIKit

class HNItem: Decodable {
    var id: Int
    var url: String?
    var kids: [Int]?
    var descendants: Int?
    var time: TimeInterval
    var by: String? = ""
    var type: String
    var text: String?
    var title: String?
    var score: Int?
    
    var formattedAgo: String {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.month, .day, .hour, .minute]
        dateFormatter.unitsStyle = .abbreviated
        
        let postedAgo = Date(timeIntervalSince1970: time).distance(to: Date())
        
        if let formattedAgo = dateFormatter.string(from: postedAgo) {
            return "\(formattedAgo) ago"
        } else {
            return ""
        }
    }
    
    var formattedText: NSAttributedString {
        guard text != nil else { return NSAttributedString() }
        
        let html = """
        <style>
            body {
                font-family: '-apple-system', 'HelveticaNeue';
                font-size: \(UIFont.systemFontSize - 2)
            }
        </style>
        <body>
            <span>%@</span>
        </body>
        """
        
        let formattedBody = String(format: html, text!)
        
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
