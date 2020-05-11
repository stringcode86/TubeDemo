//
//  MKCoordinateRegion.swift
//  TubeDemo
//
//  Created by stringCode on 11/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
    
    var maxLongitude: Double {
        center.longitude + span.longitudeDelta
    }
    
    var minLongitude: Double {
        center.longitude - span.longitudeDelta
    }
    
    var maxLatitude: Double {
        center.latitude + span.latitudeDelta
    }
    
    var minLatitude: Double {
        center.latitude - span.latitudeDelta
    }
    
    func contains(location: CLLocationCoordinate2D) -> Bool {
        return location.longitude <= maxLongitude &&
            location.longitude >= minLongitude &&
            location.latitude <= maxLatitude &&
            location.latitude >= minLatitude
    }
}
