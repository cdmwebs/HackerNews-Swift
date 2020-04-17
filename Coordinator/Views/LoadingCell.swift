//
//  LoadingCell.swift
//  Coordinator
//
//  Created by Chris Moore on 4/16/20.
//  Copyright © 2020 Known Decimal. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.startAnimating()
    }
}
