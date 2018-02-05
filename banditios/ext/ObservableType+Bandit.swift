//
//  ObservableType+Bandit.swift
//  banditios
//
//  Created by Graham Vaughn on 2/3/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

extension ObservableType {

    /**
     Subscribes an element handler to an observable sequence.
     
     - parameter weak: Weakly referenced object to pass as first argument to the handler
     - parameter onNext: Handler to invoke for each element in the observable sequence, passing `weak` as first argument.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    func subscribeNext<T: AnyObject>(weak observer: T, onNext: @escaping (T, E) -> Void) -> Disposable {
        return subscribe(onNext: weakify(observer, handler: onNext))
    }
    
    func weakify<T: AnyObject, V>(_ obj: T, handler: @escaping (T, V) -> Void) -> ((V) -> Void) {
        return { [weak obj] value in
            guard let obj = obj else { return }
            handler(obj, value)
        }
    }
    
    func weakify<T: AnyObject, V>(_ obj: T, handler: @escaping (T, V) throws -> Void) -> ((V) throws -> Void) {
        return { [weak obj] value in
            guard let obj = obj else { return }
            try handler(obj, value)
        }
    }
    
    func weakify<T: AnyObject>(_ obj: T, handler: @escaping (T) -> Void) -> (() -> Void) {
        return { [weak obj] in
            guard let obj = obj else { return }
            handler(obj)
        }
    }
    
    func weakify<T: AnyObject>(_ obj: T, handler: @escaping (T) throws -> Void) -> (() throws -> Void) {
        return { [weak obj] in
            guard let obj = obj else { return }
            try handler(obj)
        }
    }
    
    /**
     Leverages instance method currying to provide a weak wrapper around an instance function
     
     - parameter obj:    The object that owns the function
     - parameter method: The instance function represented as `InstanceType.instanceFunc`
     */
    func weakify<A: AnyObject, B>(_ obj: A, method: ((A) -> (B) -> Void)?) -> ((B) -> Void) {
        return { [weak obj] value in
            guard let obj = obj else { return }
            method?(obj)(value)
        }
    }
}

