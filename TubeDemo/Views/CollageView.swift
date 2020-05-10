//
//  CollageView.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

/// `CollageView` lays out `subviews` in collage. Calls `sizeThatFits(_)` for each view and
/// proceeds to layout in a rows.
///
/// - Note: Performance could be improved by caching subviews frames and invalidated on
/// `invalidateIntrinsicContentSize()` and or `setNeedsLayout()`. Due to time constraints
/// and the fact that only handful of views are layout this was skipped
///
/// - Note: Should not layout subviews directly. API similar to `StackView` ie
/// `addArrangedSubview(_)` would be more fitting. Omitted for due to time constraint and fact that this
/// is simple a demo.
class CollageView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        let frames = framesForSubViews(in: bounds)
        subviews.enumerated().forEach { idx, view in
            view.frame = frames[idx]
        }
    }

    override var intrinsicContentSize: CGSize {
        let width = max(bounds.width, Constant.defaultMinWidth)
        return sizeThatFits(CGSize(width: width, height: width))
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let frames = framesForSubViews(in: CGRect(origin: .zero, size: size))
        return CGSize(width: size.width, height: frames.last?.maxY ?? 0)
    }
}

// MARK: - Computing subViews frames

private extension CollageView {

    func framesForSubViews(in bounds: CGRect) -> [CGRect] {
        var maxXY = CGPoint.zero
        var frames: [CGRect] = []

        for view in subviews {
            let viewSize = view.sizeThatFits(bounds.size)
            var frame = CGRect(origin: maxXY, size: viewSize)

            if frame.maxX > bounds.width && frame.minX == 0 {
                maxXY.y = frame.maxY + Constant.padding
                continue
            }

            if frame.maxX > bounds.width {
                maxXY.y = frame.maxY + Constant.padding
                frame.origin = CGPoint(x: 0, y: maxXY.y)
            }

            maxXY.x = frame.maxX + Constant.padding
            frames.append(frame)
        }

        return frames
    }
}

// MARK: - Constants

private extension CollageView {

    struct Constant {
        static let padding: CGFloat = 4
        static let defaultMinWidth: CGFloat = 100
    }
}
