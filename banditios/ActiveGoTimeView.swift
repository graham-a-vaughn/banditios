//
//  ActiveGoTimeView.swift
//  banditios
//
//  Created by Graham Vaughn on 1/28/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ActiveGoTimeView: UIView {
    
    @IBOutlet private var typeLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var inactiveView: UIView!
    
    private var goTime: GoTime?
    private var elapsedTimeDisplay: ElapsedTimeViewModel?
    private var elapsedTimeObs: Observable<String>?
    private var endedObs: Observable<Date>?
    private var elapsedTimeDisposable = SerialDisposable()
    
    func configure(_ goTime: GoTime) {
        disposeBag.insert(elapsedTimeDisposable)
        
        let didStart = startActivityTransition()
        typeLabel.text = "\(goTime.type.name)"
        timeLabel.text = "\(goTime.start.asDetailedTimeString())"
        let elapsedTimeDisplay = ElapsedTimeViewModel(startingAt: Date.now - goTime.start)
        let elapsedTimeObs = elapsedTimeDisplay.go()
        elapsedTimeDisposable.disposable = elapsedTimeObs.bind(to: durationLabel.rx.text)
        
        let endedObs = goTime.didEndObs.asObservable()
        
        endedObs
            .subscribe(onNext: { [weak self] ended in
                guard let strongSelf = self else { return }
                strongSelf.ended()
            })
            .disposed(by: disposeBag)
        
        self.elapsedTimeDisplay = elapsedTimeDisplay
        self.elapsedTimeObs = elapsedTimeObs
        self.endedObs = endedObs
        self.goTime = goTime
        endActivityTransition(didStart: didStart)
    }
    
    private func startActivityTransition() -> Bool {
        guard inactiveView.alpha == 1.0 else { return false }
        
        UIView.animate(withDuration: 0.5) {
            self.inactiveView.alpha = 1.0
        }
        return true
    }
    
    private func endActivityTransition(didStart: Bool) {
        if inactiveView.alpha != 1.0 || didStart {
            UIView.animate(withDuration: 0.5) {
                self.inactiveView.alpha = 0.0
            }
        }
    }
    
    private func ended() {
        let final = elapsedTimeDisplay?.stop()
        durationLabel.text = final ?? "shit"
        elapsedTimeDisposable.dispose()
        elapsedTimeDisposable = SerialDisposable()
    }
}
