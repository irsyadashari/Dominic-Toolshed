//
//  ToolViewModel.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 02/07/21.
//

import Foundation

struct ToolViewModel {
    
    var tool: Tool
    
    var name: String {
        return tool.name 
    }
    
    var image: String {
        return tool.image 
    }
    
    var itemCount: Int {
        return tool.itemCount 
    }
    
    var loanCount: Int {
        return tool.loanCount
    }
    
}
