//
//  CALayerExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/23.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension CALayer {
    
    /// 暂停动画
    func pauseAnimation() {
        //取出当前时间,转成动画暂停的时间
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        //设置动画运行速度为0
        speed = 0.0
        //设置动画的时间偏移量，指定时间偏移量的目的是让动画定格在该时间点的位置
        timeOffset = pausedTime
    }
    
    /// 恢复动画
    func resumeAnimation() {
        //获取暂停的时间差
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        //用现在的时间减去时间差,就是之前暂停的时间,从之前暂停的时间开始动画
        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}

public extension CALayer {
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
    
    var center: CGPoint {
        get { return CGPoint(x: origin.x + width * 0.5, y: origin.y + height * 0.5) }
        set { origin = CGPoint(x: newValue.x - width * 0.5, y: newValue.y - height * 0.5) }
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
