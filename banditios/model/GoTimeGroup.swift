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
    static let id = "Id"
    static let goTimes = "GoTimes"
    static let lastModified = "LastModified"
}



class GoTimeGroup: NSObject, NSCoding {
    
    let id: Int
    private let goTimes = Chain<GoTime>()
    private let publisher = ReplaySubject<GoTimeGroup>.createUnbounded()
    var lastModified: Date
    private var locked = false
    
    var createdDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(id))
    }
    
    var valueChangedObs: Observable<GoTimeGroup> {
        return publisher.asObserver()
    }
    
    var items: [GoTime] {
        return goTimes.list()
    }
    
    var startTime: Date? {
       return items.first?.start
    }
    
    var endTime: Date? {
        return items.last?.end
    }
    
    var isEmpty: Bool {
       return goTimes.head == nil
    }
    
    var size: Int {
        return items.count
    }
    
    var isEnded: Bool {
        return endTime != nil
    }
    
    var isLocked: Bool {
        return locked
    }
    
    convenience init(goTimes: [GoTime]?) {
        let id = Int(Date.now.timeIntervalSince1970)
        let lastModified = Date.now
        self.init(id: id, lastModified: lastModified, goTimes: goTimes ?? [])
    }
    
    required init(id: Int, lastModified: Date, goTimes: [GoTime]) {
        self.id = id
        self.lastModified = lastModified
        super.init()
        self.goTimes.setValues(goTimes)
        publisher.on(.next(self))
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(goTimes.list(), forKey: GoTimeGroupProps.goTimes)
        aCoder.encodeCInt(Int32(id), forKey: GoTimeGroupProps.id)
        aCoder.encode(lastModified, forKey: GoTimeGroupProps.lastModified)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let decodeTimes = aDecoder.decodeObject(forKey: GoTimeGroupProps.goTimes) as? [GoTime] else {
            print("Unable to decode gotimegroup")
            return nil
        }
        let decodeId = aDecoder.decodeInt32(forKey: GoTimeGroupProps.id)
        let decodeMod = aDecoder.decodeObject(forKey: GoTimeGroupProps.lastModified)
        let id = Int(decodeId)
        guard let lastModified = decodeMod as? Date else {
            print("Unable to decode id or modified")
            return nil
        }
        self.init(id: id, lastModified: lastModified, goTimes: decodeTimes)
    }
    
    func add(_ goTime: GoTime) {
        goTimes.add(goTime)
        publisher.on(.next(self))
    }
    
    func current() -> GoTime? {
        return goTimes.peek()
    }
    
    
    
    func stop() {
        if !isEmpty {
            goTimes.end()
            publisher.on(.next(self))
        }
    }
    
    func lock() {
        locked = true
    }
    
    func buttonUp() {
        if current()?.isPaused == true {
            current()?.resume()
        }
        if !isEnded {
            stop()
        }
    }
    
    func desc() -> String {
        var result = ""
        result += "Go Time Group\n\tcreated: \(createdDate.asTimeWithSecondsString())\n\tGoTimes: \n"
        for go in goTimes.list() {
            result += "\t\t\(go.desc())\n"
        }
        return result
    }
}

extension GoTimeGroup: EquatableByValue {
    static func ===(lhs: GoTimeGroup, rhs: GoTimeGroup) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        return lhs.items.equalByValue(rhs.items)
    }
}
