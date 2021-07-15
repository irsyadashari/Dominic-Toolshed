//
//  Tool.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 02/07/21.
//

import Foundation

struct Tool {
    
    let id: Int = generateID()
    let name: String
    let image: String
    var itemCount: Int
    var loanCount: Int
    var lendersName: [String]
    
    static func generateID() -> Int {
        Int.random(in: 1..<999999999)
    }
}
