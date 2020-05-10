//
//  PaddedButton.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

class PaddedButton: UIButton {

    let padding: CGFloat = Constant.defaultPadding
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.width += padding * 2
        return size
    }
}

// MARK: - Constants

private extension PaddedButton {
    
    struct Constant {
        static let defaultPadding: CGFloat = 5
    }
}
