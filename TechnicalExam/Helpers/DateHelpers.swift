//
//  DateHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import UIKit

extension Calendar {
    static func getUTC() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? TimeZone.autoupdatingCurrent
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }

    static func getJST() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.autoupdatingCurrent
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }
}

extension Date {
    init(year: Int, month: Int, day: Int,
         hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanoSecond: Int? = nil) {
        let calendar = Calendar.getJST()
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        comps.second = second
        comps.nanosecond = nanoSecond
        self = calendar.date(from: comps)!
    }

    init?(utcDateString: String, with format: String = "yyyy/MM/dd HH:mm:ss") {
        let formatter = Date.utcDateFormatter
        formatter.dateFormat = format
        guard let result = formatter.date(from: utcDateString) else {
            return nil
        }
        self = result
    }

    init?(jstDateString: String, with format: String = "yyyy/MM/dd HH:mm:ss") {
        let formatter = Date.jstDateFormatter
        formatter.dateFormat = format
        guard let result = formatter.date(from: jstDateString) else {
            return nil
        }
        self = result
    }

    init?(iso8601 string: String) {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: string) else { return nil }
        self = date
    }

    init?(unixTime: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(unixTime))
    }

    init?(rfc1123 string: String) {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
        guard let date = formatter.date(from: string) else { return nil }
        self = date
    }

    var unixTimeString: String {
        String(Int64(timeIntervalSince1970))
    }

    var weekday: Int {
        let calendar = Calendar.getJST()
        return calendar.component(.weekday, from: self)
    }

    var onlyDate: Date? {
        let calendar = Calendar.getJST()
        guard let date = calendar.date(from: calendar.dateComponents([.year, .month, .day],
                                                                     from: self)) else {
            debugLog("Could not remove time info. from -> \(self)")
            return nil
        }
        return date
    }

    static var utcDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar.getUTC()
        return formatter
    }

    static var jstDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar.getJST()
        return formatter
    }

    var toIso8601: String {
        ISO8601DateFormatter().string(from: self)
    }

    var toRfc1123: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
        return formatter.string(from: self)
    }

    func component(_ component: Calendar.Component) -> Int {
        let calendar = Calendar.getJST()
        return calendar.component(component, from: self)
    }

    func dateComponents(_ components: Set<Calendar.Component>) -> DateComponents {
        let calendar = Calendar.getJST()
        return calendar.dateComponents(components, from: self)
    }

    func add(day: Int) -> Date? {
        let calendar = Calendar.getJST()
        return calendar.date(byAdding: .day, value: day, to: self)
    }

    func add(month: Int) -> Date? {
        let calendar = Calendar.getJST()
        return calendar.date(byAdding: .month, value: month, to: self)
    }

    func add(year: Int) -> Date? {
        let calendar = Calendar.getJST()
        return calendar.date(byAdding: .year, value: year, to: self)
    }

    func isSameDayWith(date: Date, calendar: Calendar = Calendar.getJST()) -> Bool {
        let selfComps = calendar.dateComponents([.year, .month, .day], from: self)
        let targetComps = calendar.dateComponents([.year, .month, .day], from: date)
        return selfComps.year == targetComps.year &&
            selfComps.month == targetComps.month &&
            selfComps.day == targetComps.day
    }

    func getSameComponents(
        target date: Date,
        components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second],
        calendar: Calendar = Calendar.getJST()
    ) -> DateComponents {
        let selfComps = calendar.dateComponents(components, from: self)
        let targetComps = calendar.dateComponents(components, from: date)
        var result = DateComponents()

        let keyPaths: [WritableKeyPath<DateComponents, Int?>] = [
            \.year, \.month, \.day,
            \.hour, \.minute, \.second
        ]
        keyPaths.forEach {
            if let value = selfComps[keyPath: $0], selfComps[keyPath: $0] == targetComps[keyPath: $0] {
                result[keyPath: $0] = value
            }
        }
        return result
    }

    func getFirstDayOfWeek() -> Date? {
        let weekday = component(.weekday)
    
        if weekday == 7 {
            return add(day: 0)
        }
        return add(day: -weekday)
    }

  
    func getStartOfMonth(monthOffSet: Int = 0, calendar: Calendar = Calendar.getJST()) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: self) as DateComponents
        guard let month = components.month else { return nil }
        components.month = month + monthOffSet
        return calendar.date(from: components)
    }


    func getEndOfMonth(monthOffset: Int = 0, calendar: Calendar = Calendar.getJST()) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: self) as DateComponents
        guard let month = components.month else { return nil }
        components.month = month + monthOffset + 1
        return calendar.date(from: components)?.add(day: -1)
    }


    func getStartOfADay(with dayOffSet: Int = 0, calendar: Calendar = Calendar.getJST()) -> Date? {
        var components: DateComponents = calendar.dateComponents([.year, .month, .day],
                                                                 from: self) as DateComponents
        guard let day = components.day else {
            return nil
        }
        components.day = day + dayOffSet
        return calendar.date(from: components as DateComponents)
    }

    func toString(by format: String) -> String {
        let calendar = Calendar.getJST()
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.calendar = calendar
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }

    func toStringForJST(by format: String) -> String {
        let calendar = Calendar.getJST()
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }

    func toStringForUTC(by format: String) -> String {
        let calendar = Calendar.getUTC()
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }

    func toLocalizedString(by format: String) -> String {
        let calendar = Calendar.getJST()
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate(format)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }

    func diff(from: Date, components: Set<Calendar.Component>) -> DateComponents {
        let calendar = Calendar.getJST()
        return calendar.dateComponents(components, from: from, to: self)
    }

    func diff(to toDate: Date, components: Set<Calendar.Component>) -> DateComponents {
        let calendar = Calendar.getJST()
        return calendar.dateComponents(components, from: self, to: toDate)
    }

    func setTime(_ value: Int, component: Calendar.Component) -> Date? {
        let calendar = Calendar.getJST()
        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
        switch component {
        case .year: comps.year = value
        case .month: comps.month = value
        case .day:  comps.day = value
        case .hour: comps.hour = value
        case .minute: comps.minute = value
        case .second: comps.second = value
        case .nanosecond: comps.nanosecond = value
        default:
            return nil
        }
        return calendar.date(from: comps)
    }

    static func getFrom(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar.getJST()
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return calendar.date(from: comps)
    }

    static func getFrom(yyyyMMdd: Int) -> Date? {
        if String(yyyyMMdd).count != 8 {
            return nil
        }
        let year = yyyyMMdd / 10000
        let month = yyyyMMdd / 100 % 100
        let day = yyyyMMdd % 100
        return Date.getFrom(year: year, month: month, day: day)
    }

    static func getWeeks(in month: Int, year: Int) -> Int {
        let days = getDays(in: month, year: year)
        let weekday = getFrom(year: year, month: month, day: 1)!.weekday
        if days == 28 {
            return weekday == 7 ? 4 : 5
        } else if days == 29 {
            return 5
        }
        if days == 30, weekday == 6 {
            return 6
        } else if days == 31, weekday == 5 || weekday == 6 {
            return 6
        }
        return 5
    }

    static func getDays(in month: Int, year: Int) -> Int {
        let days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        if month != 2 {
            return days[month - 1]
        }
        return isLeap(year: year) ? 29 : 28
    }

    static func isLeap(year: Int) -> Bool {
        year % 400 == 0 || (year % 100 != 0 && year % 4 == 0)
    }

    static func getUTCTimeStampFromDataStr(dataStr: String, format: String) -> TimeInterval? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let convertedDate = formatter.date(from: dataStr)
        let timeInterval = convertedDate?.timeIntervalSince1970
        return timeInterval
    }
    
    static func calculateMinimalMonth(from minDate: Date, to maxDate: Date, needsCount: Int) -> Date {
        let monthCount = (minDate.diff(to: maxDate, components: [.month]).month ?? 0) + 1
        if monthCount < needsCount {
            return minDate.add(month: monthCount - needsCount)?.getStartOfMonth() ?? minDate
        } else {
            return minDate
        }
    }

    func allDates(till endDate: Date) -> [Date] {
        var date = self
        var array: [Date] = []
        while date <= endDate {
            array.append(date)
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
        return array
    }
}
