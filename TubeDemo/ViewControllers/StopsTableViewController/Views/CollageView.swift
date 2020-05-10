//
//  CollageView.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

class CollageView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0

        for (_, view) in subviews.enumerated() {
            view.sizeToFit()
            view.frame.origin = CGPoint(x: maxX, y: maxY)

            if view.frame.maxX > bounds.maxX && view.frame.minX == 0 {
                maxY = view.frame.maxY + Constant.padding
                continue
            }

            if view.frame.maxX > bounds.maxX {
                maxY = view.frame.maxY + Constant.padding
                view.frame.origin = CGPoint(x: 0, y: maxY)
            }

            maxX = view.frame.maxX + Constant.padding
        }
    }

    override var intrinsicContentSize: CGSize {
        let width = max(bounds.width, Constant.defaultMinWidth)
        let height = self.height(for: width)
        return CGSize(width: width, height: height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: height(for: size.width))
    }
}

// MARK: - Computing height for `intrinsicContentSize` content size

private extension CollageView {

    func height(for width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: 1)
        var maxXY = CGPoint.zero

        for (idx, view) in subviews.enumerated() {
            var frame = CGRect(origin: maxXY, size: view.sizeThatFits(size))

            if frame.maxX > width && frame.minX == 0 {
                maxXY.y = frame.maxY + Constant.padding
                continue
            }

            if frame.maxX > width {
                maxXY.y = frame.maxY + Constant.padding
                frame.origin = CGPoint(x: 0, y: maxXY.y)
            }

            maxXY.x = frame.maxX + Constant.padding

            if idx == subviews.count - 1 {
                maxXY.y = frame.maxY + Constant.padding
            }
        }
        return maxXY.y
    }
}

// MARK: - Constants

private extension CollageView {

    struct Constant {
        static let padding: CGFloat = 2
        static let defaultMinWidth: CGFloat = 100
    }
}
