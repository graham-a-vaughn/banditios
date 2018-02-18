//
//  GoTimeViewModel.swift
//  banditios
//
//  Created by Graham Vaughn on 1/21/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa
import RxDataSources

/// Collection of go times. Single section contains all go times in the current cycle.
struct GoTimeSection: AnimatableSectionModelType {
    typealias Identity = Int
    
    /// Identifier for UI conformance
    var identity : Identity {
        return items.isEmpty ? 0 : items[0].identity
    }
    
    // Internal structure for mapping model to UI
    private var _items: [GoTimeRow]?
    
    /// Model containing the current cycle
    var goTimeGroup: GoTimeGroup

    /// Accessor for UI model
    var items: [GoTimeRow] {
        let result = _items ?? initItems()
        return result
    }
    
    /// Constructor for UI conformance
    init(original: GoTimeSection, items: [GoTimeRow]) {
        self = original
        self._items = Array<GoTimeRow>(items)
    }
    
    /// Convenience for model-based construction
    init(goTimeGroup: GoTimeGroup) {
        self.goTimeGroup = goTimeGroup
    }
    
    // Internal initializer for UI model
    private func initItems() -> [GoTimeRow] {
        return goTimes().map { GoTimeRow(value: $0) }
    }
    
    // Internal for mapping model to displayable model elements
    private func goTimes() -> [GoTime] {
        let itemSrc = goTimeGroup.current()?.end == nil ? Array<GoTime>(goTimeGroup.items.dropLast()) : Array<GoTime>(goTimeGroup.items)
        return itemSrc
    }
}

/// Single row in the curent cycle display
struct GoTimeRow {
    var value: GoTime
}

/// UI conformance
extension GoTimeRow : IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity : Identity {
        return value.start.hashValue
    }
    
    static func ==(lhs: GoTimeRow, rhs: GoTimeRow) -> Bool {
        return lhs.value == rhs.value
    }
}

/// View model for the currently active cycle
class GoTimeViewModel {
    private let disposeBag = DisposeBag()
    
    private let goTimeGroup = GoTimeGroup(goTimes: nil)
    private let typeConfig: GoTimeTypeConfig
    
    private let relay = ReplaySubject<TrackingStateModel>.create(bufferSize: 1)
    
    private let persistenceManager = PersistenceManager()
    private let errorHelper = ErrorHelper()
    
    private let chill = GoTimeType(name: "Not Work", primary: false)
    private let work = GoTimeType(name: "Work", primary: true)
    
    var trackingStateObs: Observable<TrackingStateModel> {
        return relay.asObservable()
    }
    
    init() {
        self.typeConfig = GoTimeTypeConfig(self.chill)
        configureTypes()
        transition(.ready)
    }
    
    func transition(_ state: TrackingState) {
        switch state {
        case .ready:
            let model = TrackingStateModel(goTime: nil, goTimeGroup: goTimeGroup, state: .ready)
            relay.onNext(model)
        case .tracking:
            let goTime = nextGoTime()
            let model = TrackingStateModel(goTime: goTime, goTimeGroup: goTimeGroup, state: .tracking)
            relay.onNext(model)
        case .paused:
            guard let goTime = goTimeGroup.current() else { return }
            goTime.pause()
            let model = TrackingStateModel(goTime: goTime, goTimeGroup: goTimeGroup, state: .paused)
            relay.onNext(model)
        case .resumed:
            guard let goTime = goTimeGroup.current() else { return }
            goTime.resume()
            let model = TrackingStateModel(goTime: goTime, goTimeGroup: goTimeGroup, state: .resumed)
            relay.onNext(model)
        case .stopped:
            stop()
            let model = TrackingStateModel(goTime: nil, goTimeGroup: goTimeGroup, state: .stopped)
            relay.onNext(model)
        }
    }
        
    /// Stops execution of the current go time, starts the next go time and returns it
    func nextGoTime() -> GoTime {
        let now = Date.now
        let nextType = typeConfig.nextType(goTimeGroup.current()?.type)
        
        let goTime = GoTime(start: now, type: nextType)
        goTimeGroup.add(goTime)
        do {
            try persistenceManager.autoSaveGoTimes(goTimeGroup)
        } catch {
            errorHelper.handleError(error)
        }
        return goTime
    }
    
    /// Stops execution of the current go time
    func stop() {
        goTimeGroup.stop()
        do {
            try persistenceManager.saveGoTimes(goTimeGroup)
        } catch {
            errorHelper.handleError(error)
        }
    }
    
    private func configureTypes() {
        typeConfig.typeMap[chill] = work
        typeConfig.typeMap[work] = chill
    }
}
