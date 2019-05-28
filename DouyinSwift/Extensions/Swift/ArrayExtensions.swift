//
//  ArrayExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/7.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

public extension Array {
    
//    mutating func remove(object: Element)  {
//        guard let index = index(of: object) else {return}
//        remove(at: index)
//    }
    
    /// 在头部插入元素
    ///
    /// - Parameter newElement: 待插入的元素
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
    
    
    /// 将序列插入数组头部
    ///
    /// - Parameter newElements: 待插入序列
    mutating func prepend<S>(contentsOf newElements: S) where S : Sequence, Array.Element == S.Element {
        insert(contentsOf: Array(newElements), at: 0)
    }
    
    
    /// 删除并返回数组头元素
    ///
    /// - Returns: 元素
    mutating func popFirst() -> Element? {
        guard let ele = first else { return nil }
        self = Array(dropFirst())
        return ele
    }
    
    
    /// 交换两个位置上的元素
    ///
    ///     [1, 2, 3, 4, 5].safeSwap(from: 3, to: 0) -> [4, 2, 3, 1, 5]
    ///     ["h", "e", "l", "l", "o"].safeSwap(from: 1, to: 0) -> ["e", "h", "l", "l", "o"]
    ///
    /// - Parameters:
    ///   - index: 第一个元素的位置
    ///   - otherIndex: 另一个元素的位置
    mutating func safeSwap(from index: Index, to otherIndex: Index) {
        guard index != otherIndex else { return }
        guard startIndex..<endIndex ~= index else { return }
        guard startIndex..<endIndex ~= otherIndex else { return }
        swapAt(index, otherIndex)
    }
}

public extension Array {
    
    /// 返回plistData
    var plistData: Data? {
        do {
            return try PropertyListSerialization.data(fromPropertyList: self, format: .binary, options: .init())
        } catch {
            print("Plist data error: \(error)")
        }
        return nil
    }
    
    
    /// 返回plist字符串
    var plistString: String? {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: .init())
            return data.utf8String
        } catch {
            print("Plist string error: \(error)")
        }
        return nil
    }
    
    
    /// 返回json字符串
    var jsonString: String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .init())
            return data.utf8String
        } catch {
            print("Json string error: \(error)")
        }
        return nil
    }
    
    /// 返回格式化的json字符串
    var jsonPrettyString: String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return data.utf8String
        } catch {
            print("Json pretty string error: \(error)")
        }
        return nil
    }
}


public extension Array {
    /// 使用plist字符串初始化数组
    ///
    /// - Parameter plistString: plist 字符串
    /// - Returns: 数组对象
    static func array(plistString: String) -> Array<Element>? {
        guard !plistString.isEmpty else { return nil }
        guard let data = plistString.data(using: .utf8) else { return nil}
        return array(plistData: data)
    }
    
    /// 使用plist数据初始化数组
    ///
    /// - Parameter plistData: plist 数据
    /// - Returns: 数组对象
    static func array(plistData: Data) -> Array<Element>? {
        guard plistData.count > 0 else { return nil }
        do {
            return try PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: nil) as? Array<Element>
        } catch {
            print("PlistData init array error: \(error)")
        }
        return nil
    }
    
    
    /// 使用json数据初始化数组
    ///
    /// - Parameter jsonString: json数据
    /// - Returns: 数组对象
    static func array(jsonString: String) -> Array<Element>? {
        guard !jsonString.isEmpty else { return nil }
        guard let data = jsonString.data(using: .utf8) else { return nil}
        guard let array = data.jsonValueDecoded() as? Array else { return nil }
        return array
    }
}
