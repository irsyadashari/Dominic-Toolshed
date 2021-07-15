//
//  ContactViewModel.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 08/07/21.
//

import Foundation

struct ContactViewModel {
    
    var contact: Contact
    
    var name: String {
        return contact.name
    }
    
    var image: String {
        return contact.image
    }
    
    var borrowedTools: [String] {
        return contact.borrowedTools
    }
    
}
