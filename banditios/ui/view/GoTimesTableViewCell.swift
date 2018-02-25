//
//  GoTimesTableViewCell.swift
//  banditios
//
//  Created by Graham Vaughn on 1/15/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class GoTimesTableViewCell: UITableViewCell {
    
    @IBOutlet private var typeLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    
    
    @IBOutlet var endLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!
    
    private var goTime: GoTime?
    private var elapsedTimeDisplay: ElapsedTimeViewModel?
    private var elapsedTimeObs: Observable<String>?
    private var endedObs: Observable<Date>?
    private var elapsedTimeDisposable = SerialDisposable()
    
    func configure(_ goTime: GoTime) {
        reuseDisposeBag.insert(elapsedTimeDisposable)
        
        let endDisplay = goTime.end?.asTimeWithSecondsString() ?? "???"
        typeLabel.text = "\(goTime.type.name)"
        timeLabel.text = "\(goTime.start.asTimeWithSecondsString())"
        endLabel.text = "\(endDisplay)"
        
        if let endTime = goTime.end {
            let elapsedTimeDisplay = ElapsedTimeViewModel(startingAt: endTime - goTime.start)
            durationLabel.text = "\(elapsedTimeDisplay.stop())"
        } else {
            observeEnd(goTime)
        }
        
        
        
        
        self.goTime = goTime
    }
    
    private func observeEnd(_ goTime: GoTime) {
        let elapsedTimeDisplay = ElapsedTimeViewModel(startingAt: Date.now - goTime.start)
        let elapsedTimeObs = elapsedTimeDisplay.go()
        elapsedTimeDisposable.disposable = elapsedTimeObs.bind(to: durationLabel.rx.text)
        
        let endedObs = goTime.didEndObs.asObservable()
        
        endedObs
            .subscribe(onNext: { [weak self] ended in
                guard let strongSelf = self else { return }
                
                let final = strongSelf.elapsedTimeDisplay?.stop()
                strongSelf.durationLabel.text = final
                strongSelf.durationLabel.textColor = UIColor.red
                strongSelf.backgroundColor = UIColor.clear
                strongSelf.elapsedTimeDisposable.dispose()
            })
            .disposed(by: reuseDisposeBag)
        self.elapsedTimeDisplay = elapsedTimeDisplay
        self.elapsedTimeObs = elapsedTimeObs
        self.endedObs = endedObs
    }
    
    private func ended() {
        let final = elapsedTimeDisplay?.stop()
        durationLabel.text = final ?? "shit"
        durationLabel.textColor = UIColor.red
        elapsedTimeDisposable.dispose()
        elapsedTimeDisposable = SerialDisposable()
    }
}
