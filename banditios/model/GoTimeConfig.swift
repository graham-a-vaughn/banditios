//
//  GoTimeConfig.swift
//  banditios
//
//  Created by Graham Vaughn on 1/21/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation

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
