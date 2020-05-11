//
//  Arrival.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation

struct Arrival: Decodable {
    let id: String
    let towards: String
    let expectedArrival: Date
}
