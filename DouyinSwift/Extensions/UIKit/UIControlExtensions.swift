//
//  UIControlExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/11.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public protocol TargetActionToClosure: AnyObject {
    var targets: NSMutableArray? { get }
}

private var targetsKey: Void?
extension TargetActionToClosure {
    private(set) public var targets: NSMutableArray? {
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
}

public class ClosureTarger {
    public typealias Closure = (_ sender: UIControl) -> Void
    let closure: Closure
    var events: UIControl.Event
    init(closure: @escaping Closure, events: UIControl.Event) {
        self.closure = closure
        self.events = events
    }
    @objc func invoke(sender: UIControl) -> Void {
        closure(sender)
    }
}

extension UIControl: TargetActionToClosure {
    
    /// 添加一个对应事件的闭包
    ///
    /// 不会删除之前的事件，会产生多个闭包对应同一个事件的情况
    ///
    /// - Parameters:
    ///   - events: 事件类型
    ///   - closure: 强引用闭包
    func addAction(events: UIControl.Event, closure: @escaping ClosureTarger.Closure) {
        let target = ClosureTarger(closure: closure, events: events)
        addTarget(target, action: #selector(ClosureTarger.invoke(sender:)), for: events)
        addTarget(target)
    }
    
    /// 设置一个事件的闭包
    ///
    /// 如果之前添加了对应的事件则替换为当前设置的
    ///
    /// - Parameters:
    ///   - events: 事件类型
    ///   - closure: 强引用闭包
    func setAction(events: UIControl.Event, closure: @escaping ClosureTarger.Closure) {
        removeAllAction(events: events)
        addAction(events: events, closure: closure)
    }
    
    /// 删除指定时间类型的Action
    ///
    /// - Parameter events: 事件类型，默认为全部
    func removeAllAction(events: UIControl.Event = .allEvents) {
        var removes = [Any]()
        targets?.forEach({ (target) in
            let oldEvents = (target as! ClosureTarger).events
            if oldEvents.rawValue & events.rawValue != 0 {
                let newEvent = UIControl.Event(rawValue: oldEvents.rawValue & (~events.rawValue))
                if newEvent != .init() {
                    removeTarget(target, action: #selector(ClosureTarger.invoke(sender:)), for: oldEvents)
                    (target as! ClosureTarger).events = newEvent
                    addTarget(target, action: #selector(ClosureTarger.invoke(sender:)), for: newEvent)
                } else {
                    removeTarget(target, action: #selector(ClosureTarger.invoke(sender:)), for: oldEvents)
                    removes.append(target)
                }
            }
        })
        targets?.removeObjects(in: removes)
    }
}
