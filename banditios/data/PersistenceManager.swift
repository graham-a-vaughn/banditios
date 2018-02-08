//
//  PersistenceManager.swift
//  banditios
//
//  Created by Graham Vaughn on 2/4/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
import SwiftyJSON
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
    private var persistenceHistory: [String: Bool] = [:]
    
    func saveGoTimes(_ goTimeGroup: GoTimeGroup) throws {
        try saveGoTimeGroupId(goTimeGroup.id)
        
        let saveDir = goTimeGroupPath(goTimeGroup.id)
        if !NSKeyedArchiver.archiveRootObject(goTimeGroup, toFile: saveDir.path) {
            throw PersistenceError.saveFailed(message: "Could not save go time groups")
        }
    }
    
    func loadGoTimeGroups() throws -> [GoTimeGroup] {
        let saveDir = Props.goTimeIdsUrl.path
        let persistedIds = try loadGoTimeGroupIds(saveDir)
        var loadedGroups: [GoTimeGroup] = []
        for id in persistedIds {
            let saveDir = goTimeGroupPath(id)
            let goTimeGroup = try loadGoTimeGroup(saveDir.path)
            loadedGroups.append(goTimeGroup)
        }
        return loadedGroups
    }
    
    private func saveGoTimeGroupId(_ id: Int) throws {
        let saveDir = Props.goTimeIdsUrl.path
        let currentIds = try loadGoTimeGroupIds(saveDir)
        if !currentIds.contains(id) {
            var idSet = Set<Int>(currentIds)
            idSet.insert(id)
            let updatedIds = Array<Int>(idSet)
            if !NSKeyedArchiver.archiveRootObject(updatedIds, toFile: saveDir) {
                throw PersistenceError.saveFailed(message: "Could not save go time group ids")
            }
        }
    }
    
    private func loadGoTimeGroupIds(_ dir: String) throws -> [Int] {
        guard let currentIds = persistedGoTimeIds(dir) as? [Int] else {
            throw PersistenceError.castFailed(message: "Could not cast go time group ids to [Int]")
        }
        return currentIds
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
    
    private func persistedGoTimeIds(_ dir: String) -> Any? {
        let currentIds = NSKeyedUnarchiver.unarchiveObject(withFile: dir)
        if currentIds == nil {
            print("No ids file found, creating one ...")
            return Array<Int>()
        }
        return currentIds
    }
    
    private func goTimeGroupPath(_ id: Int) -> URL {
        return Props.goTimeUrl.appendingPathComponent("\(id)")
    }
}
