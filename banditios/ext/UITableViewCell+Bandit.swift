//
//  UITableViewCell+Bandit.swift
//  banditios
//
//  Created by Graham Vaughn on 2/10/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Key value for objc_getAssociatedObject storage of reuseDisposeBag
private var prepareForReuseBag: Int8 = 0

extension UITableViewCell {
    
    /// Provides a means of disposal for subscriptions to observable sequences
    /// associated with a reusable cell. Subscriptions will be disposed of as needed
    /// prior to cell reuse.
    /// - parameter disposable: Disposable associated with this reuasable table cell.
    func disposeOnReuse(_ disposable: Disposable) {
        disposable.disposed(by: reuseDisposeBag)
    }
    
    // DisposeBag that will be disposed prior to reuse of this table cell, preventing duplicate subscriptions
    // to observable sequences.
    // See discussion: https://github.com/ReactiveX/RxSwift/issues/821
    var reuseDisposeBag: DisposeBag {
        MainScheduler.ensureExecutingOnScheduler()
        
        if let bag = objc_getAssociatedObject(self, &prepareForReuseBag) as? DisposeBag {
            return bag
        }
        
        let bag = DisposeBag()
        objc_setAssociatedObject(self, &prepareForReuseBag, bag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        _ = rx.sentMessage(#selector(prepareForReuse))
            .subscribe(onNext: { [weak self] _ in
                let newBag = DisposeBag()
                objc_setAssociatedObject(self as Any, &prepareForReuseBag, newBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            })
        
        return bag
    }
}
