//
//  ViewController.swift
//  ADolceSwipeableCards
//
//  Created by Andrew Dolce on 1/21/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import IntrepidSwiftWisdom

class ViewController: UIViewController {

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!

    @IBOutlet weak var cardContainerView: UIView!

    private var cards = [Card]()
    private var cardViewsInStack = [UIView]()
    private var flyingCardView: UIView? = nil

    private var currentIndex: Int = 0
    private var numberOfCardsToShow: Int {
        return min(cards.count, 3)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createTestCards()
        createCardViews()
        createPanRecognizer()
    }

    private func createTestCards() {
        cards = [
            Card(image: UIImage(named: "album0")),
            Card(image: UIImage(named: "album1")),
            Card(image: UIImage(named: "album2")),
            Card(image: UIImage(named: "album3")),
            Card(image: UIImage(named: "album4"))
        ]
    }

    private func createCardViews() {
        currentIndex = 0

        for index in 0..<numberOfCardsToShow {
            let cardView = cardViewForIndex(index)
            addCardViewToBackOfStack(cardView)
        }

        configureUIForCardsInStack(cardViewsInStack)
    }

    private func cardViewForIndex(index: Int) -> UIView {
        let card = cards[index];

        // TODO: LOAD FROM XIB
        let cardView = CardView.ip_fromNib("CardView")
        cardView.image = card.image
        cardView.overlayAlpha = 0.7

        return cardView
    }

    private func addCardViewToBackOfStack(cardView: UIView) {
        cardViewsInStack.append(cardView)

        cardView.frame = cardContainerView.bounds
        cardContainerView.insertSubview(cardView, atIndex: 0)

//        let margins = self.cardContainerView.layoutMarginsGuide
//        cardView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
//        cardView.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
//        cardView.topAnchor.constraintEqualToAnchor(margins.topAnchor).active = true
//        cardView.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor).active = true

        cardContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cardView]|", options: [], metrics: nil, views: [ "cardView" : cardView ]))
        cardContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[cardView]|", options: [], metrics: nil, views: [ "cardView" : cardView ]))

        cardView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureUIForCardsInStack(cardViews: [UIView]) {
        setTransformsOnCardsInStack(cardViews)

        let frontCard = cardViews.first as? CardView
        switchToBackgroundImage(frontCard?.image)
    }

    private func setTransformsOnCardsInStack(cardViews: [UIView]) {
        let transformsFrontToBack = [
            CGAffineTransformIdentity,
            CGAffineTransformTranslate(CGAffineTransformMakeScale(0.9, 0.9), 0, -40),
            CGAffineTransformTranslate(CGAffineTransformMakeScale(0.8, 0.8), 0, -80),
        ]

        for (index, cardView) in cardViews.enumerate() {
            cardView.transform = transformsFrontToBack[index]
        }

        if let frontCard = cardViews.first as? CardView {
            frontCard.overlayAlpha = 0
        }
    }

    private func switchToBackgroundImage(image: UIImage?) {
        backImageView.image = image
        backImageView.alpha = 1.0
        frontImageView.alpha = 0.0
        swap(&backImageView, &frontImageView)
    }

    private func animateToNextCard() {
        // Add the next card
        let newIndex = (currentIndex + numberOfCardsToShow) % cards.count
        let newCardView = cardViewForIndex(newIndex)
        addCardViewToBackOfStack(newCardView)

        // Advance the current index
        currentIndex += 1

        // Animate and update the stack
        newCardView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(0.8, 0.8), 0, -40)

        let newStack = Array(cardViewsInStack[1..<cardViewsInStack.count])

