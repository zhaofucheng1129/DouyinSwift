//
//  CALayerExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/23.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

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
