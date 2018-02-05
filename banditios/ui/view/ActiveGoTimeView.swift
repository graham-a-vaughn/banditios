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
    @IBOutlet private var readyView: UIView!
    @IBOutlet private var readyLabel: UILabel!
    private let transitionHelper = ActivityTransitionHelper()
    
    private var goTime: GoTime?
    private var elapsedTimeDisplay: ElapsedTimeViewModel?
    private var elapsedTimeObs: Observable<String>?
    private var endedObs: Observable<Date>?
    private var elapsedTimeDisposable = SerialDisposable()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialize() {
        disposeBag.insert(elapsedTimeDisposable)
        readyView.alpha = 0.0
        readyLabel.alpha = 0.0
    }
    
    func ready() {
        _ = transitionHelper.startActivityTransition(readyView)
        _ = transitionHelper.showReadyLabel(readyLabel)
        _ = transitionHelper.blinkReadyLabel(readyLabel)
    }
    
    func configure(_ goTime: GoTime) {
        transitionHelper.stopBlinkingReadyLabel()
        _ = transitionHelper.hideReadyLabel(readyLabel)
        _ = transitionHelper.startActivityTransition(readyView)
        configureLabels(goTime)
        bindObservables(goTime)
        self.goTime = goTime
        _ = transitionHelper.endActivityTransition(readyView)
    }
    
    private func configureLabels(_ goTime: GoTime) {
        typeLabel.text = "\(goTime.type.name)"
        timeLabel.text = "\(goTime.start.asTimeWithSecondsString())"
    }
    
    private func bindObservables(_ goTime: GoTime) {
        let elapsedTimeDisplay = ElapsedTimeViewModel(startingAt: Date.now - goTime.start)
        let elapsedTimeObs = elapsedTimeDisplay.go()
        elapsedTimeDisposable.disposable = elapsedTimeObs.bind(to: durationLabel.rx.text)
        
        let endedObs = goTime.didEndObs.asObservable()
        endedObs.subscribe(onNext: { [weak self] ended in
                guard let strongSelf = self else { return }
                strongSelf.ended()
            })
            .disposed(by: disposeBag)
        
        self.elapsedTimeDisplay = elapsedTimeDisplay
        self.elapsedTimeObs = elapsedTimeObs
        self.endedObs = endedObs
    }
    
    private func ended() {
        let final = elapsedTimeDisplay?.stop()
        durationLabel.text = final ?? "shit"
        elapsedTimeDisposable.dispose()
        elapsedTimeDisposable = SerialDisposable()
    }
    
    
}
