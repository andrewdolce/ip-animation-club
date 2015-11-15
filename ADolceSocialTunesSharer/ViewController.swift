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

let slowFactor: Double = 1.0

class ViewController: UIViewController {

    @IBOutlet weak var topViewLeading: NSLayoutConstraint!
    @IBOutlet weak var bottomViewLeading: NSLayoutConstraint!

    @IBOutlet weak var shareContainerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var shareButton: UIButton!

    var tintAnimation: ExpandingTintAnimation = ExpandingTintAnimation(color: UIColor.whiteColor().colorWithAlphaComponent(0.8))

    let slideAnimationDuration: NSTimeInterval = NSTimeInterval(0.5 * slowFactor)
    let overlayAnimationDuration: NSTimeInterval = NSTimeInterval(0.5 * slowFactor)

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

        topViewLeading.constant = -CGRectGetWidth(shareContainerView.bounds)
        bottomViewLeading.constant = 0
        if animated {
            animateLayout(duration: slideAnimationDuration, delay: 0)
        } else {
            view.layoutIfNeeded()
        }
    }

    private func close(tappedView tappedView: UIView, animated: Bool) {
        if animated {
            tintAnimation.applyToView(bottomView, fromView: tappedView, duration: overlayAnimationDuration)

            topViewLeading.constant = 0
            animateLayout(duration: slideAnimationDuration, delay: overlayAnimationDuration)
        } else {
            topViewLeading.constant = 0
            view.layoutIfNeeded()
        }
    }

    private func animateLayout(duration duration: NSTimeInterval, delay: NSTimeInterval) {
        shareContainerView.userInteractionEnabled = false
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.view.layoutIfNeeded()
        }, completion: { completed in
            self.shareContainerView.userInteractionEnabled = true
            self.tintAnimation.remove()
        })
    }
}
