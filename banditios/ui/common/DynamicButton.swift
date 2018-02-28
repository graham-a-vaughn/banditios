//
//  DynamicButton.swift
//  banditios
//
//  Created by Graham Vaughn on 2/20/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt

class DynamicButton: NSObject {
    let name: String
    let location: ButtonLocation
    let button: UIButton
    
    let configMgr = ButtonConfigurationManager()
    let vmObs: Observable<GoTimeViewModel>
    var state: TrackingState?
    var dbx: ButtonExecutor?
    
    var constraints: [NSLayoutConstraint] = []
    var disposable: SerialDisposable = SerialDisposable()
    
    init(_ name: String, _ loc: ButtonLocation, _ button: UIButton, _ vm: Observable<GoTimeViewModel>) {
        self.name = name
        self.location = loc
        self.button = button
        self.vmObs = vm
        super.init()
        
        disposeBag.insert(disposable)
    }
    
    func configure(_ state: TrackingState) {
        guard state != self.state else { return }
        
        let config = configMgr.getConfig(state, location)
        button.isEnabled = config.enabled
        config.appearance.apply(button, config.enabled ? .normal : .disabled)
        if let goToState = config.goToState {
            dbx = ButtonExecutor(goToState, db: self, vmObs: vmObs)
        }
        self.state = state
    }
}

class ButtonConfiguration {
    let state: TrackingState
    let enabled: Bool
    let goToState: TrackingState?
    let appearance: ButtonAppearanceConfig
    
    init(_ state: TrackingState, _ goToState: TrackingState?, appearance: ButtonAppearanceConfig, enabled: Bool) {
        self.state = state
        self.enabled = enabled
        self.goToState = goToState
        self.appearance = appearance
    }
}

class ButtonAppearanceConfig {
    private let animationQueue = DispatchQueue(label: "com.vaughn.banditios.ButtonAppearanceConfigQueue\(Date.now.timeIntervalSince1970)")
    
    var backgroundColor: UIColor = UIColor.clear
    var borderWidth: CGFloat = 2
    var cornerRadius: CGFloat = 8
    var borderColor: UIColor = UIColor.blue
    var title: String = "default"
    var titleColor: UIColor = UIColor.white
    
    init(title: String, color: UIColor) {
        self.borderColor = color
        self.titleColor = color
        self.title = title
    }
    
    func apply(_ button: UIButton, _ state: UIControlState) {
        button.borderWidth = borderWidth
        button.cornerRadius = cornerRadius
        
        animationQueue.sync {
            UIView.animate(withDuration: 0.75) {
                button.borderColor = self.borderColor
                button.setTitle(self.title, for: state)
                button.setTitleColor(self.titleColor, for: state)
            }
        }
        applyBackground(button, state)
    }
    
    private func applyBackground(_ button: UIButton, _ state: UIControlState) {
        if button.backgroundColor != backgroundColor {
            animationQueue.sync {
                UIView.animate(withDuration: 0.75) {
                    button.backgroundColor = self.backgroundColor
                }
            }
        }
    }
}

class DisabledButtonAppearance : ButtonAppearanceConfig {
    init(_ color: UIColor) {
        let specialColor = ColorHelper().getColor(color, alpha: 0.33)
        super.init(title: "D", color: specialColor)
    }
}

class ButtonExecutor {
    let goToState: TrackingState
    let dmb: DynamicButton
    let disposeBag = DisposeBag()
    var viewModel: GoTimeViewModel?
    
    let viewModelObs: Observable<GoTimeViewModel>
    var buttonTpObs: Observable<Void> = Observable.empty()
    var stateObs: Observable<TrackingStateModel> = Observable.empty()
    var stateDis = SerialDisposable()
    
    init(_ state: TrackingState, db: DynamicButton, vmObs: Observable<GoTimeViewModel>) {
        self.goToState = state
        self.dmb = db
        
        self.viewModelObs = vmObs
        self.viewModelObs
            .subscribeNext(weak: self) { strongSelf, vm in
                strongSelf.viewModel = vm
                strongSelf.observe(vm)
            }
            .disposed(by: disposeBag)
        disposeBag.insert(stateDis)
    }
    
    func observe(_ vm: GoTimeViewModel) {
        let buttonTapObs = dmb.button.rx.tap.asObservable()
        dmb.disposable.disposable = buttonTapObs.subscribeNext(weak: self) { strongSelf, _ in
            vm.transition(strongSelf.goToState)
        }
        
        self.buttonTpObs = buttonTapObs
    }
}

class ButtonConfigurationManager {
    private static let goColor = UIColor.green
    private static let pauseColor = UIColor.yellow
    private static let resumeColor = UIColor.orange
    private static let stopColor = UIColor.red
    private static let saveColor = UIColor.purple
    private static let disabledColor = UIColor.blue
    
    private static let config: [TrackingState: [ButtonLocation: ButtonConfiguration]] = [
        .ready: [.left: goConfig(.ready), .middle: disabledConfig(.ready), .right: disabledConfig(.ready)],
        .tracking: [.left: goConfig(.tracking), .middle: pauseConfig(.tracking), .right: disabledConfig(.tracking)],
        .paused: [.left: goConfig(.paused), .middle: resumeConfig(.paused), .right: stopConfig(.paused)],
        .resumed: [.left: goConfig(.resumed), .middle: pauseConfig(.resumed), .right: disabledConfig(.resumed)],
        .stopped: [.left: disabledConfig(.stopped), .middle: disabledConfig(.stopped), .right: saveConfig(.stopped)],
        .saved: [.left: disabledConfig(.saved), .middle: disabledConfig(.saved), .right: disabledConfig(.saved)]
    ]
    
    func getConfig(_ state: TrackingState, _ loc: ButtonLocation) -> ButtonConfiguration {
        return ButtonConfigurationManager.config[state]![loc]!
    }
    private static func goConfig(_ state: TrackingState) -> ButtonConfiguration {
        return ButtonConfiguration(state, .tracking, appearance: ButtonAppearanceConfig(title: "G", color: goColor), enabled: true)
    }
    
    private static func pauseConfig(_ state: TrackingState) -> ButtonConfiguration {
        return ButtonConfiguration(state, .paused, appearance: ButtonAppearanceConfig(title: "P", color: pauseColor), enabled: true)
    }
    
    private static func resumeConfig(_ state: TrackingState) -> ButtonConfiguration {
        return ButtonConfiguration(state, .resumed, appearance: ButtonAppearanceConfig(title: "R", color: resumeColor), enabled: true)
    }
    
    private static func stopConfig(_ state: TrackingState) -> ButtonConfiguration {
        return ButtonConfiguration(state, .stopped, appearance: ButtonAppearanceConfig(title: "S", color: stopColor), enabled: true)
    }
    
    private static func saveConfig(_ state: TrackingState) -> ButtonConfiguration {
        return ButtonConfiguration(state, .saved, appearance: ButtonAppearanceConfig(title: "SS", color: saveColor), enabled: true)
    }
    
    private static func disabledConfig(_ state: TrackingState) -> ButtonConfiguration {
        return ButtonConfiguration(state, nil, appearance: DisabledButtonAppearance(disabledColor), enabled: false)
    }
}


