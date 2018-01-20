//
//  GoTime.swift
//  banditios
//
//  Created by Graham Vaughn on 1/17/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import RxDataSources

struct GoTimeType {
    var name: String
    var primary: Bool = false
}

extension GoTimeType: Hashable {
    var hashValue: Int {
        return name.hashValue ^ primary.hashValue
    }
    
    static func ==(lhs: GoTimeType, rhs: GoTimeType) -> Bool {
        return lhs.name == rhs.name && lhs.primary == rhs.primary
    }
}

class GoTimeTypeConfig {
    private let defaultType: GoTimeType
    var typeMap: [GoTimeType: GoTimeType] = [:]
    
    init(_ defaultType: GoTimeType) {
        self.defaultType = defaultType
    }
    
    func nextType(_ type: GoTimeType?) -> GoTimeType {
        guard let type = type else { return defaultType }
        
        return typeMap[type] ?? defaultType
    }
}

class Node {
    var value: GoTime
    var next: Node?
    
    init(_ value: GoTime, next: Node?) {
        self.value = value
        self.next = next
    }
    
    func list(_ acc: [GoTime]) -> [GoTime] {
        var result: [GoTime] = next?.list(acc) ?? acc
        result.append(value)
        return result
    }
}

class NodeList {
    var head: Node?
    
    func list() -> [GoTime] {
        let result: [GoTime] = []
        return head?.list(result) ?? result
    }
    
    func add(_ value: GoTime) {
        let node = Node(value, next: head)
        head?.value.ended(value.start)
        head = node
    }
    
    func setValues(_ goTimes: [GoTime]) {
        for goTime in goTimes {
            add(goTime)
        }
    }
    
    func peek() -> GoTime? {
        return head?.value
    }
    
    func end() {
        head?.value.ended(Date.now)
    }
}

class GoTimeGroup: AnimatableSectionModelType {
    typealias Identity = Int
    private let goTimes = NodeList()
    private let publisher = PublishRelay<GoTimeGroup>()
    
    var items: [GoTime] {
        return goTimes.list()
    }
    
    var identity : Identity {
        return 0
    }
    
    var valueChangedObs: Observable<GoTimeGroup> {
        return publisher.asObservable()
    }
    
    convenience init(goTimes: [GoTime]?) {
        let values = goTimes ?? []
        self.init(original: self, items: values)
    }
    
    required init(original: GoTimeGroup, items: [GoTime]) {
        self.goTimes.setValues(items)
    }
    
    func add(_ goTime: GoTime) {
        goTimes.add(goTime)
        publisher.accept(self)
    }
    
    func current() -> GoTime? {
        return goTimes.peek()
    }
    
    func stop() {
        goTimes.end()
    }
}

class GoTime {
    var type: GoTimeType
    var start: Date
    private var _endRelay: PublishRelay<Date> = PublishRelay()
    private var _end: Date? = nil
    
    var end: Date? {
        return _end
    }
    
    var didEndObs: Observable<Date> {
        return _endRelay.asObservable()
    }
    
    init(start: Date, type: GoTimeType) {
        self.start = start
        self.type = type
    }
    
    func ended(_ endTime: Date) {
        guard _end == nil else { return }
        _endRelay.accept(endTime)
        _end = endTime
    }
}

extension GoTime : IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity : Identity {
        return start.hashValue
    }
    
    static func ==(lhs: GoTime, rhs: GoTime) -> Bool {
        return lhs.identity == rhs.identity
    }
}
