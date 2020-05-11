//
//  StopPointsResponse.swift
//  TubeDemo
//
//  Created by stringCode on 11/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation

struct StopPointsResponse {
    
    let stops: [Stop]
}

extension StopPointsResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case stops = "stopPoints"
    }
}
