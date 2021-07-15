//
//  ToolTableViewCell.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 02/07/21.
//

import UIKit

class ToolTableViewCell: UITableViewCell {

    @IBOutlet private weak var toolImage: UIImageView!
    @IBOutlet private weak var toolsName: UILabel!
    @IBOutlet private weak var itemCount: UILabel!
    @IBOutlet private weak var loanCount: UILabel!
    
    func configure(viewModel: ToolViewModel) {
        toolImage.image = UIImage(named: viewModel.tool.image)
        toolsName.text = viewModel.tool.name
        itemCount.text = "\(viewModel.tool.itemCount)"
        loanCount.text = "\(viewModel.tool.loanCount)"
    }
    
}
