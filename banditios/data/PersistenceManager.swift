//
//  PersistenceManager.swift
//  banditios
//
//  Created by Graham Vaughn on 2/4/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

class Props {
    static let persistDir = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let goTimeGroup = "GoTimeGroup"
    static let goTimeIds = "GoTimeGroupIds"
    
    static let goTimeUrl = persistDir.appendingPathComponent(goTimeGroup)
    static let goTimeIdsUrl = persistDir.appendingPathComponent(goTimeIds)
    
    
}

enum PersistenceError: Error {
    case castFailed(message: String)
    case saveFailed(message: String)
    case loadFailed(message: String)
}

class PersistenceManager {
    private let goTimesSubject = ReplaySubject<[GoTimeGroup]>.create(bufferSize: 1)
    private let goTimesRelay = BehaviorRelay<Void>(value: ())
    private let errorHandler = ErrorHelper()
    private let disposeBag = DisposeBag()
    
    var goTimesObs: Observable<[GoTimeGroup]> {
        return goTimesSubject.asObservable()
            .distinctUntilChanged { lhs, rhs in
                return lhs.equalByValue(rhs)
        }
    }
    
    init() {
        goTimesRelay.asObservable().subscribeNext(weak: self) { strongSelf, _ in
            do {
                try strongSelf.goTimesSubject.onNext(strongSelf.loadGoTimeGroups())
            } catch {
                strongSelf.errorHandler.handleError(error)
            }
            
        }.disposed(by: disposeBag)
    }
    
    func terminateOpenGoTimes() {
        do {
            var open: [GoTimeGroup] = []
            let goTimes = try loadGoTimeGroups()
            for time in goTimes {
                if time.endTime == nil {
                    open.append(time)
                }
            }
            print("Auto-closing open go times, count: \(open.count)")
            for time in open {
                try saveGoTimes(time)
            }
        } catch {
            print("Error encountered attempting to clean up open go times")
            errorHandler.handleError(error)
        }
    }
    
    func autoSaveGoTimes(_ goTimeGroup: GoTimeGroup) throws {
        guard !goTimeGroup.isEmpty && !goTimeGroup.isLocked else { return }
        try persistGoTime(goTimeGroup)
    }
    
    func saveGoTimes(_ goTimeGroup: GoTimeGroup) throws {
        guard !goTimeGroup.isEmpty else { return }
        
        goTimeGroup.buttonUp()
        try persistGoTime(goTimeGroup)
    }
    
    func loadGoTimeGroups() throws -> [GoTimeGroup] {
        let persistedIds = try loadOrFailGoTimeIds()
        var loadedGroups: [GoTimeGroup] = []
        var misses: [Int] = []
        for id in persistedIds {
            let saveDir = goTimeGroupPath(id)
            do {
                let goTimeGroup = try loadGoTimeGroup(saveDir.path)
                loadedGroups.append(goTimeGroup)
            } catch {
                misses.append(id)
            }
        }
        print("Loaded all go time ids, count: \(loadedGroups.count)")
        try pruneGoTimeIds(misses)
        return loadedGroups
    }
    
    private func persistGoTime(_ goTimeGroup: GoTimeGroup) throws {
        try saveGoTimeGroupId(goTimeGroup.id)
        
        goTimeGroup.lastModified = Date.now
        let saveDir = goTimeGroupPath(goTimeGroup.id)
        if !NSKeyedArchiver.archiveRootObject(goTimeGroup, toFile: saveDir.path) {
            throw PersistenceError.saveFailed(message: "Could not save go time groups: \(saveDir.path)")
        }
        goTimesRelay.accept(())
    }
    
    private func loadGoTimeGroup(_ dir: String) throws -> GoTimeGroup {
        let goTimeGroup = NSKeyedUnarchiver.unarchiveObject(withFile: dir)
        if goTimeGroup == nil {
            throw PersistenceError.loadFailed(message: "Could not load go time group at \(dir)")
        }
        if let goTimeGroup = goTimeGroup as?  GoTimeGroup {
            return goTimeGroup
        }
        throw PersistenceError.castFailed(message: "Could not cast go time group at \(dir)")
    }
    
    private func loadOrFailGoTimeIds() throws -> [Int] {
        let dir = Props.goTimeIdsUrl.path
        guard let currentIds = getOrCreateGoTimeIds(dir) as? [Int] else {
            throw PersistenceError.castFailed(message: "Could not cast go time group ids to [Int]")
        }
        return currentIds
    }
    
    private func getOrCreateGoTimeIds(_ dir: String) -> Any? {
        let currentIds = NSKeyedUnarchiver.unarchiveObject(withFile: dir)
        if currentIds == nil {
            print("No ids file found, creating one ...")
            return Array<Int>()
        }
        return currentIds
    }
    
    private func pruneGoTimeIds(_ toRemove: [Int]) throws {
        guard !toRemove.isEmpty else { return }
        
        print("Pruning go time ids: \(toRemove)")
        let currentIds = try loadOrFailGoTimeIds()
        let prunedIds = currentIds.filter { !toRemove.contains($0)}
        try saveGoTimeIds(prunedIds)
    }
    
    private func saveGoTimeGroupId(_ id: Int) throws {
        
        let currentIds = try loadOrFailGoTimeIds()
        if !currentIds.contains(id) {
            var idSet = Set<Int>(currentIds)
            idSet.insert(id)
            let updatedIds = Array<Int>(idSet)
            try saveGoTimeIds(updatedIds)
        }
    }
    
    private func saveGoTimeIds(_ ids: [Int]) throws {
        let saveDir = Props.goTimeIdsUrl.path
        if !NSKeyedArchiver.archiveRootObject(ids, toFile: saveDir) {
            throw PersistenceError.saveFailed(message: "Could not save go time group ids")
        }
    }
    
    private func goTimeGroupPath(_ id: Int) -> URL {
        return Props.persistDir.appendingPathComponent("\(Props.goTimeGroup)\(id)")
    }
}
