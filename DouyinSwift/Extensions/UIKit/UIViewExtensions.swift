//
//  UIViewExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/4.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit


// MARK: - 属性
public extension UIView {
    /// 边框颜色
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            layer.borderColor = color.cgColor
        }
    }
    
    /// 边框宽度
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    
    /// 返回视图快照
    @objc var snapshotImage: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    /// 圆角半径 cornerRadius只是对view的背景颜色和边框起作用；没有设置masksToBounds不会造成离屏渲染
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    var size: CGSize {
        get { return frame.size }
        set { width = newValue.width; height = newValue.height }
    }
    
    var width: CGFloat {
        get { return frame.size.width }
        set { return frame.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return frame.size.height }
        set { return frame.size.height = newValue }
    }
    
    var x: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }
    
    var left: CGFloat {
        get { return x }
        set { x = newValue }
    }
    
    var top: CGFloat {
        get { return y }
        set { y = newValue }
    }
    
    var right: CGFloat {
        get { return x + width }
        set { x = newValue - width }
    }
    
    var bottom: CGFloat {
        get { return y + height }
        set { y = newValue - height }
    }
    
    var centerX: CGFloat {
        get { return center.x }
        set { center.x = newValue }
    }
    
    var centerY: CGFloat {
        get { return center.y }
        set { center.y = newValue }
    }
    
    var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }
    
    
}


// MARK: - 方法
public extension UIView {
    
    
    /// 高性能的异步绘制圆角方法
    ///
    /// 原理是创建一个空白的图片，然后替换当前视图layer的contents
    ///
    /// 如果另外设置了backgroundColor属性，backgroundColor呈现的的背景颜色不会有圆角效果，需要搭配cornerRadius属性呈现圆角背景色
    ///
    /// 此方法指定的bgColor会在backgroundColor上层显示
    ///
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - corners: 圆角作用范围
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    ///   - bgColor: 背景颜色0
    func roundedCorner(radius: CGFloat, corners: UIRectCorner = [.allCorners], borderWidth: CGFloat? = nil, borderColor: UIColor? = nil, bgColor: UIColor) {
        let size = bounds.size
        DispatchQueue.global().async {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            guard let context = UIGraphicsGetCurrentContext() else { return }
            defer { UIGraphicsEndImageContext() }
            if let borderWidth = borderWidth {
                context.setLineWidth(borderWidth)
            }
            
            if let borderColor = borderColor {
                context.setStrokeColor(borderColor.cgColor)
            } else {
                context.setStrokeColor(UIColor.clear.cgColor)
            }
            
            context.setFillColor(bgColor.cgColor)
            
            let halfBorderWidth = borderWidth ?? 0 / 2.0
            let width = size.width
            let height = size.height
            
            context.move(to: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth))
            if corners.contains(.bottomRight) || corners.contains(.allCorners) {
                // 右下角角度
                context.addArc(tangent1End: CGPoint(x: width - halfBorderWidth, y: height - halfBorderWidth),
                               tangent2End: CGPoint(x: width - radius - halfBorderWidth, y: height - halfBorderWidth), radius: radius)
            } else {
                context.addLine(to: CGPoint(x: width - halfBorderWidth, y: height - halfBorderWidth))
            }
            
            if corners.contains(.bottomLeft) || corners.contains(.allCorners) {
                //左下角角度
                context.addArc(tangent1End: CGPoint(x: halfBorderWidth, y: height - halfBorderWidth),
                               tangent2End: CGPoint(x: halfBorderWidth, y: height - radius - halfBorderWidth), radius: radius)
            } else {
                context.addLine(to: CGPoint(x: halfBorderWidth, y: height - halfBorderWidth))
            }
            
            if corners.contains(.topLeft) || corners.contains(.allCorners) {
                //左上角角度
                context.addArc(tangent1End: CGPoint(x: halfBorderWidth, y: halfBorderWidth),
                               tangent2End: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth), radius: radius)
            } else {
                context.addLine(to: CGPoint(x: halfBorderWidth, y: halfBorderWidth ))
            }
            
