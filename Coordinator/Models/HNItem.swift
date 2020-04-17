//
//  HNItem.swift
//  Coordinator
//
//  Created by Chris Moore on 4/16/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import Foundation
import SwiftSoup
import UIKit

class HNItem: Decodable {
    var id: Int
    var url: URL?
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
    
    var escapedText: String {
        guard let text = text else { return "" }
        
        do {
            
            let unescapedText = try Entities.unescape(text)
            return unescapedText
        } catch Exception.Error(let type, let message) {
            print(type, message)
        } catch {
            print(error)
        }
        
        return ""
    }
    
    var formattedHTML: String {
        do {
            let textWithOpeningParagraph = "<p>\(escapedText)"
            let doc: Document = try SwiftSoup.parseBodyFragment(textWithOpeningParagraph)
            let html = try doc.html()
            return html
        } catch Exception.Error(let type, let message) {
            print(type, message)
        } catch {
            print(error)
        }
        
        return ""
    }
    
    var labelText: NSAttributedString {
        let attributedText = try? NSMutableAttributedString(
            data: formattedHTML.data(using: .utf8, allowLossyConversion: false)!,
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