        UIView.animateWithDuration(0.5, animations: {
            // Animate cards forward in stack
            self.configureUIForCardsInStack(newStack)
        }, completion: { finished in
            self.cardViewsInStack = newStack
        })
    }

    private func throwCardView(cardView: UIView, offset: CGPoint, velocity: CGPoint, minSpeed: CGFloat) {
        let currentSpeed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        let useVelocityDirection = currentSpeed > minSpeed / 2

        let direction = useVelocityDirection ? velocity : offset
        let directionMagnitude = sqrt(direction.x * direction.x + direction.y * direction.y)

        guard directionMagnitude > 0 else {
            return
        }

        let normalizedDirection = CGPointMake(direction.x / directionMagnitude, direction.y / directionMagnitude)
        let throwSpeed = max(currentSpeed, minSpeed)
        let throwDuration = 0.5
        let throwDistance = throwSpeed * CGFloat(throwDuration)
        let throwTranslation = CGPointMake(normalizedDirection.x * throwDistance, normalizedDirection.y * throwDistance)

        print("Velocity: \(velocity)")
        print("Offset: \(offset)")
        print("Speed: \(currentSpeed)")
        print("Min Speed: \(minSpeed)")
        print("Use velocity ? : \(useVelocityDirection)")
        print("Throw direction : \(normalizedDirection)")
        print("Throw translation : \(throwTranslation)")

        let throwRotation = CGFloat(M_PI / 6)

        var throwTransform = CGAffineTransformMakeTranslation(throwTranslation.x + offset.x, throwTranslation.y + offset.y)
        throwTransform = CGAffineTransformRotate(throwTransform, throwRotation)

        print("Transform : \(throwTransform)")
//
//        let currentTransform = CGAffineTransformMake(cardView.transform.a, cardView.transform.b, cardView.transform.c, cardView.transform.d, cardView.transform.tx, cardView.transform.ty)
//        let finalTransform = CGAffineTransformConcat(currentTransform, throwTransform)
//        print("Concatenated : \(finalTransform)")

        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveLinear], animations: {
            cardView.transform = throwTransform
        }, completion: { finished in
            cardView.removeFromSuperview()
        })
    }

    // MARK: Gestures

    private func createTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTapCards:")
        cardContainerView.addGestureRecognizer(tapRecognizer)
    }

    dynamic private func didTapCards(recognizer: UITapGestureRecognizer) {
        animateToNextCard()
    }

    private func createPanRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "didPanCard:")
        cardContainerView.addGestureRecognizer(panRecognizer)
    }

    dynamic private func didPanCard(recognizer: UIPanGestureRecognizer) {
        guard let frontCard = cardViewsInStack.first else {
            return
        }

        let translation = recognizer.translationInView(cardContainerView)
        print("translation = \(translation)")


        let distance = sqrt(translation.x * translation.x + translation.y * translation.y)
        let distanceThreshold = CGRectGetWidth(cardContainerView.bounds) * 0.5
        let distanceFraction = distance / max(distanceThreshold, 0.01)

        let maxRotation = CGFloat(M_PI) / 12.0
        let rotation = maxRotation * min(distanceFraction, 1)

        let translationTransform = CGAffineTransformMakeTranslation(translation.x, translation.y)
        let transform = CGAffineTransformRotate(translationTransform, rotation)

        let minOffscreenDistance = max(CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds))
        let throwDuration = 1.0
        let minSpeed = minOffscreenDistance / CGFloat(throwDuration)

        print("*****")
//        print("translation: \(translationTransform)")
        print("translation + rotation: \(transform)")

//        frontCard.layer.anchorPoint = CGPointMake(0.5, 0.5)
        frontCard.transform = transform

        if recognizer.state == .Ended {

            let velocity = recognizer.velocityInView(cardContainerView)

            let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            let speedTreshold = minSpeed

            let isFarEnoughForThrow = distance > distanceThreshold
            let isFastEnoughForThrow = speed > speedTreshold

            if isFarEnoughForThrow || isFastEnoughForThrow {
                throwCardView(frontCard, offset: translation, velocity: velocity, minSpeed: minSpeed)
                animateToNextCard()
            } else {
                UIView.animateWithDuration(0.5) {
                    frontCard.transform = CGAffineTransformIdentity
                }
            }
        }
    }
}





