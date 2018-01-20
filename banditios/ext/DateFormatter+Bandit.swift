//
//  DateFormatter+Bandit.swift
//  banditios
//
//  Created by Graham Vaughn on 1/15/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation
extension DateFormatter {
    
    /**
     Convenience init to create a DateFormatter with a date format
     
     - parameter format: A string representation of a Date Format
     */
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}
