//
//  RYSwipeViewBuffer.swift
//  Spirits
//
//  Created by DerekYuYi on 2019/4/16.
//  Copyright © 2019 RuiYu. All rights reserved.
//

/*
 Abstract: Encapsulates swipe cards animation.
 */

import UIKit

enum eRYSwipeDirection {
    case left
    case right
}


protocol RYSwipeViewBufferDelegate: NSObjectProtocol {
    
    func swipedCard(_ cardId: Int, from direction: eRYSwipeDirection)
    func swipeCardEmptied()
    func enabledSwipe() -> Bool
}

class RYSwipeViewBuffer: NSObject {
    
    // MARK: - Properties
    
    /// The property includes all cards, animations
    weak var parentView: UIView?
    
    weak var delegate: RYSwipeViewBufferDelegate?
    
    private var cards = [RYCardView]()
    
    /// The function of this property is to prevent tapping repeatly `like` or `dislike` buttons in a short duration.
    private var visibleCardsIsFinishedLayout: Bool = true
    
    /// UIKit dynamics variables that we need references to.
    private var dynamicAnimator: UIDynamicAnimator!
    private var cardAttachmentBehavior: UIAttachmentBehavior!
    
    /// Scale and alpha of successive cards visible to the user
    private let cardAttributes: [(downscale: CGFloat, alpha: CGFloat)] = [(1, 1), (0.92, 0.8), (0.84, 0.6), (0.76, 0.4)]
    private let cardInteritemSpacing: CGFloat = 15
    
    private var cardIsHiding = false
    
    /// Init with a backgroundView and as board of all cards.
    init(_ parentView: UIView?) {
        super.init()
        self.parentView = parentView
    }
    
    /// A public interface that support data source for the instance of RYSwipeViewBuffer and show it to cards.
    func update(_ cardDataSource: [RYTypeContentItem], typeDataItem: TypeDataItem?) {
        guard let parentView = parentView else { return }
        guard cardDataSource.count > 0 else { return }
        
        dynamicAnimator = UIDynamicAnimator(referenceView: parentView)
        dynamicAnimator.removeAllBehaviors()
        cards = [RYCardView]()
        
        // 1. create a deck of cards
        for i in 0..<cardDataSource.count {
            let card = RYCardView(frame: CGRect(x: 0, y: 0, width: parentView.frame.width - 60, height: parentView.frame.height * 0.6))
            cards.append(card)
            card.update(cardDataSource[i], dataTypeItem: typeDataItem)
        }
        
        // 2. layout cards: layout the first 4 cards for the user
        layoutCards()
    }
}

extension RYSwipeViewBuffer {
    
