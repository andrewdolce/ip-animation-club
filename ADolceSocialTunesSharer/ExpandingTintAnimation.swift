//
//  ExpandingTintLayer.swift
//  ADolceSocialTunesSharer
//
//  Created by Andrew Dolce on 11/15/15.
//  Copyright © 2015 Intrepid Pursuits. All rights reserved.
//

import Foundation
import UIKit

class ExpandingTintAnimation {
    let tintLayer: CALayer = CALayer()

    init(color: UIColor) {
        tintLayer.backgroundColor = color.CGColor
    }

    func applyToView(view: UIView, fromView: UIView, duration: NSTimeInterval) {
        let rect = view.convertRect(fromView.bounds, fromCoordinateSpace: fromView)
        applyToView(view, fromRect: rect, duration: duration)
    }

    func applyToView(view: UIView, fromRect: CGRect, duration: NSTimeInterval) {
        tintLayer.removeFromSuperlayer()
        view.layer.addSublayer(tintLayer)

        // Prepare the initial position of the layer (without animating)
        CALayer.doNotAnimate {
            self.tintLayer.frame = fromRect
            self.tintLayer.cornerRadius = min(CGRectGetWidth(fromRect), CGRectGetHeight(fromRect)) / 2
        }

        // Choose a scale that will make the layer big enough to fill the entire superlayer
        let xScaleFactor = CGRectGetWidth(view.bounds) / CGRectGetWidth(fromRect)
        let yScaleFactor = CGRectGetHeight(view.bounds) / CGRectGetHeight(fromRect)
        let scaleFactor = max(xScaleFactor, yScaleFactor) * 2
        let transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)

        // Kick off the animation
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(CATransform3D: transform)
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        tintLayer.addAnimation(animation, forKey: "tint")
    }

    func remove() {
        tintLayer.removeFromSuperlayer()
    }
}

extension CALayer {
    static func doNotAnimate(block: () -> Void) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey:kCATransactionDisableActions);
        block()
        CATransaction.commit()
    }
}
