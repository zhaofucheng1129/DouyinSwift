//
//  BundleExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/9.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension Bundle {
    /// 应用名称
    static var appBundleName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    
    /// 应用ID
    static var appBundleID: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    }
    
    /// 应用版本号
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    /// 应用构建版本号
    static var appBuildVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
}

public extension Bundle {
    
    /// 首选的屏幕缩放比例
    static var preferredScales: [CGFloat] {
        let scale = UIScreen.main.scale
        if scale <= 1.0 {
            return [1.0,2.0,3.0]
        } else if scale <= 2.0 {
            return [2.0,3.0,1.0]
        } else {
            return [3.0,2.0,1.0]
        }
    }
}