    private func layoutCards() {
        guard cards.count > 0 else { return }
        guard let parentView = parentView else { return }
        
        let firstCard = cards[0]
        parentView.addSubview(firstCard)
        firstCard.layer.zPosition = CGFloat(cards.count)
        firstCard.center = parentView.center
        
        firstCard.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleCardPan)))
        
        // the next 3 cards in the deck
        
        for i in 1...3 {
            if i > (cards.count - 1) { continue }
            
            let card = cards[i]
            
            card.layer.zPosition = CGFloat(cards.count - i)
            
            //
            let downscale = cardAttributes[i].downscale
            let alpha = cardAttributes[i].alpha
            card.transform = CGAffineTransform(scaleX: downscale, y: downscale)
            card.alpha = alpha
            
            // position
            card.center.x = parentView.center.x
            card.frame.origin.y = cards[0].frame.origin.y - (CGFloat(i) * cardInteritemSpacing)
            
            //
            if i == 3 {
                card.frame.origin.y += 1.5
            }
            
            parentView.addSubview(card)
        }
        
        // make sure that the first card in the deck is at the front
        parentView.bringSubviewToFront(cards[0])
    }
    
    /// adds the next card to the 4 visible cards and animates each card to move forward.
    private func showNextCard() {
        guard let parentView = parentView else { return }
        
        let animationDuration: TimeInterval = 0.2
        
        // 1. animate each card to move forward one by one
        for i in 1...3 {
            if i > (cards.count - 1) { continue }
            let card = cards[i]
            let newDownscale = cardAttributes[i - 1].downscale
            let newAlpha = cardAttributes[i - 1].alpha
            
            UIView.animate(withDuration: animationDuration, delay: (TimeInterval(i - 1) * (animationDuration / 2)), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                card.transform = CGAffineTransform(scaleX: newDownscale, y: newDownscale)
                card.alpha = newAlpha
                
                if i == 1 {
                    card.center = parentView.center
                } else {
                    card.center.x = parentView.center.x
                    card.frame.origin.y = self.cards[1].frame.origin.y - (CGFloat(i - 1) * self.cardInteritemSpacing)
                }
                
            }) { _ in
                if i == 1 {
                    card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPan)))
                }
            }
            
        }
        
        // 2. add a new card (now the 4th card in the deck) to the very back
        if 4 > (cards.count - 1) {
            if cards.count != 1 {
                parentView.bringSubviewToFront(cards[1])
            }
            return
        }
        
        let newCard = cards[4]
        newCard.layer.zPosition = CGFloat(cards.count - 4)
        let downscale = cardAttributes[3].downscale
        let alpha = cardAttributes[3].alpha
        
        // initial state of new card
        newCard.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        newCard.alpha = 0
        newCard.center.x = parentView.center.x
        newCard.frame.origin.y = cards[1].frame.origin.y - (4 * cardInteritemSpacing)
        parentView.addSubview(newCard)
        
        // set value before layout animations
        self.visibleCardsIsFinishedLayout = false
        
        // naimate to end state of new card
        UIView.animate(withDuration: animationDuration,
                       delay: (3 * (animationDuration / 2)),
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [],
                       animations: {
            newCard.transform = CGAffineTransform(scaleX: downscale, y: downscale)
            newCard.alpha = alpha
            newCard.center.x = parentView.center.x
            newCard.frame.origin.y = self.cards[1].frame.origin.y - (3 * self.cardInteritemSpacing) + 1.5
        }) { _ in
            self.visibleCardsIsFinishedLayout = true
        }
        
        // first card needs to be in the front for proper interactivity
        parentView.bringSubviewToFront(cards[1])
    }
    
    /// Whenever the front card is off the screen, this method is called in order to remove the card from our data structure and from the view.
    private func removeOldFrontCard() {
        
        guard cards.count > 0 else { return }
        
        // handle the last card and
        if cards.count == 1 {
            // perform delegate methods
            delegate?.swipeCardEmptied()
            
//            // remove from the superview
//            cards[0].removeFromSuperview()
//
//            // remove from the data source
//            cards.remove(at: 0)
            
//            return
        }
        
        // remove from the superview
        cards[0].removeFromSuperview()
        
        // remove from the data source
        cards.remove(at: 0)
    }
    
    /// This function continuously checks to see if the card's center is on the screen anymore. If it finds that card's center is not on screen, then it triggers removeOldFrontCard() which removes the front card from the data structure and from the view.
    private func hideFrontCard() {
        guard cards.count > 0 else { return }
        guard let parentView = parentView else { return }
        
        var cardRemoveTimer: Timer? = nil
        cardRemoveTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] _ in
            guard let strongSelf = self else { return }
            if !parentView.bounds.contains(strongSelf.cards[0].center) {
                cardRemoveTimer?.invalidate()
                strongSelf.cardIsHiding = true
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                    strongSelf.cards[0].alpha = 0.0
                }, completion: {[weak self] _ in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.removeOldFrontCard()
                    strongSelf.cardIsHiding = false
                })
            }
        })
    }
}


// MARK: - Pan Gesture Recognizer selector

extension RYSwipeViewBuffer {
    
    func swipe(from direction: eRYSwipeDirection) {
        
        guard cards.count > 0 else { return }
        guard visibleCardsIsFinishedLayout else { return }
        guard let swipeEnabled = delegate?.enabledSwipe(), swipeEnabled else { return }
        
        let cardView = cards[0]
        
        // 1. perform delegate methods
        if let cardID = cardView.data?.id {
            delegate?.swipedCard(cardID, from: direction)
        }
        
        // 2. prepare vector value which decides swipe direction
        var vector = CGVector(dx: 30, dy: 0)
        if direction == .right {
            cardView.showOptionImageView(option: .like)
            
        } else if direction == .left {
            cardView.showOptionImageView(option: .dislike)
            vector = CGVector(dx: -30, dy: 0)
        }
        
        // 3. remove animators
        dynamicAnimator.removeAllBehaviors()
        
        // 4. add pushBehavior
        showBehavior(by: vector)
        
        // 5. show next card
        showNextCard()
        
        // 6. remove front card
        hideFrontCard()
    }
    
