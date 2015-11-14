//
//  ViewController.swift
//  ADolceSocialTunesSharer
//
//  Created by Andrew Dolce on 11/14/15.
//  Copyright © 2015 Intrepid Pursuits. All rights reserved.
//

import UIKit
import IntrepidSwiftWisdom

extension UIColor {
    static func shareBackgroundColor() -> UIColor {
        return ColorDescriptor.RGB(r: 52, g: 25, b: 46, a: 255).color
    }
    static func shareForegroundColor() -> UIColor {
        return ColorDescriptor.RGB(r: 216, g: 197, b: 99, a: 255).color
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var topViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var bottomViewLeading: NSLayoutConstraint!

    @IBOutlet weak var shareContainerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet weak var tintedOverlayView: UIView!

    @IBOutlet weak var shareButton: UIButton!

    let slideAnimationDuration: NSTimeInterval = 0.5
    let overlayAnimationDuration: NSTimeInterval = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()

        topView.backgroundColor = UIColor.shareForegroundColor()
        bottomView.backgroundColor = UIColor.shareBackgroundColor()

        shareContainerView.backgroundColor = bottomView.backgroundColor
        shareButton.setTitleColor(bottomView.backgroundColor, forState: .Normal)
    }

    override func viewDidLayoutSubviews() {
        let halfHeight =  CGRectGetHeight(shareContainerView.bounds) / 2;
        shareContainerView.layer.cornerRadius = halfHeight
        topView.layer.cornerRadius = halfHeight
    }

    // MARK: - Actions

    @IBAction func shareButtonPressed(sender: UIButton) {
        open(animated: true)
    }

    @IBAction func mediaButtonPressed(sender: UIButton) {
        close(tappedView: sender, animated: true)
    }

    // MARK: - Animations

    private func open(animated animated: Bool) {
        if animated {
            bottomViewLeading.constant = CGRectGetWidth(shareContainerView.bounds)
            view.layoutIfNeeded()
        }

        topViewTrailing.constant = 0
        bottomViewLeading.constant = 0
        if animated {
            animateLayout(duration: slideAnimationDuration, delay: 0)
        } else {
            view.layoutIfNeeded()
        }
    }

    private func close(tappedView tappedView: UIView, animated: Bool) {
        if animated {
            animateOverlayFromView(tappedView, duration: overlayAnimationDuration)
            topViewTrailing.constant = CGRectGetWidth(shareContainerView.bounds)
            animateLayout(duration: overlayAnimationDuration, delay: slideAnimationDuration)
        } else {
            topViewTrailing.constant = CGRectGetWidth(shareContainerView.bounds)
            view.layoutIfNeeded()
        }
    }

    private func animateLayout(duration duration: NSTimeInterval, delay: NSTimeInterval) {
        shareContainerView.userInteractionEnabled = false
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.view.layoutIfNeeded()
            }, completion: { completed in
                self.shareContainerView.userInteractionEnabled = true
                self.tintedOverlayView.hidden = true
        })
    }

    // MARK: Overlay Animation

    private func animateOverlayFromView(aView: UIView, duration: NSTimeInterval) {
        positionOverlayOnView(aView)
        tintedOverlayView.hidden = false
        UIView.animateWithDuration(duration) {
            self.expandOverlay()
        }
    }

    private func positionOverlayOnView(aView: UIView) {
        let rect: CGRect = shareContainerView.convertRect(aView.bounds, fromView: aView)
        tintedOverlayView.transform = CGAffineTransformIdentity
        tintedOverlayView.frame = rect
        tintedOverlayView.layer.cornerRadius = min(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 2
    }

    private func expandOverlay() {
        let xScaleFactor = CGRectGetWidth(shareContainerView.bounds) / CGRectGetWidth(tintedOverlayView.bounds)
        let yScaleFactor = CGRectGetHeight(shareContainerView.bounds) / CGRectGetHeight(tintedOverlayView.bounds)
        let scaleFactor = max(xScaleFactor, yScaleFactor) * 2

        tintedOverlayView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
    }
}
