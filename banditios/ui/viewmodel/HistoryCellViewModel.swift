//
//  HistoryCellViewModel.swift
//  banditios
//
//  Created by Graham Vaughn on 2/10/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class HistoryCellViewModel {
    
    private let goTimeGroup: GoTimeGroup
    private let createdPublisher = ReplaySubject<String>.createUnbounded()
    private let detailsPublisher = ReplaySubject<String>.createUnbounded()
    private let disposeBag = DisposeBag()
    
    var createdObs: Observable<String> {
        return createdPublisher.asObservable()
    }
    
    var detailsObs: Observable<String> {
        return detailsPublisher.asObservable()
    }
    
    init(_ goTimeGroup: GoTimeGroup) {
        self.goTimeGroup = goTimeGroup
        configureObservables()
    }
    
    private func configureObservables() {
        goTimeGroup.valueChangedObs.subscribeNext(weak: self) { strongSelf, group in
            strongSelf.createdPublisher.onNext(strongSelf.created)
            strongSelf.detailsPublisher.onNext(strongSelf.details)
        }
        .disposed(by: disposeBag)
    }
    
    private var created: String {
        return "Date: \(goTimeGroup.createdDate.asDayAndDateString())"
    }
    
    private var details: String {
        return "Items: \(goTimeGroup.items.count), \(spanString())"
    }
    
    private func spanString() -> String {
        guard let start = goTimeGroup.startTime else { return "Not started" }
        
        let endString = goTimeGroup.endTime?.asTimeOfDayString() ?? "(active)"
        return "\(start.asTimeOfDayString()) - \(endString)"
    }
}
