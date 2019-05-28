//
//  TimeZoneExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/12.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension TimeZone {
    //https://www.zeitverschiebung.net/en/
    //https://time.is/
    
    /// 中国标准时间
    ///
    /// UTC+8
    static var china: TimeZone {
        return TimeZone(identifier: "Asia/Shanghai")!
    }
    
    /// 日本标准时间
    ///
    /// UTC+9
    static var japan: TimeZone {
        return TimeZone(identifier: "Asia/Tokyo")!
    }
    
    /// 印度标准时间
    ///
    /// UTC+5:30
    static var india: TimeZone {
        return TimeZone(identifier: "Asia/Kolkata")!
    }
}
