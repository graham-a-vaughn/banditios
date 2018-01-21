//
//  GoTime.swift
//  banditios
//
//  Created by Graham Vaughn on 1/17/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import RxDataSources

class GoTime {
    var type: GoTimeType
    var start: Date
    private var _endRelay: PublishRelay<Date> = PublishRelay()
    private var _end: Date? = nil
    
    var end: Date? {
        return _end
    }
    
    var didEndObs: Observable<Date> {
        return _endRelay.asObservable()
    }
    
    init(start: Date, type: GoTimeType) {
        self.start = start
        self.type = type
    }
    
    func ended(_ endTime: Date) {
        guard _end == nil else { return }
        _endRelay.accept(endTime)
        _end = endTime
    }
}

extension GoTime: ChainMutable {
    func acceptChain(other: GoTime) {
        self.ended(other.start)
    }
    
    func terminateSelf() {
        self.ended(Date.now)
    }
}

extension GoTime : IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity : Identity {
        return start.hashValue
    }
    
    static func ==(lhs: GoTime, rhs: GoTime) -> Bool {
        return lhs.identity == rhs.identity
    }
}
