//
//  ElapsedTime.swift
//  banditios
//
//  Created by Graham Vaughn on 2/3/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum TimeUnit: TimeInterval {
    case second = 1
    case minute = 60
    case hour = 3600
    
    var value: Int {
        return self.rawValue.int
    }
    
    static func list() -> [TimeUnit] {
        return [.second, .minute, .hour]
    }
}

struct ElapsedTimeUnit {
    let unit: TimeUnit
    var value: Int
}

class ElapsedTime {
    var value: ElapsedTimeUnit
    var next: ElapsedTime?
    
    var displayZero: Bool {
        return next != nil
    }
    
    convenience init(_ timeUnit: TimeUnit) {
        self.init(timeUnit, value: 0)
    }
    
    convenience init?(_ timeUnit: TimeUnit?) {
        self.init(timeUnit ?? .second, value: 0)
    }
    
    required init(_ timeUnit: TimeUnit, value: Int) {
        self.value = ElapsedTimeUnit(unit: timeUnit, value: value)
    }
    
    func increment() {
        var nextVal = value.value + 1
        if let next = next, nextVal == next.value.unit.value {
            next.increment()
            nextVal = 0
        }
        self.value.value = nextVal
    }
    
    func incrementDisplay() -> String {
        increment()
        return display()
    }
    
    func advanceBy(unit: TimeUnit, amount: Int) {
        assert(unit == value.unit || next != nil)
        if unit == value.unit {
            for _ in 0..<amount {
                increment()
            }
        } else {
            next?.advanceBy(unit: unit, amount: amount)
        }
    }
    
    private func getDisplay() -> String {
        if self.value.value > 0 || displayZero {
            let raw = "\(self.value.value)"
            let prepend = displayZero && raw.count == 1 ? "0" : ""
            return prepend + raw
        }
        return ""
    }
    
    private func nextDisplay() -> String {
        if let nextDisplay = next?.display(), !nextDisplay.isEmpty {
            return nextDisplay + ":"
        }
        return ""
    }
    
    func display() -> String {
        return nextDisplay() + getDisplay()
    }
}
