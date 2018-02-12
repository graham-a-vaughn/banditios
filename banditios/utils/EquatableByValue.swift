//
//  EquatableByValue.swift
//  banditios
//
//  Created by Graham Vaughn on 2/11/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation

protocol EquatableByValue {
    
    static func ===(lhs: Self, rhs: Self) -> Bool
}

infix operator ===: ComparisonPrecedence
