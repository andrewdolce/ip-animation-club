//
//  RippleLayer.swift
//  ADolceSocialTunesSharer
//
//  Created by Andrew Dolce on 11/15/15.
//  Copyright © 2015 Intrepid Pursuits. All rights reserved.
//

import Foundation
import UIKit

class RippleAnimation {
    let tintView: UIView = UIView()

    init(color: UIColor) {
        tintView.backgroundColor = color
    }

    func applyToView(view: UIView, fromView: UIView, duration: NSTimeInterval) {
        let rect = view.convertRect(fromView.bounds, fromCoordinateSpace: fromView)
        applyToView(view, fromRect: rect, duration: duration)
    }

    func applyToView(view: UIView, fromRect: CGRect, duration: NSTimeInterval) {
        tintView.removeFromSuperview()
        view.addSubview(tintView)

        tintView.transform = CGAffineTransformIdentity
        tintView.frame = fromRect
        tintView.layer.cornerRadius = min(CGRectGetWidth(fromRect), CGRectGetHeight(fromRect)) / 2

        // Choose a scale that will make the layer big enough to fill the entire superlayer
        let xScaleFactor = CGRectGetWidth(view.bounds) / CGRectGetWidth(fromRect)
        let yScaleFactor = CGRectGetHeight(view.bounds) / CGRectGetHeight(fromRect)
        let scaleFactor = max(xScaleFactor, yScaleFactor) * 2
        let transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)

        // Kick off the animation
        UIView.animateWithDuration(duration, delay: 0, options: [.CurveLinear], animations: {
            self.tintView.transform = transform
        }, completion: nil)
    }

    func remove() {
        tintView.removeFromSuperview()
    }
}
