//
//  ContactTableViewCell.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 10/07/21.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    //MARK: - PRIVATE PROPERTIES
    
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    func configure(viewModel: ContactViewModel) {
        
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.image = UIImage(named: viewModel.image)
        nameLabel.text = viewModel.name
    }
    
}
