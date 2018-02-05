//
//  GoTimeGroup.swift
//  banditios
//
//  Created by Graham Vaughn on 1/21/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class GoTimeGroup {
    private let goTimes = Chain<GoTime>()
    private let publisher = ReplaySubject<GoTimeGroup>.createUnbounded()
    var valueChangedObs: Observable<GoTimeGroup> {
        return publisher.asObserver()
    }
    
    var items: [GoTime] {
        return goTimes.list()
    }
    
    var isEmpty: Bool {
       return goTimes.head == nil
    }
    
    init(goTimes: [GoTime]?) {
        self.goTimes.setValues(goTimes ?? [])
        publisher.on(.next(self))
    }
    
    func add(_ goTime: GoTime) {
        goTimes.add(goTime)
        publisher.on(.next(self))
    }
    
    func current() -> GoTime? {
        return goTimes.peek()
    }
    
    func stop() {
        goTimes.end()
        publisher.on(.next(self))
    }
}
