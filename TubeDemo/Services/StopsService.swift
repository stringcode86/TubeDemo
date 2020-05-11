//
//  StopsService.swift
//  TubeDemo
//
//  Created by stringCode on 09/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation
import MapKit

typealias StopsHandler = ([Stop], Error?)->Void

protocol StopsService {
    
    func stopsNear(location: CLLocationCoordinate2D, handler: @escaping StopsHandler)
}

struct DefaultStopsService: StopsService {

    func stopsNear(location: CLLocationCoordinate2D, handler: @escaping StopsHandler) {
        
        let endPoint = EndPoint.nearByStations(
            lat: location.latitude,
            lon: location.longitude,
            radius: Constant.defaultRadius
        )
        
        NetworkManager.request(
            endPoint,
            type: StopPointsResponse.self,
            handler: { response, error in
                handler(response?.stops ?? [], error)
        })
    }
}

// MARK: - Constants

private extension DefaultStopsService {
    
    struct Constant {
        static let defaultRadius = 1000
    }
}
