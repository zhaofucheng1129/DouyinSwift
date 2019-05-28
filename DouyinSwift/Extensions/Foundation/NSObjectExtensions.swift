//
//  NSObjectExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/11.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

private var keyPathDictKey: Void?
public extension NSObject {
    private(set) var keyPathDict: NSMutableDictionary? {
        get { return objc_getAssociatedObject(self, &keyPathDictKey) as? NSMutableDictionary }
        set { objc_setAssociatedObject(self, &keyPathDictKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func addTarget(target: KVOClosureTarget, keyPath: String) {
        if let dict = keyPathDict {
            if let arr = dict[keyPath] as? NSMutableArray {
                arr.add(target)
            } else {
                let arr = NSMutableArray(object: target)
                dict[keyPath] = arr
            }
        } else {
            let arr = NSMutableArray(object: target)
            let dict = NSMutableDictionary()
            dict[keyPath] = arr
            self.keyPathDict = dict
        }
    }
    
    class KVOClosureTarget: NSObject {
        public typealias Closure = (_ obj: Any?, _ oldVal: Any?, _ newVal: Any?) -> Void
        let closure: Closure
        init(closure: @escaping Closure) {
            self.closure = closure
        }
        
        override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let c = change else { return }
            if let isPrior = (c[.notificationIsPriorKey] as? Bool), isPrior { return }
            if let kind = c[.kindKey] as? NSKeyValueChange, kind == .setting { return }
            
            var oldVal: Any? = nil
            if let old = c[.oldKey] { oldVal = old }
            var newVal: Any? = nil
            if let new = c[.newKey] { newVal = new }
            
            closure(object, oldVal, newVal)
        }
    }
}

public extension NSObject {
    /// 便捷的添加观察者闭包
    ///
    /// ```
    /// scrollView.addObserverAction(keyPath: "contentOffset") { (obj, old, new) in
    ///     //do something
    /// }
    /// scrollView.addObserverAction(keyPath: #keyPath(UIScrollView.contentOffset)) { (obj, old, new) in
    ///     //do something
    /// }
    /// scrollView.addObserverAction(keyPath: \UIScrollView.contentOffset) { (obj, old, new) in
    ///     //do something
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - keyPath: 待观察的keyPath
    ///   - closure: 闭包
    func addObserverAction(keyPath: String, closure: @escaping NSObject.KVOClosureTarget.Closure) {
        let target = KVOClosureTarget(closure: closure)
        addTarget(target: target, keyPath: keyPath)
        addObserver(target, forKeyPath: keyPath, options: [.new, .old], context: nil)
    }
    
    
    /// 移除指定keyPath的观察者闭包
    ///
    /// - Parameter keyPath: keyPath
    func removeObserverAction(keyPath: String) {
        guard let dict = keyPathDict, let arr = dict.object(forKey: keyPath) as? Array<KVOClosureTarget> else { return }
        arr.forEach { self.removeObserver($0, forKeyPath: keyPath) }
        dict.removeObject(forKey: keyPath)
    }
    
    
    /// 移除所有观察者闭包
    func removeAllObserverAction() {
        guard let dict = keyPathDict as? [String: Array<KVOClosureTarget>] else { return }
        dict.forEach { (key, arr) in arr.forEach { removeObserver($0, forKeyPath: key) } }
    }
}