            if corners.contains(.topRight) || corners.contains(.allCorners) {
                //右上角角度
                context.addArc(tangent1End: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth),
                               tangent2End: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth), radius: radius)
            } else {
                context.addLine(to: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth))
            }
            
            context.drawPath(using: .fillStroke)
            
            if let img = UIGraphicsGetImageFromCurrentImageContext() {
                DispatchQueue.main.async {
                    self.layer.contents = img.cgImage
                }
            }
        }
    }
    
    /// 包含子视图的快照
    ///
    /// drawHierarchy虽然比layer渲染速度快，但是处理超长视图时无法得到其图片，这时需要用Layer的渲染函数来处理。
    ///
    /// - Parameter afterUpdates: true:包含最近的屏幕更新内容 false:不包含刚加入视图层次但未显示的内容
    /// - Returns: 返回快照Image对象，可能为空
    func snapshotImage(afterUpdates: Bool) -> UIImage? {
        if !responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
            return snapshotImage
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        drawHierarchy(in: bounds, afterScreenUpdates: afterUpdates)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    /// 删除所有的子视图
    func removeSubviews() {
        subviews.forEach{ $0.removeFromSuperview() }
    }
    
    
    /// 返回视图中的第一响应者View
    ///
    /// - Returns: 第一响应者的View，可能为空
    func firstResponder() -> UIView? {
        let keyWindow = UIApplication.shared.keyWindow
        return keyWindow?.firstResponder()
    }
    
    
    /// 返回视图的控制器对象
    ///
    /// - Returns: 控制器对象，可能为空
    func viewController() -> UIViewController? {
        var view: UIView? = self
        repeat {
            if let nextResponder = view?.next {
                if nextResponder.isKind(of: UIViewController.self) {
                    return nextResponder as? UIViewController
                }
            }
            view = view?.superview
        } while view != nil
        
        return nil
    }
    
    
    /// 返回视图上叠加的alpha值
    ///
    /// - Returns: alhpa值
    func visibleAlpha() -> CGFloat {
        if isKind(of: UIWindow.self) {
            if isHidden { return 0 }
            return alpha
        }
        if window == nil { return 0 }
        var alpha:CGFloat = 1
        var v: UIView? = self
        while v != nil {
            let view = v!
            if view.isHidden { alpha = 0; break }
            alpha *= view.alpha
            v = view.superview
        }
        return alpha
    }
    
    
    
    /// 将当前坐标系的点转换到另一个视图或窗口的坐标系
    ///
    /// 当参数view为nil的时候，系统会自动帮你转换为当前窗口的基本坐标系（即view参数为整个屏幕，原点为(0,0)，宽高是屏幕的宽高）
    ///
    /// 计算公式：
    ///
    /// 1.如果`fromView`和`toView`不为`superView`关系
    ///
    /// ```
    /// (fromView.frame.origin - fromView.bounds.origin) + point - (toView.frame.origin - toView.bounds.origin)
    /// ```
    ///
    /// 2.如果'fromView'和'toView'有任何一方为另一方的'superView'，该view不再参与计算。
    /// ```
    /// [fromView addSubview:toView]; //即fromView为superView时
    /// ==> result = point - (toView.frame.origin - toView.bounds.origin)
    ///
    /// [toView addSubview:fromView]; //即toView为superView时
    /// ==> result = (fromView.frame.origin - fromView.bounds.origin) + point
    /// ```
    ///
    /// - Parameters:
    ///   - point: 当前视图坐标系的点
    ///   - view: 指定视图或窗口
    ///   - Returns: 转换坐标系后的点坐标
    func convertPoint(point: CGPoint, toViewOrWindow view: UIView?) -> CGPoint {
        guard let view = view else {
            if isKind(of: UIWindow.self) {
                return (self as! UIWindow).convert(point, to: nil)
            } else {
                return convert(point, to: nil)
            }
        }
        if let from = isKind(of: UIWindow.self) ? (self as! UIWindow) : window,
            let to = view.isKind(of: UIWindow.self) ? (view as! UIWindow) : view.window, from != to {
            var p = point
            p = convert(p, to: from)
            p = to.convert(p, to: from)
            p = view.convert(p, to: to)
            return p
        } else {
            return convert(point, to: view)
        }
    }
    
    
    /// 将一个点从一个指定视图或窗口的坐标系转换到当前视图坐标系
    ///
    /// 当参数view为nil的时候，系统会自动帮你转换为当前窗口的基本坐标系（即view参数为整个屏幕，原点为(0,0)，宽高是屏幕的宽高）
    ///
    /// 计算公式：
    ///
    /// 1.如果`fromView`和`toView`不为`superView`关系
    ///
    /// ```
    /// (fromView.frame.origin - fromView.bounds.origin) + point - (toView.frame.origin - toView.bounds.origin)
    /// ```
    ///
    /// 2.如果'fromView'和'toView'有任何一方为另一方的'superView'，该view不再参与计算。
    /// ```
    /// [fromView addSubview:toView]; //即fromView为superView时
    /// ==> result = point - (toView.frame.origin - toView.bounds.origin)
    ///
    /// [toView addSubview:fromView]; //即toView为superView时
    /// ==> result = (fromView.frame.origin - fromView.bounds.origin) + point
    /// ```
    ///
    /// - Parameters:
    ///   - point: 当前视图坐标系的点
    ///   - view: 指定视图或窗口
    ///   - Returns: 转换坐标系后的点坐标
    func convertPoint(point: CGPoint, fromViewOrWindow view: UIView?) -> CGPoint {
        guard let view = view else {
            if isKind(of: UIWindow.self) {
                return (self as! UIWindow).convert(point, from: nil)
            } else {
                return convert(point, from: nil)
            }
        }
        
        if let from = view.isKind(of: UIWindow.self) ? (view as! UIWindow) : view.window,
            let to = isKind(of: UIWindow.self) ? (self as! UIWindow) : window, from != to {
            var p = point
            p = from.convert(p, from: view)
            p = to.convert(p, from: from)
            p = convert(p, from: to)
            return p
        } else {
            return convert(point, from: nil)
        }
    }
    
    
    /// 将一个矩形区域从当前视图坐标系转换到指定视图或窗口坐标系
    ///
    /// 使用方法：
    /// ```
    /// CGRect rect = [_button.superview convertRect:_button.frame toViewOrWindow:self.view];
    /// ```
    ///
    /// button的frame是相对于其superview来确定的，frame确定了button在其superview的位置和大小
    ///
    /// 一般来说，toView方法中，消息的接收者为被转换的frame所在的控件的superview；fromView方法中，消息的接收者为即将转到的目标view.
    ///
    /// - Parameters:
    ///   - rect: 矩形区域
    ///   - view: 指定视图或窗口
    /// - Returns: 目标坐标系的矩形区域
    func convertRect(rect: CGRect, toViewOrWindow view: UIView?) -> CGRect {
        guard let view = view else {
            if isKind(of: UIWindow.self) {
                return (self as! UIWindow).convert(rect, to: nil)
            } else {
                return convert(rect, to: nil)
            }
        }
        
        if let from = isKind(of: UIWindow.self) ? (self as! UIWindow) : window,
            let to = view.isKind(of: UIWindow.self) ? (view as! UIWindow) : view.window, from != to {
            var r = rect
            r = convert(r, to: from)
            r = to.convert(rect, to: from)
            r = view.convert(rect, to: to)
            return r
        } else {
            return convert(rect, to: view)
        }
    }
    
    
    /// 将一个矩形区域从指定视图坐标系转换到当前视图或窗口坐标系
    ///
    /// 使用方法：
    /// ```
    /// CGRect rect = [self.view convertRect:_button.frame fromViewOrWindow:_button.superview];
    /// ```
    ///
    /// button的frame是相对于其superview来确定的，frame确定了button在其superview的位置和大小
    ///
    /// 一般来说，toView方法中，消息的接收者为被转换的frame所在的控件的superview；fromView方法中，消息的接收者为即将转到的目标view.
    ///
    /// - Parameters:
    ///   - rect: 矩形区域
    ///   - view: 指定视图或窗口
    /// - Returns: 当前坐标系的矩形区域
    func convertRect(rect: CGRect, fromViewOrWindow view: UIView?) -> CGRect {
        guard let view = view else {
            if isKind(of: UIWindow.self) {
                return (self as! UIWindow).convert(rect, from: nil)
            } else {
                return convert(rect, from: nil)
            }
        }
        
        if let from = view.isKind(of: UIWindow.self) ? (view as! UIWindow) : view.window,
            let to = isKind(of: UIWindow.self) ? (self as! UIWindow) : window, from != to {
            var r = rect
            r = from.convert(r, from: view)
            r = to.convert(r, from: from)
            r = convert(r, from: to)
            return r
        } else {
            return convert(rect, from: view)
        }
    }
    
    
    /// 添加阴影
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - radius: 半径
    ///   - offset: 偏移
    ///   - opacity: 透明度
    func addShadow(ofColor color: UIColor = UIColor(red: 0.07, green: 0.47, blue: 0.57, alpha: 1.0), radius: CGFloat = 3, offset: CGSize = .zero, opacity: Float = 0.5) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
 }
