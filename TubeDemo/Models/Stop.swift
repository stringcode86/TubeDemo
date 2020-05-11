//
//  Stop.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import Foundation

struct Stop {
    
    let naptanId: String
    let name: String
    let distance: Double
    let additionalProperties: [AdditionalProperty]
    
    func facilities() -> [String] {
        return additionalProperties
            .filter { $0.category == .facility && $0.available }
            .map { $0.key }
    }
}

// MARK: - Decodable

extension Stop: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case name = "commonName"
        case naptanId
        case distance
        case additionalProperties
    }
}

// MARK: - AdditionalProperty

struct AdditionalProperty: Decodable {
    
    let key: String
    let category: Category
    let value: String
    
    var available: Bool {
        return value != Constant.unavailableValue
    }
    
    enum Category: String, CaseIterable, Decodable {
        case facility = "Facility"
        case other

        init(from decoder: Decoder) throws {
            let container = try? decoder.singleValueContainer()
            let value = try? container?.decode(RawValue.self)
            let category = Self(rawValue: value ?? Self.allCases.last!.rawValue)
            self = category ?? Self.allCases.last!
        }
    }
}

// MARK: - Constants

extension AdditionalProperty {
    
    struct Constant {
        static let unavailableValue = "no"
    }
}
