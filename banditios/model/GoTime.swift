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
import SwiftyJSON

struct GoTimeProps {
    static let type = "TypeName"
    static let start = "Start"
    static let end = "End"
    static let pauses = "Pauses"
    static let pauseStart = "PauseStart"
    static let pauseEnd = "PauseEnd"
}

class Pause: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(start, forKey: GoTimeProps.pauseStart)
        aCoder.encode(end, forKey: GoTimeProps.pauseEnd)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodeStart = aDecoder.decodeObject(forKey: GoTimeProps.pauseStart)
        let decodeEnd = aDecoder.decodeObject(forKey: GoTimeProps.pauseEnd)
        guard let started = decodeStart as? Date else {
            print("Could not decode pause start")
            return nil
        }
        let ended: Date? = decodeEnd != nil ? decodeEnd as! Date? : nil
        self.init(started, ended)
    }
    
    required init(_ start: Date, _ end: Date?) {
        self.start = start
        self.end = end
        super.init()
    }
    
    convenience init(start: Date) {
        self.init(start, nil)
    }
    
    let start: Date
    var end: Date?
    
    var timePaused: TimeInterval {
        guard let endTime = end else { return 0 }
        
        return endTime - start
    }
}

class GoTime: NSObject, NSCoding {
    private var pauses: [Pause] = []
    
    var isPaused: Bool {
        return pauses.last?.start != nil
            && pauses.last?.end == nil
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(type.name, forKey: GoTimeProps.type)
        aCoder.encode(start, forKey: GoTimeProps.start)
        aCoder.encode(end, forKey: GoTimeProps.end)
        aCoder.encode(pauses, forKey: GoTimeProps.pauses)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let decodeStart = aDecoder.decodeObject(forKey: GoTimeProps.start) as? Date else {
            print("Unable to decode GoTime start date")
            return nil
        }
        guard let decodeType = aDecoder.decodeObject(forKey: GoTimeProps.type) as? String else {
            print("Unable to decode GoTime type name")
            return nil
        }
        let decodeEnd = aDecoder.decodeObject(forKey: GoTimeProps.end) as? Date
        let decodePauses = aDecoder.decodeObject(forKey: GoTimeProps.pauses) as? [Pause]
        let toType = GoTimeType(name: decodeType, primary: false)
        self.init(start: decodeStart, end: decodeEnd, type: toType, pauses: decodePauses)
    }
    
    static func ==(lhs: GoTime, rhs: GoTime) -> Bool {
        return lhs.type == rhs.type
            && lhs.start == rhs.start
            && lhs.end == rhs.end
    }
    
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
    
    var timePaused: TimeInterval {
        let time = 0.0
        return pauses.reduce(time) { result, pause in
            let acc = result + pause.timePaused
            return acc
        }
    }
    
    var elapsedTime: TimeInterval {
        let final = end ?? Date.now
        return final - start - timePaused
    }
    
    convenience init(start: Date, type: GoTimeType) {
        self.init(start: start, end: nil, type: type)
    }
    
    required init(start: Date, end: Date?, type: GoTimeType, pauses: [Pause]? = nil) {
        self.start = start
        self._end = end
        self.type = type
        super.init()
        if let pauseVals = pauses {
            self.pauses.append(contentsOf: pauseVals)
        }
    }
    
    func pause() {
        guard !isPaused else { return }
        
        pauses.append(Pause(start: Date.now))
    }
    
    func resume() {
        guard isPaused else { return }
        
        pauses.last?.end = Date.now
    }
    
    func ended(_ endTime: Date) {
        guard _end == nil else { return }
        _endRelay.accept(endTime)
        _end = endTime
    }
    
    func desc() -> String {
        var result = ""
        let endResult = end?.asTimeWithSecondsString() ?? "nil"
        result += "Go Time: \n\tstart: \(start.asTimeWithSecondsString())\n\tend?: \(endResult)\n\ttype: \(type.name)"
        return result
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

extension GoTime: EquatableByValue {
    static func ===(lhs: GoTime, rhs: GoTime) -> Bool {
        if lhs.start != rhs.start {
            return false
        }
        if (lhs.end == nil) == (rhs.end == nil) {
            return lhs.end == rhs.end
        }
        return false
    }
}
