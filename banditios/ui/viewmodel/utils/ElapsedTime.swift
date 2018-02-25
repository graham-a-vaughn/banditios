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
    private var _next: ElapsedTime?
    private var advanceAt: Int?
    
    var next: ElapsedTime? {
        get {
            return _next
        }
        set {
            _next = newValue
            if let newVal = newValue?.value.unit.value {
                advanceAt = newVal / value.unit.value
            }
            
        }
    }
    var displayZero: Bool {
        return _next != nil
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
        if let next = _next, let adv = advanceAt  {
            if nextVal == adv {
                next.increment()
                nextVal = 0
            }
        }
        self.value.value = nextVal
    }
    
    func incrementDisplay() -> String {
        increment()
        return display()
    }
    
    func advanceBy(unit: TimeUnit, amount: Int) {
        assert(unit == value.unit || _next != nil)
        if unit == value.unit {
            for _ in 0..<amount {
                increment()
            }
        } else {
            _next?.advanceBy(unit: unit, amount: amount)
        }
    }
    
    func display() -> String {
        return nextDisplay() + getDisplay()
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
        if let nextDisplay = _next?.display(), !nextDisplay.isEmpty {
            return nextDisplay + ":"
        }
        return ""
    }
}
