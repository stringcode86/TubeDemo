//
//  StopTableViewCell.swift
//  TubeDemo
//
//  Created by stringCode on 10/05/2020.
//  Copyright © 2020 stringcode. All rights reserved.
//

import UIKit

class StopTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var collageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelFrame = titleLabel.frame
        titleLabel.sizeToFit()
        titleLabel.frame.origin = labelFrame.origin
        
        let collageFrame = collageView.frame
        collageView.sizeToFit()
        collageView.frame.origin = collageFrame.origin
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        collageView.sizeToFit()
        return CGSize(width: size.width, height: collageView.frame.maxY + titleLabel.frame.minY)
    }
}
