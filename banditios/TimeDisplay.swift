//
//  TimeDisplay.swift
//  banditios
//
//  Created by Graham Vaughn on 1/19/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct ElapsedTimeUnit {
    let unit: TimeUnit
    var value: Int
}

class ElapsedTimeNode {
    var value: ElapsedTimeUnit
    var next: ElapsedTimeNode?
    
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

class ElapsedTimeList {
    let head: ElapsedTimeNode
    private let timeDisplayRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var durationTimer: Timer? = nil
    private let displayObs: Observable<String>
    
    convenience init() {
        self.init(toUnit: .hour)
        
    }
    
    required init(toUnit: TimeUnit) {
        let units = TimeUnit.list()
        head = ElapsedTimeNode(units.first) ?? ElapsedTimeNode(.second)
        var current = head
        for u in units.dropFirst() {
            let node = ElapsedTimeNode(u)
            current.next = node
            current = node
        }
        displayObs = timeDisplayRelay.asObservable()
    }
    
    convenience init(startingAt: TimeInterval) {
        self.init()
        head.advanceBy(unit: .second, amount: startingAt.int)
        startTimer()
    }
    
    func go() -> Observable<String> {
        startTimer()
        return displayObs
    }
    
    func stop() -> String {
        durationTimer?.invalidate()
        return head.display()
    }
    
    private func startTimer() {
        guard self.durationTimer == nil else { return }
        let durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.timeDisplayRelay.accept(strongSelf.head.incrementDisplay())
        }
        self.durationTimer = durationTimer
    }
}
