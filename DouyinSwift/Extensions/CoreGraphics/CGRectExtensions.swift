//
//  CGRectExtensions.swift
//  GreatApp
//
//  Created by 赵福成 on 2019/4/5.
//  Copyright © 2019 zhaofucheng. All rights reserved.
//

import UIKit

public extension CGRect {
    
    
    /// 返回指定大小和显示模式下的区域
    ///
    /// - Parameters:
    ///   - size: 原始尺寸
    ///   - mode: 显示模式
    /// - Returns: 区域范围
    func rectFit(size: CGSize, mode: UIView.ContentMode) -> CGRect {
        var s = size
        var r = self
        s.width = s.width < 0 ? -s.width : s.width
        s.height = s.height < 0 ? -s.height : s.height
        let center = CGPoint(x: midX, y: midY)
        switch mode {
        case .scaleAspectFit, .scaleAspectFill:
            if r.size.width < 0.01 || r.size.height < 0.01 || s.width < 0.01 || s.height < 0.01 {
                r.origin = center
                r.size = CGSize.zero
            } else {
                var scale: CGFloat = 0
                if mode == .scaleAspectFit {
                    if s.width / s.height < r.size.width / r.size.height {
                        scale = r.size.height / s.height
                    } else {
                        scale = r.size.width / s.width
                    }
                } else {
                    if s.width / s.height < r.size.width / r.size.height {
                        scale = r.size.width / s.width
                    } else {
                        scale = r.size.height / s.height
                    }
                }
                
                s.width *= scale
                s.height *= scale
                r.size = s
                r.origin = CGPoint(x: center.x - s.width * 0.5, y: center.y - s.height * 0.5)
            }
        case .center:
            r.size = s
            r.origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        case .top:
            r.origin.x = center.x - s.width * 0.5
            r.size = s
        case .bottom:
            r.origin.x = center.x - s.width * 0.5
            r.origin.y += r.size.height - s.height
            r.size = s
        case .left:
            r.origin.y = center.y - size.height * 0.5
            r.size = s
        case .right:
            r.origin.y = center.y - size.height * 0.5
            r.origin.x += r.size.width - s.width
            r.size = s
        case .topLeft:
            r.size = s
        case .topRight:
            r.origin.x += r.size.width - size.width
            r.size = size
        case .bottomLeft:
            r.origin.y += r.size.height - s.height
            r.size = s
        case .bottomRight:
            r.origin.x += r.size.width - s.width
            r.origin.y += r.size.height - s.height
            r.size = s
        default:
            r = self
        }
        
        return r
    }
}
