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
//import UIKit
import RxDataSources

class GoTimeGroup: AnimatableSectionModelType {
    typealias Identity = Int
    private let goTimes = Chain<GoTime>()
    private let publisher = PublishRelay<GoTimeGroup>()
    
    var items: [GoTime] {
        return goTimes.list()
    }
    
    var identity : Identity {
        return 0
    }
    
    var valueChangedObs: Observable<GoTimeGroup> {
        return publisher.asObservable()
    }
    
    convenience init(goTimes: [GoTime]?) {
        let values = goTimes ?? []
        self.init(original: self, items: values)
    }
    
    required init(original: GoTimeGroup, items: [GoTime]) {
        self.goTimes.setValues(items)
    }
    
    func add(_ goTime: GoTime) {
        goTimes.add(goTime)
        publisher.accept(self)
    }
    
    func current() -> GoTime? {
        return goTimes.peek()
    }
    
    func stop() {
        goTimes.end()
    }
}
