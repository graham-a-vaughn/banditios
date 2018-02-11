//
//  Array+Bandit.swift
//  banditios
//
//  Created by Graham Vaughn on 2/11/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation

extension Array where Element: EquatableByValue {
    func equalByValue(_ other: Array<Element>) -> Bool {
        if other.count != self.count {
            return false
        }
        for i in 0..<self.count {
            if !(self[i] === other[i]) {
                return false
            }
        }
        return true
    }
}