    /// This method handles the swiping gesture on each card and shows the appropriate emoji based on the card's center.
    @objc func handleCardPan(sender: UIPanGestureRecognizer) {
        
        guard cards.count > 0 else { return }
        guard let parentView = parentView else { return }
        // if swipe is disenable, we cancel swipe operations
        guard let swipeEnabled = delegate?.enabledSwipe(), swipeEnabled else { return }
        
        if cardIsHiding { return }
        
        // distance user must pan right or left to trigger an option
        let requiredOffsetFromCenter: CGFloat = 100
        
        let panLocationInView = sender.location(in: parentView)
        let panLocationInCard = sender.location(in: cards[0])
        
        switch sender.state {
        case .began:
            
            dynamicAnimator.removeAllBehaviors()
            let offset = UIOffset(horizontal: panLocationInCard.x - cards[0].bounds.midX, vertical: panLocationInCard.y - cards[0].bounds.midY)
            
            cardAttachmentBehavior = UIAttachmentBehavior(item: cards[0], offsetFromCenter: offset, attachedToAnchor: panLocationInView)
            dynamicAnimator.addBehavior(cardAttachmentBehavior)
            
        case .changed:
            
            cardAttachmentBehavior.anchorPoint = panLocationInView
            
            if cards[0].center.x > (parentView.center.x + 15) { // right
                cards[0].showOptionImageView(option: .like)
                
            } else if cards[0].center.x < (parentView.center.x - 15) { // left
                cards[0].showOptionImageView(option: .dislike)
                
            } else {
                cards[0].hideOptionImageView()
            }
            
        case .ended:
            
            dynamicAnimator.removeAllBehaviors()
            
            // snap to center
            if !(cards[0].center.x > (parentView.center.x + 15) || cards[0].center.x < (parentView.center.x - 15)) {
                
                cards[0].hideOptionImageView()
                
                // snap to center
                let snapBehavior = UISnapBehavior(item: cards[0], snapTo: parentView.center)
                dynamicAnimator.addBehavior(snapBehavior)
                
            } else {

                let isLeftArea = cards[0].center.x < (parentView.center.x - requiredOffsetFromCenter)
                let isRightArea = cards[0].center.x > (parentView.center.x + requiredOffsetFromCenter)
                
                /// shows an area that don't remove cards
                let isHorizontalSafeArea = !(isLeftArea || isRightArea)
                
                if isHorizontalSafeArea {
                    
                    // hide imageview
                    cards[0].hideOptionImageView()
                    
                    // snap to center
                    let snapBehavior = UISnapBehavior(item: cards[0], snapTo: parentView.center)
                    dynamicAnimator.addBehavior(snapBehavior)
                    
                } else { // go to next card
                    
                    // perform delegate methods
                    
                    if let cardID = cards[0].data?.id {
                        if isLeftArea {
                            delegate?.swipedCard(cardID, from: .left)
                        } else if isRightArea {
                            delegate?.swipedCard(cardID, from: .right)
                        }
                    }
                    
                    // add behaviors
                    let velocity = sender.velocity(in: parentView)
                    showBehavior(by: CGVector(dx: velocity.x / 10, dy: velocity.y / 10))
                    
                    // show next card
                    showNextCard()
                    
                    // hide and remove front card
                    hideFrontCard()
                }
            }
            
        default:
            break
        }
    }
    
