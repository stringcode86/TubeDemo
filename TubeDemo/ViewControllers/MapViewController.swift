//
//  ViewController.swift
//  TubeDemo
//
//  Created by stringCode on 09/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate: class {
    func mapViewController(mapViewController: MapViewController,
                           didChange location: CLLocationCoordinate2D)
}

/// `MapViewController` is a location provider via `MapViewControllerDelegate`. It requests
/// locations permissions via `UserLocationService`. Either defaults to
/// `Constant.defaultLocation` (central London) if permissions are not granted or user location is
/// outside of M25 (`Constant.londonRegion`).
class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    weak var delegate: MapViewControllerDelegate?
    
    var locationService: UserLocationService = DefaultUserLocationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveMapToLocation(location: Constant.defaultLocation)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationService.getUserLocation { [weak self] location in
            self?.handleUserLocationUpdate(location: location)
        }
    }
}

// MARK: - Default map location handling

extension MapViewController {
    
    func handleUserLocationUpdate(location: CLLocationCoordinate2D?) {
        guard let location = location else {
            moveMapToLocation(location: Constant.defaultLocation)
            return
        }
        
        guard Constant.londonRegion.contains(location: location) else {
            moveMapToLocation(location: Constant.defaultLocation)
            return
        }
        
        moveMapToLocation(location: location)
    }
    
    func moveMapToLocation(location: CLLocationCoordinate2D) {
        mapView.setVisibleMapRect(
            MKMapRect(origin: MKMapPoint(location), size: Constant.defaultSize),
            animated: true
        )
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapViewController(
            mapViewController: self,
            didChange: mapView.region.center
        )
    }
}

// MARK: - Constants

private extension MapViewController {
    
    struct Constant {
        static let defaultSize = MKMapSize(width: 1000, height: 1000)
        static let defaultLocation = CLLocationCoordinate2D(
            latitude: 51.5158221,
            longitude: -0.1434976
        )
        static let londonRegion = MKCoordinateRegion(
            center: Constant.defaultLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.4))
    }
}
