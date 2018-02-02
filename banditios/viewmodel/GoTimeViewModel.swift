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

struct GoTimeSection: AnimatableSectionModelType {
    typealias Identity = Int
    
    var goTimeGroup: GoTimeGroup
    private var _items: [GoTimeRow]?
    
    var identity : Identity {
        return items.isEmpty ? 0 : items[0].identity
    }
    
    var items: [GoTimeRow] {
        let result = _items ?? initItems()
        return result
    }
    
    init(original: GoTimeSection, items: [GoTimeRow]) {
        self = original
        self._items = Array<GoTimeRow>(items)
    }
    
    init(goTimeGroup: GoTimeGroup) {
        self.goTimeGroup = goTimeGroup
    }
    
    private func initItems() -> [GoTimeRow] {
        return goTimes().map { GoTimeRow(value: $0) }
    }
    
    private func goTimes() -> [GoTime] {
        return Array<GoTime>(goTimeGroup.items.dropLast())
    }
    private static func toGoTimes(_ rows: [GoTimeRow]) -> [GoTime]{
        return rows.map { $0.value }
    }
}

struct GoTimeRow {
    
    var value: GoTime
}

extension GoTimeRow : IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity : Identity {
        return value.start.hashValue
    }
    
    static func ==(lhs: GoTimeRow, rhs: GoTimeRow) -> Bool {
        return lhs.value == rhs.value
    }
}

class GoTimeViewModel {
    
    private let goTimeGroup = GoTimeGroup(goTimes: nil)
    private let typeConfig: GoTimeTypeConfig
    private let publisher = PublishRelay<GoTimeGroup>()
    private let disposeBag = DisposeBag()
    
    private let chill = GoTimeType(name: "Not Work", primary: false)
    private let work = GoTimeType(name: "Work", primary: true)
    
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
    
    func nextGoTime() -> GoTime {
        let now = Date.now
        let nextType = typeConfig.nextType(goTimeGroup.current()?.type)
        
        let goTime = GoTime(start: now, type: nextType)
        goTimeGroup.add(goTime)
        return goTime
    }
    
    func stop() {
        goTimeGroup.stop()
    }
    
    private func configureTypes() {
        typeConfig.typeMap[chill] = work
        typeConfig.typeMap[work] = chill
    }
}
