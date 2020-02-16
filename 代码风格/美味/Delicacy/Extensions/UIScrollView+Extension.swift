//
//  UIScrollView+Extension.swift
//  Delicacy
//
//  Created by DerekYuYi on 2018/11/8.
//  Copyright © 2018 RuiYu. All rights reserved.
//

import Foundation
import UIKit
//import RxSwift
//import RxCocoa

private let kRYTagForActivityView: Int = 10034
private let kRYTagForAnimationView: Int = 10055
private let kRYCountForAnimationsImage: Int = 10

private let kRYSizeImage: CGFloat = 88
private let kRYMarginImage: CGFloat = 70

extension UIScrollView {
    func activityIndicator(for type: eRYDataListLoadingType, description text: String? = nil, handler tapHandler: (() -> Void)? = nil) -> UIView? {
        switch type {
        case .none:
            return nil
        
        case .loading:
            let activityView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: kRYSizeImage + kRYMarginImage * 2))
            activityView.tag = kRYTagForActivityView
            activityView.backgroundColor = .clear
            
            // create a shuffled images names
            let imageSeq = randomAnimationImagesCount(kRYCountForAnimationsImage)
            
            // load shuffled images to array
            let totalAnimateImages = kRYCountForAnimationsImage
            var animationImages: [UIImage] = []
            
            let animationView = UIImageView(frame: CGRect(x: 0, y: 0, width: kRYSizeImage, height: kRYSizeImage))
            for k in 0..<totalAnimateImages {
                if k < imageSeq.count {
                    let imageNameIndex = imageSeq[k]
                    let imageName = "networkLoading\(imageNameIndex)"
                    if let image = UIImage(named: imageName) {
                        animationImages.append(image)
                    }
                }
            }
            animationView.animationImages = animationImages
            animationView.animationDuration = 5
            animationView.tag = kRYTagForAnimationView
            animationView.center = activityView.center
            
            activityView.addSubview(animationView)
            RYUITweaker.addConstraints(for: CGPoint(x: 0, y: 0), for: animationView, in: activityView, related: activityView)
            
            animationView.startAnimating()
            
            return activityView
            
        case .zeroData, .notReachable, .error:
            if let views = Bundle.main.loadNibNamed("RYNetworkTipsView", owner: nil, options: nil),
                let activityView = views.first as? RYNetworkTipsView {
                activityView.backgroundColor = .clear
                activityView.statusImageView.image = UIImage(named: "networkError")
                activityView.statusLabel.text = text
                let size = activityView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                activityView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                // action
                if let tapHandler = tapHandler {
                    activityView.retryButton.isHidden = false
                    activityView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
                    activityView.tapClosure = tapHandler
                } else {
                    activityView.retryButton.isHidden = true
                }
                
                return activityView
            }
            
            return nil
        }
        
    }
    
    @objc func retryButtonTapped() {
        
    }
    
    private func randomAnimationImagesCount(_ count: Int) -> [Int] {
        var imageSeq: [Int] = []
        for k in 1...count { // initialize
            imageSeq.append(k)
        }
        
        for j in 0..<count { // shuffle
            let randomIndex = arc4random_uniform(UInt32(count)) % UInt32(count)
            imageSeq.swapAt(Int(randomIndex), j)
        }
        return imageSeq
    }
}
