//
//  ContainerViewController.swift
//  ASDBoardingPass
//
//  Created by Andrew Dolce on 12/12/15.
//  Copyright © 2015 Intrepid Pursuits. All rights reserved.
//

import UIKit

enum TransitionAnimationStyle {
    case None
    case Push
    case Pop
}

class ContainerViewController: UIViewController {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var leftButton: FancyButton!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var marqueeView: MarqueeView!
    
    private var unpushedRoot: UIViewController? = nil
    private var viewControllers = [UIViewController]()

    init(rootViewController: UIViewController) {
        unpushedRoot = rootViewController
        super.init(nibName: "ContainerViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let root = unpushedRoot {
            pushViewController(root, animated: false)
            unpushedRoot = nil
        }

        leftButton.setImage(mapImage())
        leftButton.action = leftButtonPressed
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // 197 95
        // 244 231 106
        let white = UIColor.whiteColor()
        let orange = UIColor(red: 251.0/255, green: 197.0/255, blue: 95.0/255, alpha: 1.0)
        let yellow = UIColor(red: 244.0/255, green: 231.0/255, blue: 106.0/255, alpha: 1.0)
        let blue = UIColor(red: 88.0/255, green: 206.0/255, blue: 245.0/255, alpha: 1.0)
        let attributedStrings = [
            NSAttributedString(string: "FLIGHT:", attributes: [NSForegroundColorAttributeName: white]),
            NSAttributedString(string: "AA1234   ", attributes: [NSForegroundColorAttributeName: orange]),
            NSAttributedString(string: "DEST:", attributes: [NSForegroundColorAttributeName: white]),
            NSAttributedString(string: "DFW   ", attributes: [NSForegroundColorAttributeName: yellow]),
            NSAttributedString(string: "GATE:", attributes: [NSForegroundColorAttributeName: white]),
            NSAttributedString(string: "2   ", attributes: [NSForegroundColorAttributeName: orange]),
            NSAttributedString(string: "BOARDING:", attributes: [NSForegroundColorAttributeName: white]),
            NSAttributedString(string: "2HR 26MIN   ", attributes: [NSForegroundColorAttributeName: blue]),
            NSAttributedString(string: "DEPARTS:", attributes: [NSForegroundColorAttributeName: white]),
            NSAttributedString(string: "11:56 PM   " , attributes: [NSForegroundColorAttributeName: blue]),
            NSAttributedString(string: "ARRIVES:", attributes: [NSForegroundColorAttributeName: white]),
            NSAttributedString(string: "3:52 PM   ", attributes: [NSForegroundColorAttributeName: blue])
        ]
        let text = NSMutableAttributedString()
        for substring in attributedStrings {
            text.appendAttributedString(substring)
        }

        marqueeView.attributedText = text
        marqueeView.startAnimating()
    }

    // MARK: - Actions

    func leftButtonPressed() {
        if viewControllers.last as? TicketViewController != nil {
            popViewController(animated: true)
            leftButton.setImage(mapImage(), animated: true)
        } else {
            let ticketVC = TicketViewController(nibName: "TicketViewController", bundle: nil)
            pushViewController(ticketVC, animated: true)
            leftButton.setImage(ticketImage(), animated: true)
        }
    }

    // MARK: - Button

    func ticketImage() -> UIImage? {
        return UIImage(named: "close")
    }

    func mapImage() -> UIImage? {
        let insets = UIEdgeInsetsMake(0, 2, 0, 2)
        return UIImage(named: "barcode")?.resizableImageWithCapInsets(insets)
    }

    // MARK: - Transitions

    func pushViewController(viewController: UIViewController, animated: Bool) {
        if let topViewController = viewControllers.last {
            let style: TransitionAnimationStyle = animated ? .Push : .None
            switchFromChild(topViewController, toViewController: viewController, style: style)
        } else {
            addChild(viewController)
        }

        viewControllers.append(viewController)
    }

    func popViewController(animated animated: Bool) {
        guard let child = viewControllers.popLast() else {
            return
        }

        if let topViewController = viewControllers.last {
            let style: TransitionAnimationStyle = animated ? .Pop : .None
            switchFromChild(child, toViewController: topViewController, style: style)
        } else {
            removeChild(child)
        }
    }

    private func addChild(child: UIViewController) {
        addChildViewController(child)
        contentContainer.addSubview(child.view)
        child.view.constrainToFillSuperview()
        child.didMoveToParentViewController(self)
    }

    private func removeChild(child: UIViewController) {
        child.willMoveToParentViewController(nil)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
    }

    private func switchFromChild(fromViewController: UIViewController, toViewController: UIViewController, style: TransitionAnimationStyle) {
        fromViewController.willMoveToParentViewController(nil)

        contentContainer.addSubview(toViewController.view)
        toViewController.view.constrainToFillSuperview()

        let finish: () -> Void = {
            fromViewController.view.removeFromSuperview()
            fromViewController.removeFromParentViewController()

            toViewController.didMoveToParentViewController(self)
        }

        // Refactor this
        switch style {
        case .None:
            finish()
        case .Push:
            performPushAnimation(fromViewController: fromViewController, toViewController: toViewController, completion: finish)
        case .Pop:
            performPopAnimation(fromViewController: fromViewController, toViewController: toViewController, completion: finish)
        }
    }

    private let transitionDuration = 0.5

    private func topViewOffscreenTransform() -> CGAffineTransform {
        return CGAffineTransformMakeTranslation(0, -CGRectGetHeight(view.bounds))
    }
    private func bottomViewOffscreenTransform() -> CGAffineTransform {
        return CGAffineTransformMakeScale(0.8, 0.8)
    }

    private func performPushAnimation(fromViewController fromViewController: UIViewController, toViewController: UIViewController, completion: () -> Void) {
        let fromView = fromViewController.view
        let toView = toViewController.view

        contentContainer.bringSubviewToFront(toView)
        contentContainer.sendSubviewToBack(fromView)
        tintView.alpha = 0

        toView.transform = topViewOffscreenTransform()

        UIView.animateWithDuration(transitionDuration, animations: {
            fromView.transform = self.bottomViewOffscreenTransform()
            toView.transform = CGAffineTransformIdentity
            self.tintView.alpha = 1
        }, completion: { finished in
            completion()
        })
    }

    private func performPopAnimation(fromViewController fromViewController: UIViewController, toViewController: UIViewController, completion: () -> Void) {
        let fromView = fromViewController.view
        let toView = toViewController.view

        contentContainer.bringSubviewToFront(fromView)
        contentContainer.sendSubviewToBack(toView)
        tintView.alpha = 1

        toView.transform = bottomViewOffscreenTransform()
        UIView.animateWithDuration(transitionDuration, animations: {
            fromView.transform = self.topViewOffscreenTransform()
            toView.transform = CGAffineTransformIdentity
            self.tintView.alpha = 0
        }, completion: { finished in
            completion()
        })
    }
}

extension UIView {
    // Helpers
    func constrainToFillSuperview() {
        guard let superview = superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        frame = superview.bounds

        let options = NSLayoutFormatOptions()
        let views = ["child": self]
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[child]|", options: options, metrics: nil, views: views))
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[child]|", options: options, metrics: nil, views: views))
    }
}