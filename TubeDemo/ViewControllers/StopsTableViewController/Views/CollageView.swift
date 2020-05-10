//
//  CollageView.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

class CollageView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 320, height: 60)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
}
