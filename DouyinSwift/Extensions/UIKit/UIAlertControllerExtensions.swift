//
//  UIAlertControllerExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/6.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

#if canImport(AudioToolbox)
import AudioToolbox
#endif


public extension UIAlertController {
    
    
    /// 显示方法
    ///
    /// - Parameters:
    ///   - animated: 是否开启动画，默认开启
    ///   - vibrate: 是否有震动提示，默认关闭
    ///   - completion: 显示后的回调方法
    func show(animated: Bool = true, vibrate: Bool = false, completion:(()->Void)? = nil) {
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: completion)
        if vibrate {
            #if canImport(AudioToolbox)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            #endif
        }
    }
    
    
    /// 添加按钮
    ///
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - style: 样式
    ///   - isEnabled: 是否可用，默认可用
    ///   - handler: 按钮回调闭包
    /// - Returns: 可忽略的按钮对象
    @discardableResult
    func addAction(title: String, style: UIAlertAction.Style = .default, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.isEnabled = isEnabled
        addAction(action)
        return action
    }
    
    
    /// 添加输入框
    ///
    /// - Parameters:
    ///   - text: 输入框默认文字
    ///   - placeholder: 提示文字
    ///   - callBack: 回调
    ///   - event: 事件 默认editingChanged
    func addTextField(text: String? = nil, placeholder: String? = nil, closure:ClosureTarger.Closure? = nil, events: UIControl.Event = .editingChanged) {
        addTextField {
            $0.text = text
            $0.placeholder = placeholder
            if let c = closure {
                $0.addAction(events: events, closure: c)
            }
        }
    }
}

public extension UIAlertController {
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 提示信息
    ///   - defaultButtonTitle: 默认按钮标题
    ///   - tintColor: 颜色
    convenience init(title: String = "提示", message: String? = nil, style: UIAlertController.Style = .alert, defaultButtonTitle: String = "确定", tintColor: UIColor? = nil) {
        self.init(title: title, message: message, preferredStyle: style)
        let defaultAction = UIAlertAction(title: defaultButtonTitle, style: .default, handler: nil)
        addAction(defaultAction)
        if let color = tintColor {
            view.tintColor = color
        }
    }
}
