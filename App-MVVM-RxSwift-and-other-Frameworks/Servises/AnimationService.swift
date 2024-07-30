//
//  AnimationService.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 30.07.2024.
//

import UIKit

final class AnimationService {

    static func contraction(mask: CAShapeLayer, view: UIView, completion: @escaping () -> Void) {
        
        let coefficientContraction: CGFloat = 1.2
        let centerX = view.bounds.midX
        let centerY = view.bounds.midY
        let maskHeight = view.bounds.height * coefficientContraction
        let maskWidht = view.bounds.height * coefficientContraction
        let maskX = centerX - maskWidht / 2
        let maskY = centerY - maskHeight / 2
        
        let initialPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: maskX,
                                                                      y: maskY),
                                                      size: CGSize(width: maskWidht,
                                                                   height: maskHeight)))
        let finalPath = UIBezierPath(ovalIn: CGRect(x: centerX,
                                                    y: centerY,
                                                    width: 0,
                                                    height: 0))
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { completion() }
        animate(mask: mask, initialPath: initialPath, finalPath: finalPath)
        CATransaction.commit()
    }
    
    static func expansion(mask: CAShapeLayer, view: UIView, completion: @escaping () -> Void) {
        
        let coefficientExpansion: CGFloat = 1.2
        let centerX = view.bounds.midX
        let centerY = view.bounds.midY
        let maskHeight = view.bounds.height * coefficientExpansion
        let maskWidht = view.bounds.height * coefficientExpansion
        let maskX = centerX - maskWidht / 2
        let maskY = centerY - maskHeight / 2
        
        let initialPath = UIBezierPath(ovalIn: CGRect(x: centerX,
                                                      y: centerY,
                                                      width: 0,
                                                      height: 0))
        let finalPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: maskX,
                                                                    y: maskY),
                                                    size: CGSize(width: maskWidht,
                                                                 height: maskHeight)))
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { completion() }
        animate(mask: mask, initialPath: initialPath, finalPath: finalPath)
        CATransaction.commit()
    }
    
    static private func animate(mask: CAShapeLayer, initialPath: UIBezierPath, finalPath: UIBezierPath) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = initialPath.cgPath
        animation.toValue = finalPath.cgPath
        animation.duration = 2.0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        mask.add(animation, forKey: "pathAnimation")
    }
    
    static func animationOfInformation(display: UIView) {
        display.alpha = 0.0
        UIView.animate(withDuration: 0.3) {
            display.alpha = 1.0
        }
    }
    
    static func animationOfInformation(hiding: UIView) {
        UIView.animate(withDuration: 0.3) {
            hiding.alpha = 0.0
        } completion: { isFinish in
            hiding.removeFromSuperview()
        }
    }
}

