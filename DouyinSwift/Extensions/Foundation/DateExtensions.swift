//
//  DateExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/12.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension Date {
    
    /// 年
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    /// 月
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    /// 日期
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// 时
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    /// 分
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// 秒
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    /// 纳秒
    var nanosecond: Int {
        return Calendar.current.component(.nanosecond, from: self)
    }
    
    /// 季度
    var quarter: Int {
        return Calendar.current.component(.quarter, from: self)
    }
    
    /// 星期 1～7 默认第一天为星期天，可以在设置中进行设置修改
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    /// 当前月份的工作周第几周
    var weekdayOrdinal: Int {
        return Calendar.current.component(.weekdayOrdinal, from: self)
    }
    
    /// 当前月的第几周 1~5
    var weekOfMonth: Int {
        return Calendar.current.component(.weekOfMonth, from: self)
    }
    
    /// 当年的第几周 1~53
    var weekOfYear: Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }
    /// 基于ISO week date
    /// https://en.wikipedia.org/wiki/ISO_week_date
    var yearForWeakOfYear: Int {
        return Calendar.current.component(.yearForWeekOfYear, from: self)
    }
    
    /// 是否闰月
    var isLeapMonth: Bool {
        return Calendar.current.dateComponents([.quarter], from: self).isLeapMonth ?? false
    }
    
    /// 是否是闰年
    var isLeapYear: Bool {
        return (year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0))
    }
    
    /// 是否是今天
    var isToday: Bool {
        if fabs(timeIntervalSinceNow) > 60 * 60 * 24 { return false }
        return Date().day == day
    }
    
    
    
    /// ISO 8601格式
    var isoFormat: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: self)
    }
}

public extension Date {
    
    /// 返回增加指定年数后的日期
    ///
    /// - Parameter years: 年数
    /// - Returns: 如果年数增加后错误则返回当前日期
    func adding(years: Int) -> Date {
        var components = DateComponents()
        components.year = years
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    /// 返回增加指定月数后的日期
    ///
    /// - Parameter months: 月数
    /// - Returns: 如果月数增加后错误则返回当前日期
    func adding(months: Int) -> Date {
        var components = DateComponents()
        components.month = months
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    
    /// 返回增加指定周数后的日期
    ///
    /// - Parameter weaks: 周数
    /// - Returns: 如果周数增加后错误则返回当前日期
    func adding(weaks: Int) -> Date {
        var components = DateComponents()
        components.weekOfYear = weaks
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    /// 返回增加指定天数后的日期
    ///
    /// - Parameter days: 天数
    /// - Returns: 如果天数增加后错误则返回当前日期
    func adding(days: Int) -> Date {
        var components = DateComponents()
        components.day = days
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    /// 返回增加指定小时数后的日期
    ///
    /// - Parameter hours: 小时数
    /// - Returns: 如果小时数增加后错误则返回当前日期
    func adding(hours: Int) -> Date {
        var components = DateComponents()
        components.hour = hours
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    /// 返回增加指定分钟数后的日期
    ///
    /// - Parameter minutes: 分钟数
    /// - Returns: 如果分钟数增加后错误则返回当前日期
    func adding(minutes: Int) -> Date {
        var components = DateComponents()
        components.minute = minutes
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    /// 返回增加指定秒数后的日期
    ///
    /// - Parameter seconds: 秒数
    /// - Returns: 如果秒数增加后错误则返回当前日期
    func adding(seconds: Int) -> Date {
        var components = DateComponents()
        components.second = seconds
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    /// 返回指定格式的字符串
    ///
    ///     date.string(format: "yyyy-MM-dd HH:mm:ss")
    ///
    /// - Parameters:
    ///   - format: 日期格式
    ///   - timeZone: 时区 默认当前时区
    ///   - locale: 地区 默认当前地区
    /// - Returns: 日期字符串
    func string(format: String, timeZone: TimeZone? = nil, locale: Locale? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let timeZone = timeZone { formatter.timeZone = timeZone } else { formatter.timeZone = .current }
        if let locale = locale { formatter.locale = locale } else { formatter.locale = .current }
        return formatter.string(from: self)
    }
}

public extension Date {
    
    /// 将日期字符串根据指定格式转换为日期对象
    ///
    /// - Parameters:
    ///   - str: 日期字符串
    ///   - format: 日期格式
    ///   - timeZone: 时区
    ///   - locale: 地区
    /// - Returns: 日期对象
    static func date(for strDate: String, format: String, timeZone: TimeZone? = nil, locale: Locale? = nil) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let timeZone = timeZone { formatter.timeZone = timeZone }
        if let locale = locale { formatter.locale = locale }
        return formatter.date(from: strDate)
    }
    
    /// 将ISO 8601格式的字符串转换为日期对象
    ///
    /// - Parameter isoDate: ISO 8601格式日期字符串
    /// - Returns: 日期对象
    static func date(isoDate: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: isoDate)
    }
}
