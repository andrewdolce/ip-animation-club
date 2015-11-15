//
//  ExpandingTintLayer.swift
//  ADolceSocialTunesSharer
//
//  Created by Andrew Dolce on 11/15/15.
//  Copyright © 2015 Intrepid Pursuits. All rights reserved.
//

import Foundation
import UIKit

class ExpandingTintLayer : CALayer {
    init(color: UIColor) {
        super.init()
        backgroundColor = color.CGColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animateOnView(view: UIView, fromView: UIView, duration: NSTimeInterval) {
        let rect = view.convertRect(fromView.bounds, fromCoordinateSpace: fromView)
        animateOnView(view, fromRect: rect, duration: duration)
    }

    func animateOnView(view: UIView, fromRect: CGRect, duration: NSTimeInterval) {
        view.layer.addSublayer(self)
        frame = fromRect
        cornerRadius = min(CGRectGetWidth(fromRect), CGRectGetHeight(fromRect)) / 2

        let xScaleFactor = CGRectGetWidth(view.bounds) / CGRectGetWidth(fromRect)
        let yScaleFactor = CGRectGetHeight(view.bounds) / CGRectGetHeight(fromRect)
        let scaleFactor = max(xScaleFactor, yScaleFactor) * 2
        let transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)

        let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(CATransform3D: transform)
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        addAnimation(animation, forKey: "tint")
    }
}
