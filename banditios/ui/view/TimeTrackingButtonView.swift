//
//  TimeTrackingButtonView.swift
//  banditios
//
//  Created by Graham Vaughn on 2/18/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum ButtonLocation {
    case left
    case middle
    case right
}

class ButtonAppearance {
    var backgroundColor: UIColor = UIColor.clear
    var borderWidth: CGFloat = 2
    var cornerRadius: CGFloat = 8
    var borderColor: UIColor = UIColor.blue
    var title: String = "default"
    var titleColor: UIColor = UIColor.white
    var disabledColor: UIColor = UIColor.lightGray
    
    init(title: String, color: UIColor) {
        self.borderColor = color
        self.titleColor = color
        self.title = title
        let ch = ColorHelper()
        self.disabledColor = ch.getColor(color, alpha: 0.33)
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
    
    init(_ state: TrackingState, db: DynamicButton,vmObs: Observable<GoTimeViewModel>) {
        self.goToState = state
        self.dmb = db
        
        self.viewModelObs = vmObs
        self.viewModelObs.subscribeNext(weak: self) { strongSelf, vm in
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

class ConstraintManager {
    let ww: CGFloat = 86
    let hh: CGFloat = 44
    func constraints(_ loc: ButtonLocation, _ btn: UIButton, _ view: UIView) -> [NSLayoutConstraint] {
        switch loc {
        case .left:
            return [
                left(btn) |==| left(view) |+| 20,
                width(btn) |==| ww,
                height(btn) |==| hh,
                centerY(btn) |==| centerY(view)
            ]
        case .middle:
            return [
                width(btn) |==| ww,
                height(btn) |==| hh,
                centerY(btn) |==| centerY(view),
                centerX(btn) |==| centerX(view)
            ]
        case .right:
            return [
                width(btn) |==| ww,
                height(btn) |==| hh,
                centerY(btn) |==| centerY(view),
                right(btn) |==| right(view) |-| 20
            ]
        }
    }
}

class TimeTrackingButtonView: UIView {
    private let animationQueue = DispatchQueue(label: "com.vaughn.banditios.TimeTrackingButtonViewQueue")
    private static let goColor = UIColor.green
    private static let pauseColor = UIColor.yellow
    private static let resumeColor = UIColor.orange
    private static let stopColor = UIColor.red
    
    private let bwidth = CGFloat(86)
    private let bheight = CGFloat(44)
    
    private let maskingView: UIView = UIView()
    private let leftButton: UIButton = UIButton(type: .custom)
    private let middleButton: UIButton = UIButton(type: .custom)
    private let rightButton: UIButton = UIButton(type: .custom)
    private let buttons: [ButtonLocation: DynamicButton]
    private let buttonLocations: [String: ButtonLocation] = [
        "left": .left,
        "middle": .middle,
        "right": .right
    ]
    
    private let showButtonMap: [TrackingState: [ButtonLocation: Bool]] = [
        .ready : [.left: true, .middle: false, .right: false],
        .tracking: [.left: true, .middle: true, .right: false],
        .paused: [.left: true, .middle: true, .right: true],
        .resumed: [.left: true, .middle: true, .right: false],
        .stopped: [.left: false, .middle: false, .right: true],
    ]
    
    private let observeButtonMap: [TrackingState: [ButtonLocation: TrackingState]] = [
        .ready : [.left: .tracking],
        .tracking: [.left: .tracking, .middle: .paused],
        .paused: [.left: .tracking, .middle: .resumed, .right: .stopped],
        .resumed: [.left: .tracking, .middle: .paused],
        .stopped: [.right: .saved]
    ]
    
    private let buttonAppearanceMap: [TrackingState: [ButtonLocation: ButtonAppearance]] = [
        .ready : [.left: ButtonAppearance(title: "G", color: goColor)],
        .tracking: [.left: ButtonAppearance(title: "G", color: goColor), .middle: ButtonAppearance(title: "P", color: pauseColor)],
        .paused: [.left: ButtonAppearance(title: "G", color: goColor), .middle: ButtonAppearance(title: "R", color: resumeColor), .right: ButtonAppearance(title: "S", color: stopColor)],
        .resumed: [.left: ButtonAppearance(title: "G", color: goColor), .middle: ButtonAppearance(title: "P", color: pauseColor)],
        .stopped: [.right: ButtonAppearance(title: "SV", color: stopColor)]
    ]
    
    private let disabledButtonAppearance = ButtonAppearance(title: "D", color: UIColor.blue)
    
    private var maskConstraints: [NSLayoutConstraint] = []
    
    private let constraintManager = ConstraintManager()
    private let vmReplay = ReplaySubject<GoTimeViewModel>.createUnbounded()
    private var vmObs: Observable<GoTimeViewModel> = Observable.empty()
    private var viewModel: GoTimeViewModel?
    private var stateObs: Observable<TrackingStateModel> = Observable.empty()
    private let stateDisposable = SerialDisposable()
    private var destinations: [TrackingState] = [.tracking, .paused, .stopped]
    
    override init(frame: CGRect) {
        self.buttons = [
            .left: DynamicButton("left", .left, leftButton),
            .middle: DynamicButton("middle", .middle, middleButton),
            .right: DynamicButton("right", .right, rightButton)
        ]
        super.init(frame: frame)
        self.vmObs = vmReplay.asObservable()
        initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.buttons = [
            .left: DynamicButton("left", .left, leftButton),
            .middle: DynamicButton("middle", .middle, middleButton),
            .right: DynamicButton("right", .right, rightButton)
        ]
        super.init(coder: aDecoder)
        self.vmObs = vmReplay.asObservable()
        initializeUI()
    }
    
    private func initializeUI() {
        for btn in buttons {
            disposeBag.insert(btn.value.disposable)
        }
        disposeBag.insert(stateDisposable)
        initializeButtonLayout(.ready)
        initializeMaskLayout()
    }
    
    private func configureButtons(_ state: TrackingState) {
        let st = state
        for db in buttons.values {
            handleButtonState(db, st)
        }
    }
    
    private func initializeButtonLayout(_ initialState: TrackingState) {
        let st = initialState
        for db in buttons.values {
            let btn = db.button
            let loc = db.location
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.isUserInteractionEnabled = true
            
            handleButtonState(db, st)
            addSubview(btn)
            let cns = constraintManager.constraints(loc, btn, self)
            NSLayoutConstraint.activate(cns)
            db.constraints = cns
        }
    }
    
    private func initializeMaskLayout() {
        maskingView.alpha = 0.0
        addSubview(maskingView)
        let mskfc: [NSLayoutConstraint] = [
            left(maskingView) |==| left(self),
            right(maskingView) |==| right(self),
            top(maskingView) |==| top(self),
            bottom(maskingView) |==| bottom(self),
            ]
        NSLayoutConstraint.activate(mskfc)
    }
    
    private func handleButtonState(_ db: DynamicButton, _ st: TrackingState) {
        guard db.state != st else { return }
        let loc = db.location
        let btn = db.button
        let show = showButtonMap[st]![loc]!
        
        if show {
            let apr = buttonAppearanceMap[st]![loc]!
            setButtonAppearance(btn, apr)
            let goToState = observeButtonMap[st]![loc]!
            let bx = ButtonExecutor(goToState, db: db,vmObs: vmObs)
            //sbx.observe()
            db.dbx = bx
        } else {
            let apr = disabledButtonAppearance
            db.disposable.dispose()
            db.disposable = SerialDisposable()
            db.dbx = nil
            disposeBag.insert(db.disposable)
            
            setButtonDisabled(btn, apr)
        }
        
        db.state = st
    }
    
    private func setButtonAppearance(_ button: UIButton, _ apr: ButtonAppearance) {
        button.isEnabled = true
        button.backgroundColor = apr.backgroundColor
        button.borderWidth = apr.borderWidth
        button.borderColor = apr.borderColor
        button.cornerRadius = apr.cornerRadius
        button.setTitle(apr.title, for: .normal)
        button.setTitleColor(apr.titleColor, for: .normal)
    }
    
    private func setButtonDisabled(_ button: UIButton, _ apr: ButtonAppearance) {
        button.isEnabled = false
        button.borderWidth = apr.borderWidth
        button.borderColor = apr.disabledColor
        button.cornerRadius = apr.cornerRadius
        button.setTitle(apr.title, for: .disabled)
        button.setTitleColor(apr.titleColor, for: .disabled)
        animationQueue.sync {
            UIView.animate(withDuration: 0.75) {
                button.backgroundColor = apr.disabledColor
            }
        }
    }
    
    func configure(_ viewModel: GoTimeViewModel) {
        stateObs = viewModel.trackingStateObs
        stateDisposable.disposable = stateObs.subscribeNext(weak: self) { strongSelf, model in
            strongSelf.stateChanged(model)
        }
        
        self.viewModel = viewModel
        vmReplay.onNext(viewModel)
    }
    
    private func stateChanged(_ newState: TrackingStateModel) {
        guard newState.state != .saved else { return }
        configureButtons(newState.state)
    }
    
}
