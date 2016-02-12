//
//  UIButton+Transition.swift
//  ASDBoardingPass
//
//  Created by Andrew Dolce on 12/12/15.
//  Copyright © 2015 Intrepid Pursuits. All rights reserved.
//

import UIKit

struct Animation {
    var duration: NSTimeInterval
    var delay: NSTimeInterval
    var prep: (() -> Void)? = nil
    var animations: (() -> Void)? = nil

    func play(completion: ((Bool) -> Void)? = nil) {
        prep?()
        let options = UIViewAnimationOptions.OverrideInheritedDuration
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: { self.animations?() }, completion: completion)
    }

    static func chain(animations: [Animation], finalCompletion: (() -> Void)? = nil) {
        if let nextAnimation = animations.first {
            nextAnimation.play() { finished in
                var rest = animations
                rest.removeFirst()
                chain(rest, finalCompletion: finalCompletion)
            }
        } else {
            finalCompletion?()
        }
    }
}

class FancyButton: UIView {
    private(set) var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    var action: (() -> Void)? = nil

    private var imageView = UIImageView()

    private var imageViewWidthConstraint: NSLayoutConstraint? = nil
    private var imageViewHeightConstraint: NSLayoutConstraint? = nil

    private var button = UIButton(type: .Custom)

    private var ripple = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupImageView()
        setupButton()
        setupRipple()
    }

    private func setupButton() {
        addSubview(button)
        button.constrainToFillSuperview()
        button.addTarget(self, action: "buttonWasPressed:", forControlEvents: .TouchUpInside)
        button.addTarget(self, action: "buttonTouchDown:", forControlEvents: .TouchDown)
        button.addTarget(self, action: "buttonTouchUpOutside:", forControlEvents: .TouchUpOutside)
    }

    private func setupImageView() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))

        imageViewWidthConstraint = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
        imageViewHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
        addConstraints([imageViewWidthConstraint!, imageViewHeightConstraint!])

        constrainToFitImage()
    }

    private func setupRipple() {
        addSubview(ripple)
        ripple.constrainToFillSuperview()

        ripple.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        ripple.alpha = 0
        ripple.userInteractionEnabled = false
    }

    private func constrainToFitImage() {
        self.imageViewWidthConstraint?.constant = self.image?.size.width ?? 0
        self.imageViewHeightConstraint?.constant = self.image?.size.height ?? 0
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        ripple.layer.cornerRadius = min(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) / 2
    }

    // MARK: - Action

    func buttonWasPressed(sender: UIButton) {
        expandRipple()
        action?()
    }

    func buttonTouchDown(sender: UIButton) {
        showRipple()
    }

    func buttonTouchUpOutside(sender: UIButton) {
        cancelRipple()
    }

    // MARK: - Ripple

    private func showRipple() {
        ripple.transform = CGAffineTransformMakeScale(0.8, 0.8)
        ripple.alpha = 1
    }

    private func cancelRipple() {
        UIView.animateWithDuration(0.4) {
            self.ripple.alpha = 0
        }
    }

    private func expandRipple() {
        UIView.animateWithDuration(0.4) {
            self.ripple.transform = CGAffineTransformMakeScale(1.2, 1.2)
            self.ripple.alpha = 0
        }
    }

    // MARK: - Image Transition

    func setImage(newImage: UIImage?, animated: Bool = false, completion: (() -> Void)? = nil) {
        if animated {
            transitionToImage(newImage, completion: completion)
        } else {
            image = newImage
            constrainToFitImage()
            completion?()
        }
    }

    private func transitionToImage(toImage: UIImage?, completion finalCompletion: (() -> Void)?) {
        let intermediateImage = UIImage(named: "outerBar")

        let squish = Animation(duration: 0.25, delay: 0, prep: {
            self.imageViewWidthConstraint?.constant = 4
        }, animations: {
            self.layoutIfNeeded()
        })

        let changeToIntermediateImage = Animation(duration: 0.25, delay: 0, prep: {
            self.image = intermediateImage
            self.layoutIfNeeded()
        }, animations: {
            self.imageView.backgroundColor = UIColor.whiteColor()
        })

        let unsquish = Animation(duration: 0.25, delay: 0, prep: {
            self.image = toImage
            self.constrainToFitImage()
            self.imageView.backgroundColor = UIColor.clearColor()
        }, animations: {
            self.layoutIfNeeded()
        })

        Animation.chain([ squish, changeToIntermediateImage, unsquish ], finalCompletion: finalCompletion)
    }
}
