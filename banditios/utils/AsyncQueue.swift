//
//  AsyncQueue.swift
//  banditios
//
//  Created by Graham Vaughn on 2/3/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AsyncQueue {
    private var queue: [AsyncQueueItem] = []
    private var queueRemovalReadyLock = BehaviorRelay<Bool>(value: true)
    private var idGen: Int = 1
    private let disposeBag = DisposeBag()
    
    func addExecution(_ action: @escaping ( @escaping () -> ()) -> ()) {
        var precedentCompleteObs: Observable<Bool> = Observable.just(true)
        if let lastItem = queue.last {
            precedentCompleteObs = lastItem.completionObs
        }
        let queueItem = AsyncQueueItem(action, waitFor: precedentCompleteObs, id: nextId())
        queue.append(queueItem)
        queueItem.completionObs.subscribeNext(weak: self) { strongSelf, isComplete in
            if isComplete {
                print("Item #\(queueItem.id) complete")
                strongSelf.dequeue(queueItem)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func nextId() -> Int {
        let next = idGen + 1
        idGen = next
        return next
    }
    
    private func dequeue(_ item: AsyncQueueItem) {
        guard let upId = queue.last?.id, item.id == upId else { return }
        let updatedQueue = Array<AsyncQueueItem>(queue.filter { !$0.isComplete })
        queue = updatedQueue
        print("Dequeue executed, new queue: \(self.desc())")
    }
    
    func desc() -> String {
        return queue.reduce("") { result, item in
            return "\(result), \(item.id)"
        };
    }
}
