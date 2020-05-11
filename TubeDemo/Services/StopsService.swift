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
    
    func stopsNear(location: CLLocationCoordinate2D, handler: @escaping StopsHandler) {
        let endPoint = EndPoint.nearByStations(
            lat: location.latitude,
            lon: location.longitude,
            radius: Constant.defaultRadius)
        NetworkManager.request(endPoint, type: StopPointsResponse.self) { resp, error in
            handler(resp?.stops ?? [], error)
        }
    }
}

// MARK: - Constants

private extension StopsService {
    
    struct Constant {
        static let defaultRadius = 1000
    }
}
