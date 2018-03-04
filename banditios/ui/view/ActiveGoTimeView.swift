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

class Blinker: NSObject {
    private var blinkTimer: Timer? = nil
    private let blinkDuration: TimeInterval
    private var blinking = BehaviorRelay<Int>(value: 0)
    
    init(_ duration: TimeInterval?) {
        self.blinkDuration = duration ?? 0.5
        super.init()
    }
    
    func start(_ label: UIView) {
        self.blinkTimer?.invalidate()
        label.alpha = 1.0
        blinking.accept(0)
        let blinkTimer = Timer.scheduledTimer(withTimeInterval: blinkDuration, repeats: true) { [weak self] tmr in
            guard let strongSelf = self else { return }
            UIView.animate(withDuration: strongSelf.blinkDuration,
                           delay: 0.0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.1,
                           options: UIViewAnimationOptions.curveEaseIn, animations: {
                label.alpha = strongSelf.blinkAlpha()
            }, completion: nil)
        }
        self.blinkTimer = blinkTimer
    }
    
    func stop(_ label: UIView, _ alpha: CGFloat) {
        blinkTimer?.invalidate()
        label.alpha = alpha
    }
    
    private func blinkAlpha() -> CGFloat {
        let current = blinking.value
        let next = current == 0 ? 1 : 0
        blinking.accept(next)
        return CGFloat(current)
    }
}

class ActiveView : UIView {
    private static let elapsedColor = UIColor.green
    private static let pauseColor = UIColor.orange
    private static let stopColor = UIColor.red
    
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    private let durationBlinker = Blinker(0.5)
    private var elapsedTimeDisplay: ElapsedTimeViewModel?
    private var elapsedTimeObs: Observable<String>?
    private var elapsedTimeDisposable = SerialDisposable()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSerialDisposables()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSerialDisposables()
    }
    
    private func initializeSerialDisposables() {
        disposeBag.insert(elapsedTimeDisposable)
    }
    
    func apply(_ model: TrackingStateModel) {
        switch model.state {
        case .ready:
            self.alpha = 0.0
            typeLabel.text = ""
            timeLabel.text = ""
            durationLabel.text = ""
        case .tracking:
            if let goTime = model.goTime {
                configureTrackingLabels(goTime)
                observeElapsedTime(goTime)
                self.alpha = 1.0
            }
        case .paused:
            elapsedTimeDisplay?.pause()
            durationLabel.textColor = ActiveView.pauseColor
            durationBlinker.start(durationLabel)
        case .resumed:
            elapsedTimeDisplay?.resume()
            durationBlinker.stop(durationLabel, 1.0)
            durationLabel.textColor = ActiveView.elapsedColor
        case .stopped:
            durationLabel.text = elapsedTimeDisplay?.stop()
            durationBlinker.stop(durationLabel, 1.0)
            durationLabel.textColor = ActiveView.stopColor
        default:
            return
        }
    }
    
    private func configureTrackingLabels(_ goTime: GoTime) {
        typeLabel.text = "\(goTime.type.name)"
        timeLabel.text = "\(goTime.start.asTimeWithSecondsString())"
        
        durationBlinker.stop(durationLabel, 1.0)
        durationLabel.textColor = ActiveView.elapsedColor
    }
    
    private func observeElapsedTime(_ goTime: GoTime) {
        let elapsedTimeDisplay = ElapsedTimeViewModel(startingAt: Date.now - goTime.start)
        let elapsedTimeObs = elapsedTimeDisplay.go()
        elapsedTimeDisposable.disposable = elapsedTimeObs.bind(to: durationLabel.rx.text)
        
        self.elapsedTimeDisplay = elapsedTimeDisplay
        self.elapsedTimeObs = elapsedTimeObs
    }
}

class ReadyView : UIView {
    private static let readyBlinkPeriod: TimeInterval = 1.0
    
    @IBOutlet var readyLabel: UILabel!
    let blinker: Blinker
    
    override init(frame: CGRect) {
        self.blinker = Blinker(ReadyView.readyBlinkPeriod)
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.readyLabel = UILabel()
        self.blinker = Blinker(ReadyView.readyBlinkPeriod)
        super.init(coder: aDecoder)
    }
    
    func apply(_ model: TrackingStateModel) {
        switch model.state {
        case .ready:
            self.alpha = 1.0
            readyLabel.alpha = 1.0
            blinker.start(readyLabel)
        default:
            self.hide()
        }
    }
    
    private func hide() {
        blinker.stop(readyLabel, 0.0)
        self.alpha = 0.0
    }
}

class TransitionView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ActiveGoTimeView: UIView {
    private static let defaultTransitionPeriod = 0.5
    private static let activeTransitionPeriod = 0.15
    
    @IBOutlet var activeView: ActiveView!
    @IBOutlet var readyView: ReadyView!
    @IBOutlet var transitionView: TransitionView!
    
    private let defaultHelper = ActivityTransitionHelper(0.85, 0.0, duration: ActiveGoTimeView.defaultTransitionPeriod)
    private let activetHelper = ActivityTransitionHelper(0.3, 0.0, duration: ActiveGoTimeView.activeTransitionPeriod)
    
    private let stateDisposable = SerialDisposable()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        disposeBag.insert(stateDisposable)
    }
    
    func observeTrackingState(_ stateObs: Observable<TrackingStateModel>) {
        stateDisposable.disposable = stateObs.subscribeNext(weak: self) { strongSelf, model in
            strongSelf.stateChanged(model)
        }
    }
    
    func stateChanged(_ new: TrackingStateModel) {
        switch new.state {
        case .ready, .stopped:
            transition(new, activetHelper)
        default:
            transition(new, defaultHelper)
        }
    }
    
    private func transition(_ state: TrackingStateModel, _ helper: ActivityTransitionHelper) {
        helper.showElement(transitionView)
        readyView.apply(state)
        activeView.apply(state)
        helper.hideElement(transitionView)
    }
}
