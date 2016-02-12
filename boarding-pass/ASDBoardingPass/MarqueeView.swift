//
//  MarqueeView.swift
//  ASDBoardingPass
//
//  Created by Andrew Dolce on 12/12/15.
//  Copyright © 2015 Intrepid Pursuits. All rights reserved.
//

import UIKit

class MarqueeView: UIView {
    var attributedText: NSAttributedString? = nil

    private var leftLabel = UILabel()
    private var rightLabel = UILabel()
    private var sizingLabel = UILabel()
    private var initialWidth: CGFloat = 600

    override func awakeFromNib() {
        super.awakeFromNib()

        initialWidth = CGRectGetWidth(bounds)
        setupLabels()
    }

    func startAnimating() {
        startNextLoop()
    }

    private func setupLabels() {
        let labels = [
            "left": leftLabel,
            "right": rightLabel
        ]
        for label in labels.values {
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        let options = NSLayoutFormatOptions.AlignAllBaseline
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[left][right]|", options: options, metrics: nil, views: labels))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[right]-|", options: options, metrics: nil, views: labels))
    }

    private func repeatedText(text: NSAttributedString, toFillWidth width: CGFloat) -> NSAttributedString {
        let delimiter = NSAttributedString(string: " ")
        let textWithDelimiter = text.mutableCopy() as! NSMutableAttributedString
        textWithDelimiter.appendAttributedString(delimiter)

        sizingLabel.attributedText = textWithDelimiter
        let labelWidth = sizingLabel.intrinsicContentSize().width
        let numRepeats = Int(width / labelWidth) + 1
        let repeated = textWithDelimiter.mutableCopy()
        for _ in 0..<numRepeats {
            repeated.appendAttributedString(textWithDelimiter)
        }
        return repeated as! NSAttributedString
    }

    private func startNextLoop() {
        let textLength = attributedText?.length ?? 0
        let text = (textLength > 0) ? attributedText! : NSAttributedString(string: "     ")
        let width = initialWidth

        leftLabel.attributedText = rightLabel.attributedText
        rightLabel.attributedText = repeatedText(text, toFillWidth: width)

        let rightLabelWidth = rightLabel.intrinsicContentSize().width
        let transform = CGAffineTransformMakeTranslation(rightLabelWidth, 0)
        leftLabel.transform = transform
        rightLabel.transform = transform

        let duration = NSTimeInterval(rightLabelWidth / width) * 3.0
        let options = UIViewAnimationOptions.CurveLinear
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
            self.leftLabel.transform = CGAffineTransformIdentity
            self.rightLabel.transform = CGAffineTransformIdentity
        }, completion: { finished in
            self.startNextLoop()
        })
    }
}
