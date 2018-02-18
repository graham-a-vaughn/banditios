//
//  ActivityTransitionHelper.swift
//  banditios
//
//  Created by Graham Vaughn on 2/4/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ActivityTransitionHelper {
    private let animationQueue = DispatchQueue(label: "com.vaughn.banditios.activityTransitionQueue")
    private let readyBlinkQueue = DispatchQueue(label: "com.vaughn.banditios.readyBlinkQueue")
    private let spinoffQueue = DispatchQueue(label: "com.vaughn.banditios.spinoffQueue")
    
    private var blinking = BehaviorRelay<CGFloat>(value: 1.0)
    private var blinkTimer: Timer? = nil
    
    func startActivityTransition(_ transitionView: UIView, _ duration: TimeInterval? = 1.0 ) {
        _ = show(transitionView)
    }
    
    private func show(_ transitionView: UIView, _ duration: TimeInterval? = 1.0) -> Bool {
        animationQueue.sync  {
            UIView.animate(withDuration: duration ?? 1.0) {
                transitionView.alpha = 1.0
            }
        }
        return true
    }
    
    private func hide(_ transitionView: UIView, _ duration: TimeInterval? = 1.0) -> Bool {
        animationQueue.sync {
            UIView.animate(withDuration: duration ?? 1.0) {
                transitionView.alpha = 0.0
            }
        }
        return true
    }
    
    
    func endActivityTransition(_ transitionView: UIView, _ duration: TimeInterval? = 1.0) {
        _ = hide(transitionView, duration ?? 1.0)
    }
    
    func showReadyLabel(_ label: UILabel) -> Bool {
        animationQueue.sync {
            UIView.animate(withDuration: 0.5) {
                label.alpha = 1.0
            }
        }
        return true
    }
    
    func hideReadyLabel(_ label: UILabel) -> Bool {
        animationQueue.sync {
            UIView.animate(withDuration: 0.25) {
                label.alpha = 0.0
            }
        }
        return true
    }
    
    func blinkReadyLabel(_ label: UILabel, _ duration: TimeInterval? = 1.0) -> Bool {
        guard self.blinkTimer == nil else { return false }
        let blinkTimer = Timer.scheduledTimer(withTimeInterval: duration ?? 1.0, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            UIView.animate(withDuration: duration ?? 1.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                label.alpha = strongSelf.blinkAlpha()
                
            }, completion: nil)
        }
        
        self.blinkTimer = blinkTimer
        
        
        return true
    }
    
    func blink(_ view: UIView, _ duration: TimeInterval? = 1.0) -> Disposable {
        return MainScheduler.instance.schedulePeriodic(view, startAfter: 0, period: 1.0) { [weak self] view in
            guard let strongSelf = self else { return view }
            
            UIView.animate(withDuration: duration ?? 1.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                view.alpha = strongSelf.blinkAlpha()
            }, completion: nil)
            return view
        }
    }
    
    private func blinkAlpha() -> CGFloat {
        let current = blinking.value
        let next: CGFloat = current == 1.0 ? 0.0 : 1.0
        blinking.accept(next)
        return next
    }
    func stopBlinkingReadyLabel() {
        blinkTimer?.invalidate()
    }
}
