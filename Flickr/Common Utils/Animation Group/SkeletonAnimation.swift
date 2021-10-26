//
//  SkeletonAnimation.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 29.09.2021.
//

import UIKit

// MARK: - SkeletonAnimationProtocol

protocol SkeletonAnimationProtocol {
    func startAnimationFor(view: UIView, cornerRadius: Bool)
    func stopAllAnimations()
}

// MARK: - SkeletonAnimation

final class SkeletonAnimation: SkeletonAnimationProtocol {
    
    private var gradientLayerArray: [CAGradientLayer] = .init()
    
    func startAnimationFor(view: UIView, cornerRadius: Bool = false) {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let gradientLayer: CAGradientLayer = .init()
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: -1.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 2.5, y: 0.75)
        gradientLayer.drawsAsynchronously = true
        
        let colors: [CGColor] = [UIColor.systemGray4.cgColor, UIColor.systemGray5.cgColor, UIColor.systemGray6.cgColor]
        gradientLayer.colors = colors.reversed()
        
        if cornerRadius {
            gradientLayer.cornerRadius = gradientLayer.frame.height / 2
            gradientLayer.masksToBounds = true
        }
        
        let locations: [NSNumber] = [0.0, 0.25, 1.0]
        gradientLayer.locations = locations
        view.layer.addSublayer(gradientLayer)
        
        let gradientAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        gradientAnimation.fromValue = [0.0, 0.0, 0.25]
        gradientAnimation.toValue = [0.75 ,1.0, 1.0]
        gradientAnimation.duration = 0.75
        gradientAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        gradientAnimation.repeatCount = .infinity
        gradientAnimation.autoreverses = true
        gradientAnimation.isRemovedOnCompletion = false
        
        gradientLayer.add(gradientAnimation, forKey: "gradientAnimation")
        gradientLayerArray.append(gradientLayer)
    }
    
    func stopAllAnimations() {
        gradientLayerArray.forEach { $0.removeFromSuperlayer() }
    }
    
}
