//
//  LoanedToolTableVIewCell.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 11/07/21.
//

import UIKit

class LoanedToolTableVIewCell: UITableViewCell {

    @IBOutlet private weak var toolImageView: UIImageView!
    @IBOutlet private weak var loanedToolCountLabel: UILabel!
    
    public func configure(toolImage: UIImage, loanedToolCount: String) {
        
        toolImageView.image = toolImage
        loanedToolCountLabel.text = loanedToolCount
    }
    
}
