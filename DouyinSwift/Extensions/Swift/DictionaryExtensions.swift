//
//  DictionaryExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/12.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension Dictionary {
    static func dictionary(plistData: Data) -> Dictionary<Key,Value>? {
        return try? PropertyListSerialization.propertyList(from: plistData, options: [.mutableContainersAndLeaves], format: nil) as? Dictionary<Key, Value>
    }
    
    static func dictionary(plistString: String) -> Dictionary<Key, Value>? {
        guard plistString.isNotBlank else { return nil }
        guard let data = plistString.data(using: .utf8) else { return nil }
        return dictionary(plistData: data)
    }
}

public extension Dictionary {
    var plistData: Data? {
        return try? PropertyListSerialization.data(fromPropertyList: self, format: .binary, options: .init())
    }
    
    var plistString: String? {
        return try? PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: .init()).utf8String
    }
    
    func jsonData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    func jsonString(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

public extension Dictionary {
    
    /// 是否含有指定的key
    ///
    /// - Parameter key: 指定Key
    /// - Returns: 包含返回true 否则返回false
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    
    /// 取出指定的keys组成的新字典
    ///
    /// - Parameter keys: key序列
    /// - Returns: 字典对象
    func values<S: Sequence>(keys: S) -> Dictionary<Key, Value> where S.Element == Key{
        let dict = self.filter { keys.contains($0.key) }
        return dict
    }
    
    /// 从字典中删除指定的Key
    mutating func remove<S: Sequence>(keys: S) where S.Element == Key {
        keys.forEach { removeValue(forKey: $0) }
    }
    
    /// 返回除了指定Key序列之外的元素组成的字典
    func remove<S: Sequence>(keys: S) -> Dictionary<Key, Value> where S.Element == Key {
        return filter { !keys.contains($0.key) }
    }
    
}

public extension Dictionary where Key: Comparable {
    
    /// 将所有Key排序返回一个数组,默认升序
    var allKeysSorted: Array<Key> {
        return keys.sorted(by: <)
    }
    
    /// 根据Key升序排列去的的Value数组
    var allValuesSortedByKeys: Array<Value> {
        let keys = allKeysSorted
        return keys.compactMap { self[$0] }
    }
    
}
