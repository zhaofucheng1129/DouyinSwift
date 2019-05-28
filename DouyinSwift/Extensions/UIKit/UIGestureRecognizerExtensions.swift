//
//  UIGestureRecognizerExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/11.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

private var targetsKey: Void?
public extension UIGestureRecognizer {
    private(set) var targets: NSMutableArray? {
        get { return objc_getAssociatedObject(self, &targetsKey) as? NSMutableArray }
        set { objc_setAssociatedObject(self, &targetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func addTarget(_ target: ClosureTarger) {
        if let t = targets {
            t.add(target)
        } else {
            let t = NSMutableArray()
            t.add(target)
            targets = t
        }
    }
    
    class ClosureTarger {
        public typealias Closure = (_ sender: UIGestureRecognizer) -> Void
        let closure: Closure
        init(closure: @escaping Closure) {
            self.closure = closure
        }
        @objc func invoke(sender: UIGestureRecognizer) -> Void {
            closure(sender)
        }
    }
}

public extension UIGestureRecognizer {
    
    /// 添加Action闭包
    ///
    /// - Parameter closure: 功能闭包
    func addAction(closure: @escaping UIGestureRecognizer.ClosureTarger.Closure) {
        let target = ClosureTarger(closure: closure)
        addTarget(target, action: #selector(ClosureTarger.invoke(sender:)))
        addTarget(target)
    }
    
    /// 移除所有Action
    func removeAllAction() {
        targets?.forEach({ (target) in
            removeTarget(target, action:  #selector(ClosureTarger.invoke(sender:)))
        })
        targets?.removeAllObjects()
    }
}

public extension UIGestureRecognizer {
    
    /// 使用功能闭包初始化一个手势
    ///
    /// - Parameter closure: 功能闭包
    convenience init(closure: @escaping UIGestureRecognizer.ClosureTarger.Closure) {
        self.init()
        addAction(closure: closure)
    }
}


