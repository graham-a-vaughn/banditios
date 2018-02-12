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

class ElapsedTimeViewModel {
    let head: ElapsedTime
    private let timeDisplayRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var durationTimer: Timer? = nil
    private let displayObs: Observable<String>
    
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
    
    private func startTimer() {
        guard self.durationTimer == nil else { return }
        let durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.timeDisplayRelay.accept(strongSelf.head.incrementDisplay())
        }
        self.durationTimer = durationTimer
    }
}
