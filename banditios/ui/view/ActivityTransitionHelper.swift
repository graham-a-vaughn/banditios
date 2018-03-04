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
    private static let animationQueue = DispatchQueue(label: "com.vaughn.banditios.activityTransitionQueue")
    private static let defaultDuration: TimeInterval = 1.0
    
    private let showAlpha: CGFloat
    private let hideAlpha: CGFloat
    private let duration: TimeInterval
    
    private var queue: DispatchQueue {
        return ActivityTransitionHelper.animationQueue
    }
    
    private var defaultDuration: TimeInterval {
        return ActivityTransitionHelper.defaultDuration
    }
    
    required init(_ show: CGFloat, _ hide: CGFloat, duration: TimeInterval) {
        self.showAlpha = show
        self.hideAlpha = hide
        self.duration = duration
    }
    
    convenience init() {
        self.init(1.0, 0.0, duration: ActivityTransitionHelper.defaultDuration)
    }
    
    func showElement(_ transitionView: UIView) {
        _ = show(transitionView)
    }
    
    func hideElement(_ transitionView: UIView) {
        _ = hide(transitionView)
    }
    
    private func show(_ transitionView: UIView) -> Bool {
        queue.sync  {
            UIView.animate(withDuration: duration) {
                transitionView.alpha = self.showAlpha
            }
        }
        return true
    }
    
    private func hide(_ transitionView: UIView) -> Bool {
        queue.sync {
            UIView.animate(withDuration: duration) {
                transitionView.alpha = self.hideAlpha
            }
        }
        return true
    }
}
