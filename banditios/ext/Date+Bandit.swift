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

enum TimeUnit: TimeInterval {
    case second = 1
    case minute = 60
    case hour = 3600
    
    var value: Int {
        return self.rawValue.int
    }
}

extension TimeInterval {
    var int: Int {
        return Int(self)
    }
}

extension Date {
    /// Return the current time
    static var now : Date { return Date() }
    
    /// Convenience initializer for creating a Date from its ISO8601 representation
    /*
    init?(iso8601String: String) {
        guard let date = BoredzoISO8601DateFormatter.getDefault().date(from: iso8601String) else { return nil }
        self = date
    }
 */
    
    /// Convenience initializer for creating a Date corresponding to given number of milliseconds since Unix epoch
    /// (since 00:00:00 UTC on 1 January 1970)
    init(millisSince1970: Double) {
        self.init(timeIntervalSince1970: millisSince1970 / 1000)
    }
    
    /// Convenience initializer for creating a date with given date components in given timezone
    /// All components except year are optional with reasonable defaults, for convenience.
    init(year: Int, month: Int = 1, day: Int = 1,
         hour: Int = 0, minute: Int = 0, second: Int = 0,
         timeZone: TimeZone? = nil) {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = timeZone
        self.init(timeInterval: 0, since: Calendar.current.date(from: components)!)
    }
    
    init(hour: Int, minute: Int, second: Int) {
        self.init(year: 2000, month: 1, day: 1, hour: hour, minute: minute, second: second, timeZone: nil)
    }
    
    /**
     Returns a string describing the date relative to today. Possible return values
     include "Today" and "Tomorrow"
     */
    func asRelativeDayString() -> String {
        return relativeDayFormatter.string(from: self)
    }
    
    /**
     Returns a string of a date formatted in the following way
     <Day>, <Month> <DateWithOrdinal>  ie.  Monday, September 12th
     If its today or tomorrow, will say today or tomorrow instead of day of week
     */
    func asRelativeDateWithOrdinalString() -> String {
        var dayOfWeek: String = ""
        if self.isToday {
            dayOfWeek = "Today"
        } else if self.isTomorrow {
            dayOfWeek = "Tomorrow"
        } else {
            dayOfWeek = dayOfWeekFormater.string(from: self)
        }
        let month = monthFormater.string(from: self)
        let day = self.dayWithOrdinalSuffix
        
        return "\(dayOfWeek), \(month) \(day)"
    }
    
    /**
     Returns a string describing the time. Possible return values
     include "7:30 PM" and "11:01 AM"
     */
    func asTimeString() -> String {
        return timeFormatter.string(from: self)
    }
    
    func asDetailedTimeString() -> String {
        return detailTimeFormatter.string(from: self)
    }
    
    /// Returns a string describing the time range between the given dates.
    /// The am/pm component of the time range will be consolidated if
    /// it is the same for both times. Possible return values include
    /// "10:30 - 11:00 AM" and "11:30 PM - 12:30 AM"
    static func asTimeRangeString(from: Date, to: Date) -> String {
        let startTime = (amPmFormatter.string(from: from) == amPmFormatter.string(from: to)) ?
            shortTimeFormatter.string(from: from) :
            timeFormatter.string(from: from)
        let endTime = timeFormatter.string(from: to)
        return "\(startTime) - \(endTime)"
    }
    
    static func asTimeIntervalString(_ interval: TimeInterval) -> String {
        var hours = 0
        var minutes = 0
        var seconds = 0
        var remainder = 0
        
        if interval >= TimeUnit.hour.rawValue {
            hours = (Int(interval) / Int(TimeUnit.hour.rawValue))
            remainder = Int(interval.remainder(dividingBy: TimeUnit.hour.rawValue))
        } else {
            remainder = Int(interval)
        }
        if remainder >= Int(TimeUnit.minute.rawValue) {
            minutes = (Int(remainder)) / (Int(TimeUnit.minute.rawValue))
            remainder = Int(Double(remainder).remainder(dividingBy: TimeUnit.minute.rawValue))
        }
        seconds = Int(remainder)
        let asTime = Date(hour: hours, minute: minutes, second: seconds)
        return detailTimeFormatter.string(from: asTime)
    }
    
    func asElapsedTimeString() -> String {
        let offset = Date.now
        let elapsed: TimeInterval = offset - self
        return Date.asTimeIntervalString(elapsed)
    }
    
    /// returns true if the Date is in the past
    var isInPast : Bool {
        return self.timeIntervalSinceNow < 0
    }
    
    /// returns true if the Date is equal to now or in the past
    var isPresentOrPast: Bool {
        return self.timeIntervalSinceNow <= 0
    }
    
    /// returns true if the Date is in the future
    var isInFuture : Bool {
        return self.timeIntervalSinceNow > 0
    }
    
    /// returns the start of the day for the given date
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// returns true if this date is today, false otherwise
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// returns true if this date is tomorrow, false otherwise
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    /// returns a string of the day with its ordinal suffix (st, nd, rd, th)
    var dayWithOrdinalSuffix: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        let dayOfMonth = (Calendar.current as Calendar).component(.day, from: self)
        return numberFormatter.string(from: NSNumber(value: dayOfMonth))!
    }
    
}

