//
//  CardView.swift
//  ADolceSwipeableCards
//
//  Created by Andrew Dolce on 1/21/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

class CardView: UIView {

    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var overlayView: UIView?

    var image: UIImage? = nil {
        didSet {
            imageView?.image = image
        }
    }

    var overlayAlpha: CGFloat = 0 {
        didSet {
            overlayView?.alpha = overlayAlpha
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        imageView?.image = image
        overlayView?.alpha = overlayAlpha
    }
}
