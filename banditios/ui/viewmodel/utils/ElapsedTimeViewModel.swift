//
//  ElapsedTimeViewModel.swift
//  banditios
//
//  Created by Graham Vaughn on 2/3/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct ElapsedTimeValue {
    let elapsedTime: TimeInterval
    let display: String
}

class ElapsedTimeViewModel {
    let head: ElapsedTime
    private let timeDisplayRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var durationTimer: Timer? = nil
    private let displayObs: Observable<String>
    private let elapsedTimeRelay: BehaviorRelay<TimeInterval> = BehaviorRelay(value: 0)
    
    convenience init() {
        self.init(toUnit: .hour)
    }
    
    required init(toUnit: TimeUnit) {
        let units = TimeUnit.list()
        head = ElapsedTime(units.first) ?? ElapsedTime(.second)
        var current = head
        for u in units.dropFirst() {
            let node = ElapsedTime(u)
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
    
    func pause() {
        _ = stop()
        durationTimer = nil
    }
    
    func resume() {
        startTimer()
    }
    
    private func startTimer() {
        guard self.durationTimer == nil else { return }
        let durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.timeDisplayRelay.accept(strongSelf.head.incrementDisplay())
            strongSelf.elapsedTimeRelay.accept(strongSelf.elapsedTimeRelay.value + 1)
        }
        self.durationTimer = durationTimer
    }
}
