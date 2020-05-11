//
//  StopsViewController.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit
import MapKit

class StopsTableViewController: UITableViewController {

    var location: CLLocationCoordinate2D = Constant.defaultLocation
    var stopsService: StopsService = StopsService()
    var arrivalsService: ArrivalsService = ArrivalsService()
    
    private var stops: [Stop] = []
    private var arrivals: [String: [Arrival]] = [:]
    private var arrivalsTimer: Timer?
    private var selectedFacility: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStops(location: location)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        begingArrivalsRefreshing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        endArrivalsRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return stops.count
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return arrivals(for: stops[section]).count + 1
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseId(for: indexPath.row),
            for: indexPath
        )

        if indexPath.row == 0 {
            configureStopCell(cell, stop: stops[indexPath.section])
        } else {
            configureArrivalCell(cell, arrival: arrival(for: indexPath))
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FacilityDetailViewController {
            destination.facility = selectedFacility
        }
    }
}

// MARK: - MapViewControllerDelegate

extension StopsTableViewController: MapViewControllerDelegate {
    
    func mapViewController(mapViewController: MapViewController,
                           didChange location: CLLocationCoordinate2D) {
        self.location = location
        self.refreshStops(location: location)
    }
}

// MARK: - TableView utility methods

private extension StopsTableViewController {

    func configureArrivalCell(_ cell: UITableViewCell, arrival: Arrival) {
        let cellA = cell as? ArrivalTableViewCell
        cellA?.configure(title: arrival.towards, date: arrival.expectedArrival)
    }

    func configureStopCell(_ cell: UITableViewCell, stop: Stop) {
        let stopCell = cell as? StopTableViewCell
        stopCell?.configure(title: stop.name, collageItems: stop.facilities())
        stopCell?.delegate = self
    }

    func arrival(for indexPath: IndexPath) -> Arrival {
        return arrivals(for: stops[indexPath.section])[indexPath.row - 1]
    }
    
    func arrivals(for stop: Stop) -> [Arrival] {
        return arrivals[stop.naptanId] ?? []
    }
    
    func reuseId(for row: Int) -> String {
        return row == 0 ? Constant.stopReuseId : Constant.arrivalReuseId
    }
}

// MARK: - StopTableViewCellDelegate

extension StopsTableViewController: StopTableViewCellDelegate {

    func cell(cell: StopTableViewCell, didSelectCollageItemAt index: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        selectedFacility = stops[indexPath.section].facilities()[index]
        performSegue(withIdentifier: Constant.toFacilitySegueId, sender: cell)
    }
}

// MARK: - Refreshing stops

private extension StopsTableViewController {
    
    func refreshStops(location: CLLocationCoordinate2D) {
        stopsService.stopsNear(location: location) { stops, error in
            
            DispatchQueue.main.async {
                self.handleError(error)
                self.handleStops(stops)
                self.refreshArrivals(for: stops)
            }
        }
    }
    
    func handleStops(_ stops: [Stop]) {
        var sectionsToDelete = [Int]()
        var sectionsToInsert = [Int]()

        while self.stops.count > stops.count {
            self.stops.removeLast()
            sectionsToDelete.append(self.stops.count)
        }
        
        let sectionsToReload = Array(0..<self.stops.count)

        if stops.count > self.stops.count {
            sectionsToInsert = Array(self.stops.count..<stops.count)
        }

        self.stops = stops.sorted { $0.distance < $1.distance }
        self.arrivals = [:]

        tableView.beginUpdates()
        tableView.deleteSections(IndexSet(sectionsToDelete), with: .top)
        tableView.reloadSections(IndexSet(sectionsToReload), with: .fade)
        tableView.insertSections(IndexSet(sectionsToInsert), with: .bottom)
        tableView.endUpdates()
    }
}

// MARK: - Arrivals refreshing

private extension StopsTableViewController {
    
    func refreshArrivals(for stops: [Stop]) {
        guard stops.count > 0 else {
            arrivals = [:]
            return
        }
        
        for stop in stops {
            arrivalsService.arrivals(
                for: stop.naptanId,
                limit: Constant.defaultArrivalsLimit,
                handler: { arrivals, error in
                    
                    DispatchQueue.main.async {
                        self.handleError(error)
                        self.handleArrivals(stop: stop, arrivals: arrivals)
                    }
            })
        }
    }
    
    func handleArrivals(stop: Stop, arrivals: [Arrival]) {
        self.arrivals[stop.naptanId] = arrivals
        
        if let idx = stops.lastIndex(where: { $0.naptanId == stop.naptanId }) {
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet([idx]), with: .fade)
            tableView.endUpdates()
        }
    }
}

// MARK: - Arrivals timer

private extension StopsTableViewController {
    
    func begingArrivalsRefreshing() {
        guard arrivalsTimer == nil else {
            return
        }
        arrivalsTimer = Timer.scheduledTimer(
            withTimeInterval: Constant.refreshInterval,
            repeats: true,
            block: { [weak self] _ in
                self?.refreshArrivals(for: self?.stops ?? [])
            }
        )
    }
    
    func endArrivalsRefreshing() {
        arrivalsTimer?.invalidate()
        arrivalsTimer = nil
    }
}

// MARK: - Generic error handling

private extension StopsTableViewController {
    
    func handleError(_ error: Error?) {
        guard let error = error else  {
            return
        }
        
        let alert = UIAlertController(
            title: Constant.genericErrorTitle,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: Constant.genericErrorOK, style: .cancel)
        )
        
        present(alert, animated: true)
    }
}


// MARK: - Constants

private extension StopsTableViewController {

    struct Constant {
        static let arrivalReuseId = "ArrivalCellReuseId"
        static let stopReuseId = "StopCellReuseId"
        static let toFacilitySegueId = "toFacilityDetail"
        static let genericErrorTitle = "Error"
        static let genericErrorOK = "OK"
        static let defaultArrivalsLimit = 3
        static let refreshInterval = TimeInterval(30)
        static let defaultLocation = CLLocationCoordinate2D(
            latitude: 51.5155294,
            longitude: -0.1440504
        )
    }
}
