//
//  StopsViewController.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit
import MapKit

/// `StopsTableViewController` implements `MapViewControllerDelegate` to get location.
/// Uses `StopService` and `ArrivalsService` to load data. Mock services could easily be
/// injected. Entire section is used for displaying data for one tube stop. First cell acts as header.
/// This is due to facilities requirement. Facilities have non-uniform size. Therefore autosizing cells
/// seem a natural fit. Autosizing does not work with section headers. When loading stops animations
/// are not as graceful as I would like. This could be improved by more elaborate diffing. For now
/// I'm simply reloading, inserting or deleting sections. Currently there is no loading state. Error
/// handling very rudimentary.
class StopsTableViewController: UITableViewController {

    var location: CLLocationCoordinate2D = Constant.defaultLocation
    var stopsService: StopsService = DefaultStopsService()
    var arrivalsService: ArrivalsService = DefaultArrivalsService()
    
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
                self.handleNewStops(stops)
                self.refreshArrivals(for: stops)
            }
        }
    }
    
    func handleNewStops(_ stops: [Stop]) {
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
        tableView.deleteSections(IndexSet(sectionsToDelete), with: .bottom)
        tableView.reloadSections(IndexSet(sectionsToReload), with: .fade)
        tableView.insertSections(IndexSet(sectionsToInsert), with: .top)
        tableView.endUpdates()
    }
}

// MARK: - Arrivals refreshing

private extension StopsTableViewController {
    
    func refreshArrivals(for stops: [Stop]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            guard stops.count > 0 else {
                self.arrivals = [:]
                return
            }
            
            for stop in stops {
                self.arrivalsService.arrivals(
                    for: stop.naptanId,
                    limit: Constant.defaultArrivalsLimit,
                    handler: { arrivals, error in
                        
                        DispatchQueue.main.async {
                            self.handleError(error)
                            self.handleNewArrivals(stop: stop, arrivals: arrivals)
                        }
                })
            }
        }
    }
    
    func handleNewArrivals(stop: Stop, arrivals: [Arrival]) {

        if let idx = stops.lastIndex(where: { $0.naptanId == stop.naptanId }) {

            var currArrivals = self.arrivals[stop.naptanId] ?? []

            var indexesToDelete = [Int]()
            var indexesToInsert = [Int]()

            // Removing unn--eeded cells
            while currArrivals.count > (arrivals.count) + 1 {
                currArrivals.removeLast()
                indexesToDelete.append(currArrivals.count + 1)
            }

            // Adding unneeded cells
            let indexesToReload = Array(1..<(currArrivals.count + 1))

            // Inserting new cells if needed
            if  currArrivals.count < (arrivals.count + 1) {
                indexesToInsert = Array((currArrivals.count + 1)..<(arrivals.count + 1))
            }

            self.arrivals[stop.naptanId] = arrivals

            let cellsToDelete = indexesToDelete.map { IndexPath(row: $0, section: idx) }
            let cellsToReload = indexesToReload.map { IndexPath(row: $0, section: idx) }
            let cellsToInsert = indexesToInsert.map { IndexPath(row: $0, section: idx) }

            tableView.beginUpdates()
            tableView.deleteRows(at: cellsToDelete, with: .top)
            tableView.reloadRows(at: cellsToReload, with: .fade)
            tableView.insertRows(at: cellsToInsert, with: .bottom)
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
