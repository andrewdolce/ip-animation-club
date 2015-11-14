//
//  ViewController.swift
//  ADolceSocialTunesSharer
//
//  Created by Andrew Dolce on 11/14/15.
//  Copyright © 2015 Intrepid Pursuits. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var bottomViewLeading: NSLayoutConstraint!

    @IBOutlet weak var shareContainerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        close(animated: true)
    }

    // MARK: - Animations

    private func open(animated animated: Bool) {
        topViewTrailing.constant = 0
        layout(animated: animated)
    }

    private func close(animated animated: Bool) {
        topViewTrailing.constant = CGRectGetWidth(shareContainerView.bounds)
        layout(animated: animated)
    }

    private func layout(animated animated: Bool) {
        if animated {
            shareContainerView.userInteractionEnabled = false
            UIView.animateWithDuration(0.5, animations:{
                self.view.layoutIfNeeded()
            }, completion: { completed in
                self.shareContainerView.userInteractionEnabled = true
            })
        } else {
            self.view.layoutIfNeeded()
        }
    }
}
