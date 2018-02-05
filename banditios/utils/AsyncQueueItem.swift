//
//  AsyncQueueItem.swift
//  banditios
//
//  Created by Graham Vaughn on 2/3/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AsyncQueueItem {
    
    // TODO: Doc cases:
    // 1) needs to broadcast all past & future events
    // 2) needs to supply multiple independant subscriptions
    let id: Int
    private let completionPublisher = ReplaySubject<Bool>.createUnbounded()
    private let completionState = BehaviorRelay<Bool>(value: false)
    private let precendentDisposable = SerialDisposable()
    private let disposeBag = DisposeBag()
    
    var completionObs: Observable<Bool> {
        return completionPublisher.asObservable()
    }
    
    var isComplete: Bool {
        return completionState.value
    }
    
    init(_ action: @escaping ( @escaping () -> ()) -> (), waitFor: Observable<Bool>, id: Int) {
        self.id = id
        disposeBag.insert(precendentDisposable)
        completionPublisher.onNext(false)
        
        precendentDisposable.disposable = waitFor.subscribeNext(weak: self) { strongSelf, precedentComplete in
            if precedentComplete {
                action() { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.completionPublisher.onNext(true)
                    strongSelf.completionState.accept(true)
                }
            }
        }
    }
}
