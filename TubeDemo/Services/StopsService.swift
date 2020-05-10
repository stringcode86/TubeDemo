//
//  StopsService.swift
//  TubeDemo
//
//  Created by stringCode on 09/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation
import MapKit

struct StopsService {
    
    typealias StopsHandler = ([Stop], Error?)->Void
    
    func stopsNear(location: CLLocationCoordinate2D, handler: StopsHandler) {
        
    }
}
