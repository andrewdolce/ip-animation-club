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
        createTapRecognizer()
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
        cardView.backgroundColor = UIColor.yellowColor()
        return cardView
    }

    private func addCardViewToBackOfStack(cardView: UIView) {
        cardViewsInStack.append(cardView)

        cardView.frame = cardContainerView.bounds
        cardContainerView.insertSubview(cardView, atIndex: 0)

        let margins = self.cardContainerView.layoutMarginsGuide
        cardView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
        cardView.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
        cardView.topAnchor.constraintEqualToAnchor(margins.topAnchor).active = true
        cardView.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor).active = true

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
        guard let frontCardView = cardViewsInStack.first else {
            return
        }

        throwCardView(frontCardView)

        // Add the next card
        let newIndex = (currentIndex + numberOfCardsToShow) % cards.count
        let newCardView = cardViewForIndex(newIndex)
        addCardViewToBackOfStack(newCardView)

        // Advance the current index
        currentIndex += 1

        // Animate and update the stack
        newCardView.transform = CGAffineTransformMakeScale(0.8, 0.8)


        let newStack = Array(cardViewsInStack[1..<cardViewsInStack.count])

        UIView.animateWithDuration(0.5, animations: {
            // Animate cards forward in stack
            self.configureUIForCardsInStack(newStack)
        }, completion: { finished in
            frontCardView.removeFromSuperview()
            self.cardViewsInStack = newStack
        })
    }

    private func throwCardView(cardView: UIView) {
        let thrownTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(CGFloat(M_1_PI) / 4.0), 400, 0)
        UIView.animateWithDuration(0.5) {
            cardView.transform = thrownTransform
        }
    }

    // MARK: Gestures

    private func createTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTapCards:")
        cardContainerView.addGestureRecognizer(tapRecognizer)
    }

    dynamic private func didTapCards(recognizer: UITapGestureRecognizer) {
        animateToNextCard()
    }
}