    private func showBehavior(by vector: CGVector) {
        
        let pushBehavior = UIPushBehavior(items: [cards[0]], mode: .instantaneous)
        pushBehavior.pushDirection = vector
        pushBehavior.magnitude = 175
        dynamicAnimator.addBehavior(pushBehavior)
        
        // spin after throwing
        var angular = CGFloat.pi / 2
        let currentAngle: Double = atan2(Double(cards[0].transform.b), Double(cards[0].transform.a))
        
        if currentAngle > 0 {
            angular = angular * 1
        } else {
            angular = angular * -1
        }
        
        let itemBehavior = UIDynamicItemBehavior(items: [cards[0]])
        itemBehavior.friction = 0.2
        //                    itemBehavior.allowsRotation = true
        itemBehavior.addAngularVelocity(CGFloat(angular), for: cards[0])
        dynamicAnimator.addBehavior(itemBehavior)
    }
}


// MARK: - Card item view

enum CardOption: String {
    case like
    case dislike
}


class RYCardView: UIView {
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = RYColors.color(from: 0x333333)
        label.font = UIFont(name: "PingFangSC-Medium", size: 18)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10.0
        
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        
        label.backgroundColor = nil
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Medium", size: 18)
        label.contentMode = .topLeft
        
        label.numberOfLines = 0
        
        return label
    }()
    
    private let likeStatusImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "star_gray"))
        
        return imageView
    }()
    
    /// gradientlayer
    private let gradientLayer: CAGradientLayer = {
        let graLayer = CAGradientLayer()
        graLayer.type = .axial
        return graLayer
    }()
    
    // datasource
    var data: RYTypeContentItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 79/255, green: 96/255, blue: 201/255, alpha: 1.0)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        
        let heightForHeaderLabel: CGFloat = 55
        let gap: CGFloat = 20.0
        let contentLabelTop: CGFloat = 30.0
        
        self.addSubview(headerLabel)
        headerLabel.frame = CGRect(x: gap, y: gap, width: frame.width - gap * 2, height: heightForHeaderLabel)
        
        self.addSubview(contentLabel)
        contentLabel.frame = CGRect(x: gap, y: headerLabel.frame.maxY + contentLabelTop, width: frame.width - gap * 2, height: frame.height - contentLabelTop - gap*2 - heightForHeaderLabel)
        
        self.addSubview(likeStatusImageView)
        let widthForLikeImageView: CGFloat = 64
        likeStatusImageView.frame = CGRect(x: 0, y: 0, width: widthForLikeImageView, height: widthForLikeImageView)
        likeStatusImageView.center = CGPoint(x: center.x, y: frame.height - widthForLikeImageView)
        likeStatusImageView.isHidden = true
        likeStatusImageView.contentMode = .center // fit image
        likeStatusImageView.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        likeStatusImageView.roundedCorner(nil, widthForLikeImageView / 2.0)
    }
    
    func update(_ typeContentItem: RYTypeContentItem, dataTypeItem: TypeDataItem?) {
        headerLabel.text = typeContentItem.title
        contentLabel.text = typeContentItem.content
        contentLabel.sizeToFit()
        
        // init gradientlayer
        if let dataTypeItem = dataTypeItem {
            gradientLayer.frame = bounds
            gradientLayer.colors = [dataTypeItem.startColor.cgColor, dataTypeItem.endColor.cgColor]
            layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // record datasource
        data = typeContentItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showOptionImageView(option: CardOption) {
        
        switch option {
        case .like:
            
            if likeStatusImageView.isHidden {
                likeStatusImageView.alpha = 0
                likeStatusImageView.isHidden = true
                self.likeStatusImageView.image = UIImage(named: "collect")
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.likeStatusImageView.alpha = 1
                }) { _ in
                    self.likeStatusImageView.isHidden = false
                }
            }
            
        case .dislike:
            
            if likeStatusImageView.isHidden {
                likeStatusImageView.alpha = 0
                likeStatusImageView.isHidden = true
                self.likeStatusImageView.image = UIImage(named: "delete_orange")
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.likeStatusImageView.alpha = 1
                }) { _ in
                    self.likeStatusImageView.isHidden = false
                }
            }
        }
    }
    
    func hideOptionImageView() {
        // fade out likeStatusImageView
        if !likeStatusImageView.isHidden {
            UIView.animate(withDuration: 0.15, animations: {
                self.likeStatusImageView.alpha = 0
            }, completion: { (_) in
                self.likeStatusImageView.isHidden = true
            })
        }
    }
}

