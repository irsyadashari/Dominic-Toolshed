//
//  DominicToolshed.swift
//  DominicTools
//
//  Created by Irsyad Ashari on 02/07/21.
//

import Foundation

class DominicToolshed {
    let tools:[Tool]
    
    init() {
        let toolsList = [
            Tool(name: "Wrench", image: "wrench", itemCount: 6, loanCount: 0, lendersName: []),
            Tool(name: "Cutter", image: "cutter", itemCount: 15, loanCount: 0, lendersName: []),
            Tool(name: "Pliers", image: "pliers", itemCount: 12, loanCount: 0, lendersName: []),
            Tool(name: "Screwdriver", image: "screwdriver", itemCount: 13, loanCount: 0, lendersName: []),
            Tool(name: "Welding machine", image: "welding_machine", itemCount: 3, loanCount: 0, lendersName: []),
            Tool(name: "Welding glasses", image: "welding_glasses", itemCount: 7, loanCount: 0, lendersName: []),
            Tool(name: "Hammer", image: "hammer", itemCount: 4, loanCount: 0, lendersName: []),
            Tool(name: "Measuring Tape", image: "measuring_tape", itemCount: 9, loanCount: 0, lendersName: []),
            Tool(name: "Alan key set", image: "key_set", itemCount: 4, loanCount: 0, lendersName: []),
            Tool(name: "Air compressor", image: "air_compressor", itemCount: 2, loanCount: 0, lendersName: []),
        ]
        
        self.tools = toolsList
    }
}
