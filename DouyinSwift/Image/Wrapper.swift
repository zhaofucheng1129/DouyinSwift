//
//  ImageWrapper.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/15.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

/// 包装类
public struct Wrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/// 约束Class
public protocol WrapperObject: AnyObject { }

/// 约束值类型
public protocol WrapperValue { }

extension WrapperObject {
    public var load: Wrapper<Self> {
        get { return Wrapper(self) }
        set { }
    }
}

extension WrapperValue {
    public var load: Wrapper<Self> {
        get { return Wrapper(self) }
        set { }
    }
}



class Delegate<Input, Output> {
    init() {}
    
    private var block: ((Input) -> Output?)?
    
    /// 代理方法
    ///
    /// - Parameters:
    ///   - target: 持有被代理对象的弱引用
    ///   - block: 传入的代理要执行的功能闭包 内部将持有 调用call时触发
    func delegate<T: AnyObject>(on target: T,block: ((T, Input) -> Output)?) {
        self.block = { [weak target] input in
            guard let target = target else { return nil }
            return block?(target, input)
        }
    }
    
    func call(_ input: Input) -> Output? {
        return block?(input)
    }
}

extension Delegate where Input == Void {
    /// 输入参数为Void时的调用方法
    func call() -> Output? {
        return call(())
    }
}
