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
        return Array<GoTime>(goTimeGroup.items.dropLast())
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
    
    private let goTimeGroup = GoTimeGroup(goTimes: nil)
    private let typeConfig: GoTimeTypeConfig
    private let publisher = PublishRelay<GoTimeGroup>()
    private let disposeBag = DisposeBag()
    
    private let chill = GoTimeType(name: "Not Work", primary: false)
    private let work = GoTimeType(name: "Work", primary: true)
    
    /// Emits a new section model for every change in the underlying model
    var goTimeSectionObs: Observable<[GoTimeSection]> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.goTimeGroup.valueChangedObs.subscribe(onNext: { group in
                observer.on(.next([GoTimeSection(goTimeGroup: group)]))
            })
        }
    }
    
    init() {
        self.typeConfig = GoTimeTypeConfig(self.chill)
        configureTypes()
    }
    
    /// Stops execution of the current go time, starts the next go time and returns it
    func nextGoTime() -> GoTime {
        let now = Date.now
        let nextType = typeConfig.nextType(goTimeGroup.current()?.type)
        
        let goTime = GoTime(start: now, type: nextType)
        goTimeGroup.add(goTime)
        return goTime
    }
    
    /// Stops execution of the current go time
    func stop() {
        goTimeGroup.stop()
    }
    
    private func configureTypes() {
        typeConfig.typeMap[chill] = work
        typeConfig.typeMap[work] = chill
    }
}
