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
}

class GoTime: NSObject, NSCoding {
    
    static let persistDir = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = persistDir.appendingPathComponent("goTime")
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(type.name, forKey: GoTimeProps.type)
        aCoder.encode(start, forKey: GoTimeProps.start)
        aCoder.encode(end, forKey: GoTimeProps.end)
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
        let toType = GoTimeType(name: decodeType, primary: false)
        self.init(start: decodeStart, type: toType)
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

extension GoTime: JSONConvertable {
    func toJSON() -> JSON {
        let json: [String: Any?] = [
            "start": start.timeIntervalSinceReferenceDate,
            "end": end?.timeIntervalSinceReferenceDate ?? "",
            "type": [ "name": type.name, "primary": type.primary ]
        ]
        return JSON(json)
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
