//
//  ArrivalsService.swift
//  TubeDemo
//
//  Created by stringCode on 09/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation

typealias ArrivalsHandler = ([Arrival], Error?) -> Void

protocol ArrivalsService {
        
    func arrivals(for naptanId: String, limit: Int, handler: @escaping ArrivalsHandler)
}

struct DefaultArrivalsService: ArrivalsService {
    
    typealias ArrivalsHandler = ([Arrival], Error?) -> Void
    
    func arrivals(for naptanId: String, limit: Int, handler: @escaping ArrivalsHandler) {
        NetworkManager.request(
            EndPoint.arrivals(id: naptanId),
            type: Array<Arrival>.self,
            handler: { arrivals, error in
                handler(self.ordered(arrivals: arrivals, limit: limit), error)
        })
    }
    
    private func ordered(arrivals: [Arrival]?, limit: Int) -> [Arrival] {
        guard var arrivals = arrivals else {
            return []
        }
                
        arrivals = arrivals
            .sorted { $0.expectedArrival < $1.expectedArrival }
            .filter { Date() < $0.expectedArrival }
        
        if arrivals.count > limit {
            return Array(arrivals[0..<limit])
        }
        
        return arrivals
    }
}
