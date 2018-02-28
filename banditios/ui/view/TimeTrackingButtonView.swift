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
    
    private let bwidth = CGFloat(86)
    private let bheight = CGFloat(44)
    
    private let maskingView: UIView = UIView()
    private let buttons: [ButtonLocation: DynamicButton]
    
    private var maskConstraints: [NSLayoutConstraint] = []
    private let constraintManager = ConstraintManager()
    
    private let vmReplay = ReplaySubject<GoTimeViewModel>.createUnbounded()
    private var vmObs: Observable<GoTimeViewModel> = Observable.empty()
    private var viewModel: GoTimeViewModel?
    private var stateObs: Observable<TrackingStateModel> = Observable.empty()
    private let stateDisposable = SerialDisposable()
    
    override init(frame: CGRect) {
        let vObs = vmReplay.asObservable()
        self.buttons = [
            .left: DynamicButton("left", .left, UIButton(type: .custom), vObs),
            .middle: DynamicButton("middle", .middle, UIButton(type: .custom), vObs),
            .right: DynamicButton("right", .right, UIButton(type: .custom), vObs)
        ]
        super.init(frame: frame)
        self.vmObs = vObs
        initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        let vObs = vmReplay.asObservable()
        self.buttons = [
            .left: DynamicButton("left", .left, UIButton(type: .custom), vObs),
            .middle: DynamicButton("middle", .middle, UIButton(type: .custom), vObs),
            .right: DynamicButton("right", .right, UIButton(type: .custom), vObs)
        ]
        super.init(coder: aDecoder)
        self.vmObs = vObs
        initializeUI()
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
    
    private func configureButtons(_ state: TrackingState) {
        let st = state
        for db in buttons.values {
            db.configure(st)
        }
    }
    
    private func initializeUI() {
        disposeBag.insert(stateDisposable)
        initializeButtonLayout(.ready)
        initializeMaskLayout()
    }
    
    private func initializeButtonLayout(_ initialState: TrackingState) {
        let st = initialState
        for db in buttons.values {
            let btn = db.button
            let loc = db.location
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.isUserInteractionEnabled = true
            
            db.configure(st)
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
    
}
