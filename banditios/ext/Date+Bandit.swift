//
//  Date+Bandit.swift
//  banditios
//
//  Created by Graham Vaughn on 1/15/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import Foundation

public func - (lhs: Date, rhs: Date) -> TimeInterval {
    return lhs.timeIntervalSince(rhs)
}

private let relativeDayFormatter: DateFormatter = {
    var formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    formatter.doesRelativeDateFormatting = true
    return formatter
}()

private let timeFormatter: DateFormatter = DateFormatter(format: "h:mm a")

private let shortTimeFormatter: DateFormatter = DateFormatter(format: "h:mm")

private let detailTimeFormatter: DateFormatter = DateFormatter(format: "h:mm:ss")

private let monthFormater = DateFormatter(format: "MMMM")

private let dayOfWeekFormater = DateFormatter(format: "EEEE")

private let amPmFormatter = DateFormatter(format: "a")

extension TimeInterval {
    var int: Int {
        return Int(self)
    }
}

extension Date {
    /// Return the current time
    static var now : Date { return Date() }
    
    func asTimeWithSecondsString() -> String {
        return detailTimeFormatter.string(from: self)
    }
 
}

