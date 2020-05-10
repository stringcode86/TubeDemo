//
//  Stop.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation

struct Stop {
    
    let name: String
    let arrivals: [Arrival]
    let additionalProperties: [AdditionalProperty]
}

extension Stop {
    
    func facilities() -> [String] {
       return ["Test", "Random", "Something else"]
    }
}

struct AdditionalProperty {
    
    let key: String
    let category: String
    let value: Bool
}
