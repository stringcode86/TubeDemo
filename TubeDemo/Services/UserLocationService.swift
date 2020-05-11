//
//  UserLocationService.swift
//  TubeDemo
//
//  Created by stringCode on 11/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation
import CoreLocation

class UserLocationService: NSObject {

    typealias LocationHandler = (CLLocationCoordinate2D?)->Void
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    private var userLocationHandlers: [LocationHandler] = []
    
    func getUserLocation(handler: @escaping LocationHandler) {
        requestLocationPermissionsIfNeeded()
        userLocationHandlers.append(handler)
        locationManager.startUpdatingLocation()
    }
    
    func requestLocationPermissionsIfNeeded() {
        let status = CLLocationManager.authorizationStatus()
        if status != .authorizedWhenInUse || status != .authorizedAlways {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension UserLocationService: CLLocationManagerDelegate {
        
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        manager.stopUpdatingLocation()
        
        while userLocationHandlers.count != 0 {
            let handler = userLocationHandlers.removeLast()
            handler(location.coordinate)
        }
    }
}
