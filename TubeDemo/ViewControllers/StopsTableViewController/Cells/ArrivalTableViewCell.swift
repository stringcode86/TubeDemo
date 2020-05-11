//
//  ArrivalTableViewCell.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

class ArrivalTableViewCell: UITableViewCell {

    func configure(title: String, date: Date) {
        textLabel?.text = title
        detailTextLabel?.text = Formatter.shorTime.string(from: date)
    }
}
