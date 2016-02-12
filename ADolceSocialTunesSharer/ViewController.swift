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

    var rippleAnimation: RippleAnimation = RippleAnimation(color: UIColor.whiteColor().colorWithAlphaComponent(0.8))

    let slideAnimationDuration: NSTimeInterval = NSTimeInterval(0.5 * slowFactor)
    let rippleAnimationDuration: NSTimeInterval = NSTimeInterval(0.5 * slowFactor)

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
        open()
    }

    @IBAction func mediaButtonPressed(sender: UIButton) {
        close(tappedView: sender)
    }

    // MARK: - Animations

    private func open() {
        // First shift the bottom view all the way to the right
        bottomViewLeading.constant = CGRectGetWidth(shareContainerView.bounds)
        view.layoutIfNeeded()

        // Now animate the views into place
        topViewLeading.constant = -CGRectGetWidth(shareContainerView.bounds)
        bottomViewLeading.constant = 0

        UIView.animateWithDuration(slideAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    private func close(tappedView tappedView: UIView) {
        shareContainerView.userInteractionEnabled = false
        rippleAnimation.applyToView(bottomView, fromView: tappedView, duration: rippleAnimationDuration)

        topViewLeading.constant = 0

        let options = UIViewAnimationOptions(rawValue: 0)
        UIView.animateWithDuration(slideAnimationDuration, delay: rippleAnimationDuration, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finished in
            self.rippleAnimation.remove()
            self.shareContainerView.userInteractionEnabled = true
        })
    }
}
