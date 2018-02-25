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
    private static let activityTransition = 1.0
    private static let readyLabelTransition = 0.25
    private static let readyBlinkRate = 0.25
    
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
    private var readyBlinkerDisposable = SerialDisposable()
    private let stateDisposable = SerialDisposable()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ stateObs: Observable<TrackingStateModel>) {
        initialize()
        
        observe(stateObs)
    }
    
    func observe(_ stateObs: Observable<TrackingStateModel>) {
        stateDisposable.disposable = stateObs.subscribeNext(weak: self) { strongSelf, model in
            strongSelf.stateChanged(model)
        }
    }
    
    private func initialize() {
        disposeBag.insert(elapsedTimeDisposable)
        disposeBag.insert(readyBlinkerDisposable)
        disposeBag.insert(stateDisposable)
    }
    
    private func configureLabels(_ goTime: GoTime) {
        typeLabel.text = "\(goTime.type.name)"
        timeLabel.text = "\(goTime.start.asTimeWithSecondsString())"
    }
    
    func stateChanged(_ new: TrackingStateModel) {
        transition()
        switch new.state {
        case .ready:
            ready()
        case .tracking:
            guard let goTime = new.goTime else { return }
            next(goTime)
        case .paused:
            pause()
        case .resumed:
            guard let goTime = new.goTime else { return }
            resume(goTime)
        case .stopped:
            stop()
        default:
            return
        }
        
    }
    
    private func transition() {
        transitionHelper.hideElement(readyLabel, ActiveGoTimeView.readyLabelTransition)
        
        elapsedTimeDisposable.disposable.dispose()
        readyBlinkerDisposable.dispose()
        
        elapsedTimeDisposable = SerialDisposable()
        readyBlinkerDisposable = SerialDisposable()
        disposeBag.insert(elapsedTimeDisposable)
        disposeBag.insert(readyBlinkerDisposable)
    }
    
    func ready() {
        transitionHelper.showElement(readyView, ActiveGoTimeView.activityTransition)
        transitionHelper.showElement(readyLabel, ActiveGoTimeView.readyLabelTransition)
        readyBlinkerDisposable.disposable = transitionHelper.blink(readyLabel, ActiveGoTimeView.readyBlinkRate)
        
    }
    
    private func next(_ goTime: GoTime) {
        transitionHelper.showElement(readyView, ActiveGoTimeView.activityTransition)
        configureLabels(goTime)
        startElapsedTimeDisplay(Date.now - goTime.start)
        transitionHelper.hideElement(readyView, ActiveGoTimeView.activityTransition)
    }
    
    private func pause() {
        stopElapsedTimeDisplay()
    }
    
    private func resume(_ goTime: GoTime) {
        let timePaused = goTime.timePaused
        let startingAt = (Date.now - goTime.start) - timePaused
        startElapsedTimeDisplay(startingAt)
    }
    
    private func stop() {
        stopElapsedTimeDisplay()
    }
    
    private func stopElapsedTimeDisplay() {
        _ = elapsedTimeDisplay?.stop()
    }
    
    private func startElapsedTimeDisplay(_ startingAt: TimeInterval) {
        let elapsedTimeDisplay = ElapsedTimeViewModel(startingAt: startingAt)
        let elapsedTimeObs = elapsedTimeDisplay.go()
        elapsedTimeDisposable.disposable = elapsedTimeObs.bind(to: durationLabel.rx.text)
        self.elapsedTimeDisplay = elapsedTimeDisplay
        self.elapsedTimeObs = elapsedTimeObs
    }
    
    
    
    
    
    func configure(_ goTime: GoTime) {
        transitionHelper.stopBlinkingReadyLabel()
        transitionHelper.hideElement(readyLabel, ActiveGoTimeView.readyLabelTransition)
        transitionHelper.showElement(readyView, ActiveGoTimeView.activityTransition)
        configureLabels(goTime)
        bindObservables(goTime)
        self.goTime = goTime
        transitionHelper.hideElement(readyView, ActiveGoTimeView.activityTransition)
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
