//
//  HistoryViewModel.swift
//  banditios
//
//  Created by Graham Vaughn on 2/9/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct HistorySection: AnimatableSectionModelType {
    typealias Identity = Int
    
    /// Identifier for UI conformance
    var identity : Identity {
        return items.isEmpty ? 0 : items[0].identity
    }
    
    var goTimeGroups: [GoTimeGroup]
    
    /// Constructor for UI conformance
    init(original: HistorySection, items: [HistoryRow]) {
        self = original
        self._items = Array<HistoryRow>(items)
    }
    
    /// Convenience for model-based construction
    init(goTimeGroups: [GoTimeGroup]) {
        self.goTimeGroups = goTimeGroups
    }
    
    // Internal structure for mapping model to UI
    private var _items: [HistoryRow]?
    
    /// Accessor for UI model
    var items: [HistoryRow] {
        let result = _items ?? initItems()
        return result
    }
    
    // Internal initializer for UI model
    private func initItems() -> [HistoryRow] {
        return goTimeGroups.map { HistoryRow(value: $0) }
    }
}

struct HistoryRow {
    var value: GoTimeGroup
}

/// UI conformance
extension HistoryRow : IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity : Identity {
        return value.id
    }
    
    static func ==(lhs: HistoryRow, rhs: HistoryRow) -> Bool {
        return lhs.value.id == rhs.value.id
    }
}


class HistoryViewModel {
    
    private let disposeBag = DisposeBag()
    private let persistenceManager = PersistenceManager()
    private var goTimeGroups: [GoTimeGroup]
    private let errorHelper: ErrorHelper
    private var poller: Timer?
    
    var historyChangeObs: Observable<[HistorySection]> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.persistenceManager.goTimesObs
                .subscribe(onNext: { groups in
                    print("HISTORY")
                    for g in groups {
                        print(g.desc())
                    }
                    observer.on(.next([HistorySection(goTimeGroups: groups)]))
            })
        }
    }
    
    init() {
        let errorHelper = ErrorHelper()
        do {
            self.goTimeGroups = try persistenceManager.loadGoTimeGroups()
        } catch {
            errorHelper.handleError(error)
            self.goTimeGroups = []
        }
        self.errorHelper = errorHelper
    }
}
