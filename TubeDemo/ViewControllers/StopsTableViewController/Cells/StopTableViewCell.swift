//
//  StopTableViewCell.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

protocol StopTableViewCellDelegate: class {

    func cell(cell: StopTableViewCell, didSelectCollageItemAt index: Int)
}

class StopTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collageView: CollageView!

    weak var delegate: StopTableViewCellDelegate?
    
    func configure(title: String, collageItems: [String]) {
        titleLabel.text = title
        setCollageItems(collageItems)
    }
}

// MARK: - Collage handling

private extension StopTableViewCell {
    
    func setCollageItems(_ collageItems: [String]) {
        while collageView.subviews.count > collageItems.count {
            collageView.subviews.last?.removeFromSuperview()
        }
        
        for (index, collageItem) in collageItems.enumerated() {
            let button = dequeueButton(collageView: collageView, at: index)
            button?.setTitle(collageItem, for: .normal)
            button?.tag = index
        }
        
        collageView.invalidateIntrinsicContentSize()
        collageView.setNeedsLayout()
    }
    
    func dequeueButton(collageView: CollageView, at index: Int) -> UIButton? {
        guard index >= collageView.subviews.count else {
            return collageView.subviews[index] as? UIButton
        }
        
        let button = PaddedButton(type: .roundedRect)
        button.addTarget(
            self,
            action: #selector(collageButtonAction(_:)),
            for: .touchUpInside
        )
        
        styleButton(button)
        collageView.addSubview(button)
        
        return button
    }
    
    func styleButton(_ button: UIButton) {
        button.backgroundColor = UIColor.secondarySystemBackground
        button.setTitleColor(UIColor.darkText, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
    }
    
    @objc func collageButtonAction(_ sender: UIButton) {
        delegate?.cell(cell: self, didSelectCollageItemAt: sender.tag)
    }
}
