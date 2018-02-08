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

struct GoTimeGroupProps {
    static let goTimes = "GoTimes"
}
class GoTimeGroup: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(goTimes.list(), forKey: GoTimeGroupProps.goTimes)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let decodeTimes = aDecoder.decodeObject(forKey: GoTimeGroupProps.goTimes) as? [GoTime] else {
            print("Unable to decode gotimegroup")
            return nil
        }
        self.init(goTimes: decodeTimes)
    }
    
    let id: Int
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
    
    required init(goTimes: [GoTime]?) {
        self.id = Int(Date.now.timeIntervalSince1970)
        super.init()
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
